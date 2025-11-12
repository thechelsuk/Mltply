import Foundation
import SwiftUI

enum AchievementType: String, Codable {
    case streak
    case numberMastery
    case totalCorrect
}

struct Achievement: Codable, Identifiable {
    let id: String
    let type: AchievementType
    let title: String
    let description: String
    let iconName: String
    let color: String // Store as hex string for Codable
    let requirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    // For number mastery achievements
    var number: Int?
    var operation: MathOperation?
    
    var pastelColor: Color {
        Color(hex: color) ?? .gray
    }
}

class AchievementsManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    private let achievementsKey = "MltplyAchievements"
    
    init() {
        initializeAchievements()
        loadAchievements()
    }
    
    private func initializeAchievements() {
        var defaultAchievements: [Achievement] = []
        
        // Streak achievements
        let streakMilestones = [
            (5, "On Fire", "🔥", "FFB3BA"),
            (10, "Hot Streak", "⚡️", "FFDFBA"),
            (20, "Unstoppable", "💫", "FFFFBA"),
            (50, "Legendary", "⭐️", "BAFFC9"),
            (100, "Math Master", "👑", "BAE1FF")
        ]
        
        for (count, title, icon, color) in streakMilestones {
            defaultAchievements.append(Achievement(
                id: "streak_\(count)",
                type: .streak,
                title: title,
                description: "Get \(count) correct answers in a row",
                iconName: icon,
                color: color,
                requirement: count,
                isUnlocked: false
            ))
        }
        
        // Total correct achievements
        let totalMilestones = [
            (10, "Getting Started", "star.fill", "E0BBE4"),
            (25, "Quick Learner", "star.circle.fill", "D4A5A5"),
            (50, "Dedicated", "rosette", "FFDFD3"),
            (100, "Committed", "medal.fill", "C5E1A5"),
            (250, "Expert", "crown.fill", "FFE0B2"),
            (500, "Genius", "sparkles", "B2DFDB"),
            (1000, "Legend", "flame.fill", "FFCCBC")
        ]
        
        for (count, title, icon, color) in totalMilestones {
            defaultAchievements.append(Achievement(
                id: "total_\(count)",
                type: .totalCorrect,
                title: title,
                description: "Answer \(count) questions correctly",
                iconName: icon,
                color: color,
                requirement: count,
                isUnlocked: false
            ))
        }
        
        // Number mastery achievements - one for each number (1-12) and operation
        let operations: [(MathOperation, String, String)] = [
            (.addition, "Addition", "plus.circle.fill"),
            (.subtraction, "Subtraction", "minus.circle.fill"),
            (.multiplication, "Multiplication", "multiply.circle.fill"),
            (.division, "Division", "divide.circle.fill")
        ]
        
        let pastelColors = ["B5EAD7", "FFDAC1", "C7CEEA", "FFB7B2", "E2F0CB", "FDE2E4", "CAFFBF", "9BF6FF", "A0C4FF", "BDB2FF", "FFC6FF", "FDFFB6"]
        
        for number in 1...12 {
            for (operation, opName, icon) in operations {
                let colorIndex = ((number - 1) * 4 + operations.firstIndex(where: { $0.0 == operation })!) % pastelColors.count
                defaultAchievements.append(Achievement(
                    id: "number_\(number)_\(operation.rawValue)",
                    type: .numberMastery,
                    title: "\(number) \(opName) Master",
                    description: "Complete all \(number) \(opName.lowercased()) problems",
                    iconName: icon,
                    color: pastelColors[colorIndex],
                    requirement: 12,
                    isUnlocked: false,
                    number: number,
                    operation: operation
                ))
            }
        }
        
        // Only initialize if no achievements exist
        if achievements.isEmpty {
            achievements = defaultAchievements
        } else {
            // Merge new achievements with existing ones
            for newAchievement in defaultAchievements {
                if !achievements.contains(where: { $0.id == newAchievement.id }) {
                    achievements.append(newAchievement)
                }
            }
        }
    }
    
    func checkAndUnlockAchievements(questionHistory: QuestionHistory) {
        var hasChanges = false
        
        for index in achievements.indices {
            guard !achievements[index].isUnlocked else { continue }
            
            var shouldUnlock = false
            
            switch achievements[index].type {
            case .streak:
                shouldUnlock = questionHistory.longestStreak >= achievements[index].requirement
                
            case .totalCorrect:
                shouldUnlock = questionHistory.totalCorrect >= achievements[index].requirement
                
            case .numberMastery:
                if let number = achievements[index].number,
                   let operation = achievements[index].operation {
                    shouldUnlock = questionHistory.hasCompletedNumber(number, operation: operation)
                }
            }
            
            if shouldUnlock {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                hasChanges = true
            }
        }
        
        if hasChanges {
            saveAchievements()
        }
    }
    
    func clearAllAchievements() {
        for index in achievements.indices {
            achievements[index].isUnlocked = false
            achievements[index].unlockedDate = nil
        }
        saveAchievements()
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    var streakAchievements: [Achievement] {
        achievements.filter { $0.type == .streak }
    }
    
    var totalAchievements: [Achievement] {
        achievements.filter { $0.type == .totalCorrect }
    }
    
    var masteryAchievements: [Achievement] {
        achievements.filter { $0.type == .numberMastery }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
    }
}

// Helper extension for Color from hex string
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
