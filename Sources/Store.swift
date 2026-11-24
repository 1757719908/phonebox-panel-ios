import Foundation

enum Store {
    private static let urlKey = "pb.url"
    private static let alwaysOnKey = "pb.alwaysOn"
    private static let hideStatusKey = "pb.hideStatus"

    static var urlString: String? {
        get { UserDefaults.standard.string(forKey: urlKey) }
        set {
            if let v = newValue, !v.isEmpty {
                UserDefaults.standard.set(v, forKey: urlKey)
            } else {
                UserDefaults.standard.removeObject(forKey: urlKey)
            }
        }
    }

    static var alwaysOn: Bool {
        get { UserDefaults.standard.object(forKey: alwaysOnKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: alwaysOnKey) }
    }

    static var hideStatusBar: Bool {
        get { UserDefaults.standard.object(forKey: hideStatusKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: hideStatusKey) }
    }

    static func normalizedURL(from raw: String) -> URL? {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        if !s.lowercased().hasPrefix("http://") && !s.lowercased().hasPrefix("https://") {
            s = "http://" + s
        }
        return URL(string: s)
    }
}
