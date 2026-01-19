import Foundation

enum NavigationDestination: String, Hashable, CaseIterable, Identifiable {
    case library
    case scan
    case duplicates
    case similar
    case quality
    case sieve
    case categories

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .library: return "All Photos"
        case .scan: return "Scan"
        case .duplicates: return "Duplicates"
        case .similar: return "Similar"
        case .quality: return "Quality"
        case .sieve: return "Sieve Mode"
        case .categories: return "Categories"
        }
    }

    var icon: String {
        switch self {
        case .library: return "photo.on.rectangle"
        case .scan: return "magnifyingglass"
        case .duplicates: return "doc.on.doc"
        case .similar: return "square.stack.3d.up"
        case .quality: return "sparkles"
        case .sieve: return "gamecontroller"
        case .categories: return "folder"
        }
    }

    var section: Section {
        switch self {
        case .library, .scan: return .library
        case .duplicates, .similar, .quality, .sieve: return .cleanup
        case .categories: return .organize
        }
    }

    enum Section: String, CaseIterable {
        case library = "Library"
        case cleanup = "Cleanup"
        case organize = "Organize"

        var destinations: [NavigationDestination] {
            NavigationDestination.allCases.filter { $0.section == self }
        }
    }

    static var grouped: [(Section, [NavigationDestination])] {
        Section.allCases.map { section in
            (section, section.destinations)
        }
    }
}
