import Foundation
import SwiftUI
import AVKit

public struct VideoBoundsModifier: ViewModifier {
  public init() {}
    
  public func body(content: Content) -> some View {
    content
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .top)
  }
}
