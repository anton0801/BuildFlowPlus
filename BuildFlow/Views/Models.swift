import Foundation

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

    var completionPercent: Double {
        guard !tasks.isEmpty else { return 0 }
        let done = tasks.filter { $0.isDone }.count
        return Double(done) / Double(tasks.count) * 100
    }
}

struct StageTask: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
    var note: String = ""
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

    var totalCost: Double { quantity * pricePerUnit }
}

enum MaterialUnit: String, Codable, CaseIterable {
    case pcs = "pcs"
    case m2 = "m²"
    case m3 = "m³"
    case m = "m"
    case kg = "kg"
    case l = "l"
    case bags = "bags"
}

enum MaterialStatus: String, Codable, CaseIterable {
    case planned = "Planned"
    case ordered = "Ordered"
    case delivered = "Delivered"
    case used = "Used"

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
