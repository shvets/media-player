import Foundation

public protocol PlayerNavigator {
  @discardableResult func next() -> Bool

  @discardableResult func previous() -> Bool
}