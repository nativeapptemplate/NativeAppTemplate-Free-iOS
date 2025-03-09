//
//  ShowTagInfoDetailView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI

struct ShowTagInfoScanResultView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  var showTagInfoScanResult: ShowTagInfoScanResult
  
  init(
    showTagInfoScanResult: ShowTagInfoScanResult
  ) {
    self.showTagInfoScanResult = showTagInfoScanResult
  }
  
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension ShowTagInfoScanResultView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      switch showTagInfoScanResult.type {
      case .succeeded:
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
    GroupBox(label: Label(String.tagInfo, systemImage: "rectangle") ) {
      VStack {
        if let itemTag = showTagInfoScanResult.itemTag {
          let scannedAt = showTagInfoScanResult.scannedAt
          let itemTagType = showTagInfoScanResult.itemTagType
          let isReadOnly = showTagInfoScanResult.isReadOnly
          let displayReadOnly = isReadOnly ? String.readOnly : String.writable
          
          let imageSize = 10.0
          
          Text(String(itemTag.queueNumber))
            .font(.uiTitle1)
            .foregroundStyle(itemTagType == .server ? .red : .blue)
          HStack(alignment: .firstTextBaseline) {
            Text(String(scannedAt.cardTimeAgoInWordsDateString))
              .font(.uiBodyCustom)
              .foregroundStyle(.coloredSecondaryFootnoteText)
            Text(verbatim: "show tag info scanned")
              .font(.uiFootnote)
              .foregroundStyle(.coloredSecondaryFootnoteText)
          }
          
          Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 8) {
            GridRow {
              Image(systemName: "storefront")
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.coloredSecondaryFootnoteText)
              Text(itemTag.shopName)
                .font(.uiLabelBold)
              Text(" ")
                .font(.uiFootnote)
                .foregroundStyle(.coloredSecondaryFootnoteText)
            }
            GridRow {
              Image(systemName: "info.circle")
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.coloredSecondaryFootnoteText)
              Text(itemTagType.displayString)
                .font(.uiLabelBold)
                .foregroundStyle(itemTagType == .server ? .red : .blue)
              Text(verbatim: "tag type")
                .font(.uiFootnote)
                .foregroundStyle(.coloredSecondaryFootnoteText)
            }
            GridRow {
              Image(systemName: "flag.checkered")
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.coloredSecondaryFootnoteText)
              if itemTag.state == .completed {
                CompletedTag()
              } else {
                IdlingTag()
              }
              Text(verbatim: "tag status")
                .font(.uiFootnote)
                .foregroundStyle(.coloredSecondaryFootnoteText)
            }
            
            if itemTag.scanState == ScanState.scanned && itemTag.customerReadAt != nil {
              GridRow {
                Image(systemName: "person.2")
                  .frame(width: imageSize, height: imageSize)
                  .foregroundStyle(.coloredSecondaryFootnoteText)
                Text(itemTag.customerReadAt!.cardTimeString)
                  .font(.uiLabelBold)
                Text(verbatim: "scanned by a customer")
                  .font(.uiFootnote)
                  .foregroundStyle(.coloredSecondaryFootnoteText)
              }
            }
            
            if itemTag.state == ItemTagState.completed && itemTag.completedAt != nil {
              GridRow {
                Image(systemName: "flag.checkered.circle")
                  .frame(width: imageSize, height: imageSize)
                  .foregroundStyle(.coloredSecondaryFootnoteText)
                Text(itemTag.completedAt!.cardTimeString)
                  .font(.uiLabelBold)
                Text(verbatim: "completed")
                  .font(.uiFootnote)
                  .foregroundStyle(.coloredSecondaryFootnoteText)
              }
            }
            
            GridRow {
              Image(systemName: "rectangle")
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.coloredSecondaryFootnoteText)
              Text(displayReadOnly)
                .font(.uiLabelBold)
              Text(verbatim: "NFC tag")
                .font(.uiFootnote)
                .foregroundStyle(.coloredSecondaryFootnoteText)
            }
            GridRow {
              Image(systemName: "clock")
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.coloredSecondaryFootnoteText)
              Text(itemTag.createdAt.cardDateString)
                .font(.uiLabelBold)
              Text(verbatim: "created")
                .font(.uiFootnote)
                .foregroundStyle(.coloredSecondaryFootnoteText)
            }
          }
        }
      }
    }
    .foregroundStyle(.coloredSecondaryForeground)
    .backgroundStyle(.coloredSecondaryBackground)
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
  
  @ViewBuilder var failedView: some View {
    GroupBox(label: Label(String("Error"), systemImage: "exclamationmark.triangle") ) {
      Text(showTagInfoScanResult.message)
        .padding(.top)
    }
    .backgroundStyle(.failureBackground)
  }
  
  @ViewBuilder var idledView: some View {
    GroupBox(label: Label(String.tagInfo, systemImage: "rectangle") ) {
    }
    .foregroundStyle(.coloredSecondaryForeground)
    .backgroundStyle(.coloredSecondaryBackground)
  }
}
