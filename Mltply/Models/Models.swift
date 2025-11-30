import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var isTypingIndicator: Bool = false
    var tapback: Tapback? = nil
    var accessibilityIdentifier: String? = nil
}

enum Tapback: String {
    case correct, incorrect
}

enum MathOperation: String, Codable {
    case addition = "addition"
    case subtraction = "subtraction"
    case multiplication = "multiplication"
    case division = "division"
}

struct MathQuestion {
    let question: String
    let answer: Int
    let firstNumber: Int
    let secondNumber: Int
    let operation: MathOperation
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

public enum QuestionMode: String, CaseIterable, Identifiable {
    case random = "random"
    case sequential = "Ascending"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .random: return "Random"
        case .sequential: return "Ascending"
        }
    }

    public var iconName: String {
        switch self {
        case .random: return "shuffle"
        case .sequential: return "arrow.up.arrow.down"
        }
    }
}

struct PracticeSettings: Equatable {
    var selectedNumbers: Set<Int> = Set(1...12)  // All numbers 1-12 selected by default
    var currentNumberIndex: Int = 0
    var currentMultiplier: Int = 1

    private var sortedNumbers: [Int] {
        selectedNumbers.sorted()
    }

    var currentNumber: Int {
        guard !sortedNumbers.isEmpty else { return 1 }
        return sortedNumbers[currentNumberIndex % sortedNumbers.count]
    }

    var hasSelectedNumbers: Bool {
        !selectedNumbers.isEmpty
    }

    mutating func nextQuestion() {
        if currentMultiplier < 12 {
            currentMultiplier += 1
        } else {
            // Move to next number
            currentMultiplier = 1
            if !sortedNumbers.isEmpty {
                currentNumberIndex = (currentNumberIndex + 1) % sortedNumbers.count
            }
        }
    }

    mutating func reset() {
        currentMultiplier = 1
        currentNumberIndex = 0
    }

    mutating func toggleNumber(_ number: Int) {
        if selectedNumbers.contains(number) {
            selectedNumbers.remove(number)
        } else {
            selectedNumbers.insert(number)
        }
        // Reset to first number when selection changes
        reset()
    }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case light, dark, system
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
    var iconName: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

enum AppIcon: String, CaseIterable, Identifiable {
    case `default` = "AppIcon"
    case original = "AppIconOG"
    case glass = "mltply"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default: return "Default"
        case .original: return "Original"
        case .glass: return "Glass"
        }
    }

    var iconName: String? {
        switch self {
        case .default: return nil // Primary app icon
        case .original: return "AppIconOG"
        case .glass: return "mltply"
        }
    }
    
    var systemIconName: String {
        switch self {
        case .default: return "sun.max" // Light theme icon for default
        case .original: return "moon" // Dark theme icon for original
        case .glass: return "cube.transparent" // Glass icon for iOS 26+
        }
    }
    
    /// Whether this icon requires iOS 26+ (glass icons)
    var requiresIOS26: Bool {
        switch self {
        case .glass: return true
        default: return false
        }
    }
}
