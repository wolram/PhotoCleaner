import Foundation

enum AppConfig {
    static let appName = "Snap Sieve"
    static let appVersion = "1.0.0"

    enum Thresholds {
        static let defaultDuplicateDistance: Float = 0.5
        static let defaultSimilarityHammingDistance: Int = 8
        static let defaultQualityThreshold: Float = 0.3
        static let minDuplicateDistance: Float = 0.3
        static let maxDuplicateDistance: Float = 0.7
    }

    enum Processing {
        static let maxConcurrentTasks = 8
        static let batchSize = 100
        static let thumbnailSize = CGSize(width: 200, height: 200)
        static let analysisImageSize = CGSize(width: 512, height: 512)
        static let memoryWarningThreshold: UInt64 = 500_000_000 // 500MB
    }

    enum Categories {
        static let predefined: [String] = [
            "Nature & Landscapes",
            "Portraits & People",
            "Food & Drinks",
            "Architecture & Buildings",
            "Animals & Pets",
            "Travel & Vacation",
            "Events & Celebrations",
            "Art & Design",
            "Sports & Action",
            "Documents & Screenshots"
        ]

        static let categoryPrompts: [String: String] = [
            "Nature & Landscapes": "a photo of nature, landscape, mountains, forest, beach, sunset, sky",
            "Portraits & People": "a photo of a person, portrait, selfie, group photo, people",
            "Food & Drinks": "a photo of food, meal, drink, restaurant, cooking",
            "Architecture & Buildings": "a photo of a building, architecture, house, city, street",
            "Animals & Pets": "a photo of an animal, pet, dog, cat, bird, wildlife",
            "Travel & Vacation": "a photo from travel, vacation, tourist attraction, landmark",
            "Events & Celebrations": "a photo of an event, party, celebration, wedding, birthday",
            "Art & Design": "a photo of art, design, painting, drawing, creative work",
            "Sports & Action": "a photo of sports, action, exercise, game, athletic activity",
            "Documents & Screenshots": "a screenshot, document, text, receipt, note"
        ]
    }

    enum UI {
        static let sidebarWidth: CGFloat = 220
        static let gridItemMinSize: CGFloat = 120
        static let gridItemMaxSize: CGFloat = 200
        static let gridSpacing: CGFloat = 2
        static let animationDuration: Double = 0.3
    }
}
