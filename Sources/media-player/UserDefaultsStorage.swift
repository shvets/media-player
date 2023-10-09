import Foundation

//@propertyWrapper
open class UserDefaultsStorage<T: Codable> {
  private let store: UserDefaults = .standard

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  var key: String

  // let value: T

  public init(_ key: String) {
    self.key = key
  }

  public func save(_ value: T) throws {
    let data = try encoder.encode(value)

    store.set(data, forKey: key)
  }

  public func load() throws -> T? {
    if let data = store.data(forKey: key), !data.isEmpty {
      return try decoder.decode(T.self, from: data)
    }

    return nil
  }

//    var wrappedValue: T {
//        get {
//            guard let data = store.data(forKey: key) else {
//                return value
//            }
//
//            let decoded = try? decoder.decode(T.self, from: data)
//
//            return decoded ?? value
//        }
//        nonmutating set {
//            let data = try? encoder.encode(newValue)
//
//            store.set(data, forKey: key)
//        }
//    }
}
