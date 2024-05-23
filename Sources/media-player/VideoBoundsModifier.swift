import Foundation
import SwiftUI
import AVKit

public struct VideoBoundsModifier: ViewModifier {
  public init() {}
    
  public func body(content: Content) -> some View {
    content
#if os(iOS) || os(tvOS)
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .top)
#endif
  }
}
