// Copyright (c) 2020 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI

struct ErrorView {
  private var titleText = "Something went wrong."
  private var bodyText = "Please try again."
  private var buttonTitle = "Reload"
  private var buttonAction: () -> Void
  
  init(
    buttonAction: @escaping () -> Void,
    titleText: String = "Something went wrong.",
    bodyText: String = "Please try again.",
    buttonTitle: String = "Reload"
  ) {
    self.titleText = titleText
    self.bodyText = bodyText
    self.buttonTitle = buttonTitle
    self.buttonAction = buttonAction
  }
}

// MARK: - View {
extension ErrorView: View {
  var body: some View {
    ZStack {
      VStack {
        Spacer()
        
        Image(systemName: "exclamationmark.triangle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 96)
          .padding()
          .foregroundStyle(.titleText)
        
        Text(titleText)
          .font(.uiTitle1)
          .foregroundStyle(.titleText)
          .padding(.top)
        
        Text(bodyText)
          .font(.uiLabel)
          .foregroundStyle(.contentText)
          .multilineTextAlignment(.center)
          .padding(.top, 4)
        
        MainButtonView(
          title: buttonTitle,
          type: .primary(withArrow: false),
          callback: buttonAction)
        .padding(32)
        
        Spacer()
      }
      .background(Color.backgroundColor)
    }
  }
}

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(buttonAction: {}).inAllColorSchemes
  }
}
