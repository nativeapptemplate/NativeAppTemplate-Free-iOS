//
//  LocalizationTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// The app ships in English and Japanese. Every string catalog key must have a
/// Japanese translation, so a string added without one fails here instead of
/// showing up in English on a Japanese device.
struct LocalizationTest {
    /// The catalog tests read the .xcstrings sources from the Mac through #filePath,
    /// which a simulator can do and a device cannot. They run on the simulator (and CI);
    /// a device run skips them instead of failing with "no such file".
    static let canReadSourceCatalogs: Bool = {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }()

    // MARK: - Every key has Japanese

    @Test(.enabled(if: canReadSourceCatalogs, "Reads the .xcstrings sources on the Mac"))
    func everyLocalizableKeyHasJapanese() throws {
        let catalog = try StringCatalog(named: "Localizable.xcstrings")
        #expect(catalog.strings.count > 100) // guards against reading the wrong (or an empty) file
        #expect(catalog.keysMissingJapanese.isEmpty, "Missing Japanese: \(catalog.keysMissingJapanese)")
    }

    @Test(.enabled(if: canReadSourceCatalogs, "Reads the .xcstrings sources on the Mac"))
    func everyInfoPlistStringHasJapanese() throws {
        let catalog = try StringCatalog(named: "InfoPlist.xcstrings")
        #expect(catalog.keysMissingJapanese.isEmpty, "Missing Japanese: \(catalog.keysMissingJapanese)")

        // Every permission prompt in Info.plist must be in the catalog
        let infoPlist = try #require(Bundle.main.infoDictionary)
        for key in infoPlist.keys where key.hasSuffix("UsageDescription") {
            #expect(catalog.strings[key] != nil, "\(key) is not in InfoPlist.xcstrings")
        }
    }

    /// The home screen name stays the product name, which the rename replaces in English
    @Test(.enabled(if: canReadSourceCatalogs, "Reads the .xcstrings sources on the Mac"))
    func appNameIsNotTranslated() throws {
        let catalog = try StringCatalog(named: "InfoPlist.xcstrings")
        let values = Dictionary(uniqueKeysWithValues: catalog.japaneseValues)
        #expect(values["CFBundleDisplayName"] == "Native App Template")
        #expect(values["CFBundleName"] == "NativeAppTemplate")
    }

    @Test(.enabled(if: canReadSourceCatalogs, "Reads the .xcstrings sources on the Mac"))
    func japaneseKeepsTheSameFormatSpecifiers() throws {
        let catalog = try StringCatalog(named: "Localizable.xcstrings")
        for (key, japanese) in catalog.japaneseValues {
            #expect(
                Self.formatSpecifiers(in: japanese) == Self.formatSpecifiers(in: key),
                "\(key) -> \(japanese)"
            )
        }
    }

    /// Shop is 店舗 throughout, as in the API's ja.yml (店舗名). nativeapptemplate-agent
    /// renames 店舗 as a substring, so ショップ, 店 or お店 would survive a rename.
    @Test(.enabled(if: canReadSourceCatalogs, "Reads the .xcstrings sources on the Mac"))
    func shopIsAlways店舗() throws {
        let catalog = try StringCatalog(named: "Localizable.xcstrings")
        let offenders = catalog.japaneseValues.filter { _, japanese in
            japanese.contains("ショップ") || Self.removing("店舗", from: japanese).contains("店")
        }
        #expect(offenders.isEmpty, "Use 店舗: \(offenders)")
    }

    /// An ItemTag is アイテムタグ in full: nativeapptemplate-agent renames アイテムタグ
    /// as a substring, so a shortened タグ or アイテム would survive a rename.
    @Test(.enabled(if: canReadSourceCatalogs, "Reads the .xcstrings sources on the Mac"))
    func itemTagIsAlwaysアイテムタグInFull() throws {
        let catalog = try StringCatalog(named: "Localizable.xcstrings")
        let offenders = catalog.japaneseValues.filter { _, japanese in
            let rest = Self.removing("アイテムタグ", from: japanese)
            return rest.contains("タグ") || rest.contains("アイテム")
        }
        #expect(offenders.isEmpty, "Use アイテムタグ: \(offenders)")
    }

    // MARK: - The built app carries Japanese

    @Test
    func appDeclaresJapanese() {
        #expect(Bundle.main.localizations.contains("ja"))
        #expect(Bundle.main.developmentLocalization == "en")
    }

    /// Expected values come from the glossary shared with the Android app and the
    /// API's config/locales/ja.yml (店舗, アイテムタグ), and match the paid edition.
    @Test(arguments: [
        ("Shops", "店舗"),
        ("Shop Name", "店舗名"),
        ("Add Shop", "店舗を追加"),
        ("Settings", "設定"),
        ("Manage Item Tags", "アイテムタグの管理"),
        ("Add Item Tag", "アイテムタグを追加"),
        ("Idled", "未完了"),
        ("Completed", "完了"),
        ("Mark as completed", "完了にする"),
        ("Mark as idled", "未完了に戻す"),
        ("App Language", "アプリの言語"),
        ("Change in Settings", "端末の設定で変更"),
        ("Emails are sent in this language too.", "メールもこの言語で届きます。"),
        ("Sign In", "サインイン"),
        ("Sign Out", "サインアウト"),
        ("Sign Up", "新規登録"),
    ])
    func japaneseSpotCheck(english: String, japanese: String) throws {
        #expect(try Self.japaneseBundle().localizedString(forKey: english, value: nil, table: nil) == japanese)
    }

    /// Tests run in English (the scheme's test action), so the constants other
    /// tests compare against stay English on a Japanese simulator.
    @Test
    func testsRunInEnglish() {
        #expect(Strings.shops == "Shops")
        #expect(Strings.appLanguage == "App Language")
    }

    // MARK: - Helpers

    private static func japaneseBundle() throws -> Bundle {
        let path = try #require(Bundle.main.path(forResource: "ja", ofType: "lproj"))
        return try #require(Bundle(path: path))
    }

    private static func removing(_ word: String, from string: String) -> String {
        string.replacingOccurrences(of: word, with: "")
    }

    /// "%@", "%lld", "%1$@" ... reduced to their conversion ("@", "lld"), sorted,
    /// because a translation may reorder positional arguments.
    private static func formatSpecifiers(in string: String) -> [String] {
        let regex = /%(?:\d+\$)?(lld|ld|d|@|f|%)/
        return string.matches(of: regex).map { String($0.output.1) }.filter { $0 != "%" }.sorted()
    }
}

/// Reads a .xcstrings file from the source tree.
private struct StringCatalog {
    let strings: [String: [String: Any]]

    init(named name: String) throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // App
            .deletingLastPathComponent() // NativeAppTemplateTests
            .deletingLastPathComponent() // repository root
            .appendingPathComponent("NativeAppTemplate")
            .appendingPathComponent(name)
        let data = try Data(contentsOf: url)
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        strings = try #require(json["strings"] as? [String: [String: Any]])
    }

    /// Japanese value per key, for keys whose Japanese is a plain string unit
    var japaneseValues: [(String, String)] {
        strings.compactMap { key, entry in
            guard let unit = Self.japanese(of: entry)?["stringUnit"] as? [String: Any],
                  let value = unit["value"] as? String else { return nil }
            return (key, value)
        }
    }

    var keysMissingJapanese: [String] {
        strings.compactMap { key, entry in
            if entry["shouldTranslate"] as? Bool == false { return nil }
            guard let japanese = Self.japanese(of: entry), Self.isTranslated(japanese) else { return key }
            return nil
        }.sorted()
    }

    private static func japanese(of entry: [String: Any]) -> [String: Any]? {
        (entry["localizations"] as? [String: Any])?["ja"] as? [String: Any]
    }

    /// A string unit, or every case of a plural/device variation, is translated and non-empty
    private static func isTranslated(_ localization: [String: Any]) -> Bool {
        if let unit = localization["stringUnit"] as? [String: Any] {
            return unit["state"] as? String == "translated" && !((unit["value"] as? String) ?? "").isEmpty
        }
        if let variations = localization["variations"] as? [String: [String: [String: Any]]] {
            let cases = variations.values.flatMap(\.values)
            return !cases.isEmpty && cases.allSatisfy(isTranslated)
        }
        return false
    }
}
