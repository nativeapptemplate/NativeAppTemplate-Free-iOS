//
//  CompleteScanResultView.swift
//  NativeAppTemplate
//

import SwiftUI

struct CompleteScanResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MessageBus.self) private var messageBus
    var completeScanResult: CompleteScanResult

    var body: some View {
        contentView
    }
}

// MARK: - private

private extension CompleteScanResultView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            switch completeScanResult.type {
            case .completed, .reset:
                succeededView
            case .failed:
                failedView
            case .idled:
                idledView
            }
        }

        return contentView
    }

    @ViewBuilder var succeededView: some View {
        if let itemTag = completeScanResult.itemTag {
            GroupBox(label: Label(String("Result"), systemImage: "checkmark.circle")) {
                Text(String(itemTag.queueNumber))
                    .font(.uiTitle1)

                if itemTag.state == .completed {
                    CompletedTag()
                } else {
                    IdlingTag()
                }

                if completeScanResult.type == .reset {
                    Text(completeScanResult.type.displayString)
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(completeScanResult.scannedAt.cardTimeAgoInWordsDateString)
                        .font(.uiBodyCustom)
                        .foregroundStyle(.successSecondaryForeground)
                    Text(verbatim: "complete scanned")
                        .font(.uiFootnote)
                        .foregroundStyle(.successSecondaryForeground)
                }
                .padding(.top, NativeAppTemplateConstants.Spacing.xxs)
            }
            .backgroundStyle(.ultraThinMaterial)
        }
    }

    var failedView: some View {
        GroupBox(label: Label(String("Error"), systemImage: "exclamationmark.triangle")) {
            Text(completeScanResult.message)
                .padding(.top, NativeAppTemplateConstants.Spacing.xxs)
        }
        .foregroundStyle(.validationError)
        .backgroundStyle(.ultraThinMaterial)
    }

    var idledView: some View {
        GroupBox(label: Label(String("Result"), systemImage: "checkmark.circle")) {}
            .backgroundStyle(.ultraThinMaterial)
    }
}
