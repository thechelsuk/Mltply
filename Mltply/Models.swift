import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var tapback: Tapback? = nil
    var isTypingIndicator: Bool = false
}

enum Tapback: String {
    case correct, incorrect
}

struct MathQuestion {
    let question: String
    let answer: Int
}

struct MathOperationSettings: Equatable {
    var additionEnabled: Bool = true
    var subtractionEnabled: Bool = true
    var multiplicationEnabled: Bool = true
    var divisionEnabled: Bool = true

    var hasAtLeastOneEnabled: Bool {
        return additionEnabled || subtractionEnabled || multiplicationEnabled || divisionEnabled
    }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
