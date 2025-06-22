//
//  ScanView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import SwiftUI
import CoreNFC

enum ScanType: String {
  case completeScan
  case test

  var displayString: String {
    switch self {
    case .completeScan:
      return "Complete Scan"
    case .test:
      return "Test"
    }
  }
}

// MARK: - CaseIterable
extension ScanType: CaseIterable {
  var index: Self.AllCases.Index {
    get {
      Self.allCases.firstIndex(of: self)!
    }
    set {
      self = Self.allCases[newValue]
    }
  }

  var count: Int {
    Self.allCases.count
  }
}

// MARK: - Identifiable
extension ScanType: Identifiable {
  var id: Self { self }
}

struct ScanView: View {
  @Environment(\.sessionController) private var sessionController: SessionControllerProtocol
  @StateObject private var nfcManager = appSingletons.nfcManager
  @State private var viewModel: ScanViewModel

  init(viewModel: ScanViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    contentView
      .onChange(of: sessionController.didBackgroundTagReading) {
        viewModel.handleBackgroundTagReading()
      }
  }
}

// MARK: - private
private extension ScanView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
        LoadingView()
      } else {
        scanView
          .onChange(of: nfcManager.isScanResultChanged) {
            viewModel.handleScanResultChanged()
          }
          .onChange(of: nfcManager.isScanResultChangedForTesting) {
            viewModel.handleScanResultChangedForTesting()
          }
      }
    }

    return contentView
  }

  var scanView: some View {
    ScrollView {
      VStack(spacing: 64) {
        switch viewModel.scanType {
        case .completeScan:
          if !viewModel.isShowingResetConfirmationDialog {
            GroupBox(label: Label(String.completeScan, systemImage: "flag.checkered") ) {
              MainButtonView(title: String.scan, type: .coloredPrimary(withArrow: false)) {
                viewModel.startCompleteScan()
              }
               .padding()

              Text(String.completeScanHelp)
                .font(.uiFootnote)
                .foregroundStyle(.coloredPrimaryFootnoteText)
            }
            .foregroundStyle(.coloredPrimaryForeground)
            .backgroundStyle(.coloredPrimaryBackground)
          }

          CompleteScanResultView(
            completeScanResult: sessionController.completeScanResult
          )
        case .test:
          GroupBox(label: Label(String.showTagInfoScan, systemImage: "info.circle") ) {
            MainButtonView(title: String.scan, type: .coloredSecondary(withArrow: false)) {
              viewModel.startTestScan()
            }
            .padding()

            Text(String.showTagInfoScanHelp)
              .font(.uiFootnote)
              .foregroundStyle(.coloredSecondaryFootnoteText)
          }
          .foregroundStyle(.coloredSecondaryForeground)
          .backgroundStyle(.coloredSecondaryBackground)

          ShowTagInfoScanResultView(
            showTagInfoScanResult: sessionController.showTagInfoScanResult
          )
        }

        Spacer()
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Picker(String("ScanType"), selection: $viewModel.scanType) {
          Text(String.completeScan).tag(ScanType.completeScan)
          Text(String.showTagInfoScan).tag(ScanType.test)
        }
        .pickerStyle(SegmentedPickerStyle())
      }
    }
    .toolbarBackground(.black, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .padding()
    .confirmationDialog(
      String.itemTagAlreadyCompleted,
      isPresented: $viewModel.isShowingResetConfirmationDialog
    ) {
      Button(String.reset, role: .destructive) {
        viewModel.resetTag()
      }
      Button(String.cancel, role: .cancel) {
        viewModel.dismissResetConfirmationDialog()
      }
    } message: {
      Text(String.areYouSure)
    }
    .accessibility(identifier: "scanView")
    .scrollContentBackground(.hidden)
  }
}
