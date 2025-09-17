import Foundation

public enum IconSource: String, Codable, Sendable {
    case systemSymbol
    case remoteURL
}

public struct IconReference: Codable, Equatable, Sendable {
    public var source: IconSource
    public var value: String

    public init(source: IconSource, value: String) {
        self.source = source
        self.value = value
    }

    public static func system(_ name: String) -> IconReference {
        IconReference(source: .systemSymbol, value: name)
    }

    public static func remote(_ url: URL) -> IconReference {
        IconReference(source: .remoteURL, value: url.absoluteString)
    }

    public var remoteURL: URL? {
        guard source == .remoteURL else { return nil }
        return URL(string: value)
    }
}
