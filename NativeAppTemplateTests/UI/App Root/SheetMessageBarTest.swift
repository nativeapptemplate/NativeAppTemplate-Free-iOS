//
//  SheetMessageBarTest.swift
//  NativeAppTemplate
//

import Foundation
import Testing

/// The app's message bar is under a sheet, so a save that fails on a sheet (the API's 422
/// for a member's address on Send Invitation...) said nothing the user could see. Every
/// sheet puts the bar on its own content with `sheetMessageBar`.
struct SheetMessageBarTest {
    /// Reads the Swift sources on the Mac through #filePath, which a simulator can do and a
    /// device cannot (as LocalizationTest)
    static let canReadSources: Bool = {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }()

    @Test(.enabled(if: canReadSources, "Reads the Swift sources on the Mac"))
    func everySheetShowsTheMessageBar() throws {
        let uiDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // App Root
            .deletingLastPathComponent() // UI
            .deletingLastPathComponent() // NativeAppTemplateTests
            .deletingLastPathComponent() // repository root
            .appendingPathComponent("NativeAppTemplate/UI")
        let files = try #require(FileManager.default.enumerator(at: uiDirectory, includingPropertiesForKeys: nil))

        var sheets = 0
        var withoutBar: [String] = []
        for case let url as URL in files where url.pathExtension == "swift" {
            let lines = try String(contentsOf: url, encoding: .utf8).components(separatedBy: "\n")
            for (index, line) in lines.enumerated() where line.trimmingCharacters(in: .whitespaces) == ".sheet(" {
                // The call runs to the ")" at the same indentation
                let indent = String(line.prefix { $0 == " " })
                let end = lines[index...].firstIndex(of: indent + ")") ?? lines.count
                sheets += 1
                if !lines[index ..< end].contains(where: { $0.contains(".sheetMessageBar(") }) {
                    withoutBar.append("\(url.lastPathComponent):\(index + 1)")
                }
            }
        }

        #expect(sheets >= 3) // guards against reading the wrong (or an empty) folder
        #expect(withoutBar.isEmpty, "Sheets without sheetMessageBar: \(withoutBar)")
    }
}
