import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable, Identifiable {
    var id: String           // Firebase UID or "guest"
    var displayName: String
    var email: String
    var avatarEmoji: String
    var isGuest: Bool
    var joinDate: Date
    var totalProjectsCreated: Int

    static var guestProfile: UserProfile {
        UserProfile(
            id: "guest",
            displayName: "Guest User",
            email: "",
            avatarEmoji: "👤",
            isGuest: true,
            joinDate: Date(),
            totalProjectsCreated: 0
        )
    }
}

struct LoadedConfig {
    var mode: String?
    var isFirstLaunch: Bool
    var tracking: [String: String]
    var navigation: [String: String]
    var permissions: PermissionData
    
    struct PermissionData {
        var approved: Bool
        var declined: Bool
        var lastAsked: Date?
    }
}

// MARK: - Project
struct Project: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var area: Double
    var totalBudget: Double
    var startDate: Date
    var endDate: Date?
    var address: String
    var notes: String
    var coverEmoji: String = "🏗️"
    var statusTag: ProjectStatus = .active
    var priority: ProjectPriority = .medium
}

enum ProjectStatus: String, Codable, CaseIterable {
    case planning   = "Planning"
    case active     = "Active"
    case onHold     = "On Hold"
    case completed  = "Completed"

    var colorHex: String {
        switch self {
        case .planning:  return "8E8E93"
        case .active:    return "F5B800"
        case .onHold:    return "FF9500"
        case .completed: return "34C759"
        }
    }
    var icon: String {
        switch self {
        case .planning:  return "clock"
        case .active:    return "bolt.fill"
        case .onHold:    return "pause.fill"
        case .completed: return "checkmark.seal.fill"
        }
    }
}

enum ProjectPriority: String, Codable, CaseIterable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var colorHex: String {
        switch self {
        case .low:    return "4ECDC4"
        case .medium: return "F5B800"
        case .high:   return "FF6B6B"
        }
    }
}

// MARK: - Stage
struct BuildStage: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var colorHex: String
    var tasks: [StageTask]
    var deadline: Date?
    var notes: String
    var photos: [String]
    var order: Int
    var estimatedCost: Double = 0
    var actualCost: Double    = 0

    var completionPercent: Double {
        guard !tasks.isEmpty else { return 0 }
        let done = tasks.filter { $0.isDone }.count
        return Double(done) / Double(tasks.count) * 100
    }

    var status: StageStatus {
        if completionPercent == 100 { return .done }
        if completionPercent > 0    { return .inProgress }
        if let d = deadline, d < Date() { return .overdue }
        return .pending
    }
}

enum StageStatus {
    case pending, inProgress, done, overdue

    var label: String {
        switch self {
        case .pending:    return "Pending"
        case .inProgress: return "In Progress"
        case .done:       return "Done"
        case .overdue:    return "Overdue"
        }
    }
    var colorHex: String {
        switch self {
        case .pending:    return "8E8E93"
        case .inProgress: return "F5B800"
        case .done:       return "34C759"
        case .overdue:    return "FF6B6B"
        }
    }
}

struct StageTask: Codable, Identifiable {
    var id: UUID     = UUID()
    var title: String
    var isDone: Bool = false
    var note: String = ""
    var priority: TaskPriority = .normal
}

enum TaskPriority: String, Codable, CaseIterable {
    case normal  = "Normal"
    case high    = "High"
    case urgent  = "Urgent"

    var colorHex: String {
        switch self {
        case .normal: return "8E8E93"
        case .high:   return "F5B800"
        case .urgent: return "FF6B6B"
        }
    }
    var icon: String {
        switch self {
        case .normal: return "minus"
        case .high:   return "arrow.up"
        case .urgent: return "exclamationmark.2"
        }
    }
}

// MARK: - Material
struct Material: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var quantity: Double
    var unit: MaterialUnit
    var pricePerUnit: Double
    var supplier: String
    var status: MaterialStatus
    var stageId: UUID?
    var notes: String
    var orderDate: Date?

    var totalCost: Double { quantity * pricePerUnit }
}

enum MaterialUnit: String, Codable, CaseIterable {
    case pcs  = "pcs"
    case m2   = "m²"
    case m3   = "m³"
    case m    = "m"
    case kg   = "kg"
    case l    = "l"
    case bags = "bags"
    case ton  = "ton"
}

enum MaterialStatus: String, Codable, CaseIterable {
    case planned   = "Planned"
    case ordered   = "Ordered"
    case delivered = "Delivered"
    case used      = "Used"

    var color: String {
        switch self {
        case .planned:   return "8E8E93"
        case .ordered:   return "F5B800"
        case .delivered: return "4ECDC4"
        case .used:      return "34C759"
        }
    }
}

// MARK: - Expense
struct Expense: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var stageId: UUID?
    var notes: String
    var receiptNote: String = ""
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case materials = "Materials"
    case labor     = "Labor"
    case equipment = "Equipment"
    case permits   = "Permits"
    case other     = "Other"

    var icon: String {
        switch self {
        case .materials: return "cube.box.fill"
        case .labor:     return "person.2.fill"
        case .equipment: return "wrench.and.screwdriver.fill"
        case .permits:   return "doc.text.fill"
        case .other:     return "ellipsis.circle.fill"
        }
    }
    var colorHex: String {
        switch self {
        case .materials: return "F5B800"
        case .labor:     return "FF6B6B"
        case .equipment: return "4ECDC4"
        case .permits:   return "A8E063"
        case .other:     return "8E8E93"
        }
    }
}

// MARK: - Worker
struct Worker: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var specialization: String
    var dailyRate: Double
    var rating: Int
    var notes: String
    var workHistory: [WorkEntry]
    var isActive: Bool = true
    var avatarEmoji: String = "👷"
}

struct WorkEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var stageId: UUID?
    var stageName: String
    var startDate: Date
    var endDate: Date?
    var amount: Double
    var notes: String
}

// MARK: - Document
struct AppDocument: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: DocumentType
    var dateAdded: Date
    var notes: String
    var thumbnail: String?
}

enum DocumentType: String, Codable, CaseIterable {
    case contract  = "Contract"
    case blueprint = "Blueprint"
    case plan      = "Plan"
    case invoice   = "Invoice"
    case photo     = "Photo"
    case other     = "Other"

    var icon: String {
        switch self {
        case .contract:  return "doc.text.fill"
        case .blueprint: return "map.fill"
        case .plan:      return "list.clipboard.fill"
        case .invoice:   return "banknote.fill"
        case .photo:     return "photo.fill"
        case .other:     return "doc.fill"
        }
    }
}

// MARK: - Activity Log (NEW)
struct ActivityLog: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var title: String
    var subtitle: String
    var icon: String
    var colorHex: String
    var category: ActivityCategory
}

enum ActivityCategory: String, Codable {
    case stage    = "Stage"
    case material = "Material"
    case expense  = "Expense"
    case worker   = "Worker"
    case project  = "Project"
}

// MARK: - Quick Note (NEW)
struct QuickNote: Codable, Identifiable {
    var id: UUID   = UUID()
    var text: String
    var date: Date = Date()
    var isPinned: Bool = false
    var colorHex: String = "F5B800"
}

// MARK: - Build Tip (NEW)
struct BuildTip: Identifiable {
    var id = UUID()
    var icon: String
    var title: String
    var body: String
    var category: String
    var colorHex: String

    static let all: [BuildTip] = [
        BuildTip(icon: "🧱", title: "Foundation First", body: "Always let concrete cure at least 28 days before loading walls. Rushing leads to settlement cracks.", category: "Foundation", colorHex: "8E8E93"),
        BuildTip(icon: "💧", title: "Waterproofing", body: "Apply waterproofing to basement walls before backfilling. Never skip this step.", category: "Foundation", colorHex: "4ECDC4"),
        BuildTip(icon: "⚡", title: "Cable Sizing", body: "Oversize your electrical conduits by 30%. Future upgrades will thank you.", category: "Electrical", colorHex: "F5B800"),
        BuildTip(icon: "🏠", title: "Roof Ventilation", body: "Add 1 sq ft of ventilation per 150 sq ft of attic space to prevent moisture buildup.", category: "Roof", colorHex: "FF6B6B"),
        BuildTip(icon: "🎨", title: "Prime Before Paint", body: "Always prime new plaster before painting. Skipping primer wastes 2x more paint.", category: "Finishing", colorHex: "A8E063"),
        BuildTip(icon: "📐", title: "Order Extra Tiles", body: "Buy 10–15% extra tiles for cuts and breakage. Dye lots change, so stock from one batch.", category: "Finishing", colorHex: "FF9500"),
        BuildTip(icon: "💰", title: "10% Reserve", body: "Always keep 10% of your budget as a contingency reserve. Unexpected costs are the norm in construction.", category: "Budget", colorHex: "34C759"),
        BuildTip(icon: "📸", title: "Document Everything", body: "Take photos of all pipes and cables before covering walls. You'll need them for future repairs.", category: "General", colorHex: "007AFF"),
    ]
}
