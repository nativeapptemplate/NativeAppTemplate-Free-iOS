//
//  MainTab.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/11/03.
//

import Foundation
import SwiftUI

enum MainTab {
  case shops
  case scan
  case settings
}

// MARK: - CaseIterable
extension MainTab: CaseIterable { }
