import Foundation

public struct MediaSource {
  public var url: URL?
  public var name: String?
  public var id: Int?

  public init(url: URL?, name: String? = nil, id: Int? = nil) {
    self.url = url

    if let name = name {
      self.name = name
    }
    else if let url = url {
      self.name = url.absoluteString
    }

    self.id = id
  }
}