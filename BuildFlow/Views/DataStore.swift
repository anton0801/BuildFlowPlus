import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var project: Project = Project(
        name: "My House 88m²",
        area: 88,
        totalBudget: 150000,
        startDate: Date(),
        address: "",
        notes: ""
    )
    @Published var stages: [BuildStage]    = []
    @Published var materials: [Material]  = []
    @Published var expenses: [Expense]    = []
    @Published var workers: [Worker]      = []
    @Published var documents: [AppDocument] = []

    private let projectKey   = "bf_project"
    private let stagesKey    = "bf_stages"
    private let materialsKey = "bf_materials"
    private let expensesKey  = "bf_expenses"
    private let workersKey   = "bf_workers"
    private let documentsKey = "bf_documents"

    init() {
        load()
        if stages.isEmpty { seedDefaultStages() }
    }

    // MARK: - Computed
    var totalSpent: Double       { expenses.reduce(0) { $0 + $1.amount } }
    var budgetRemaining: Double  { project.totalBudget - totalSpent }
    var overallProgress: Double {
        guard !stages.isEmpty else { return 0 }
        return stages.reduce(0) { $0 + $1.completionPercent } / Double(stages.count)
    }
    var progressText: String { String(format: "%.0f%%", overallProgress) }

    // MARK: - Persistence
    func save() {
        encode(project,   key: projectKey)
        encode(stages,    key: stagesKey)
        encode(materials, key: materialsKey)
        encode(expenses,  key: expensesKey)
        encode(workers,   key: workersKey)
        encode(documents, key: documentsKey)
    }

    private func load() {
        if let p: Project          = decode(key: projectKey)   { project   = p }
        if let s: [BuildStage]     = decode(key: stagesKey)    { stages    = s }
        if let m: [Material]       = decode(key: materialsKey) { materials = m }
        if let e: [Expense]        = decode(key: expensesKey)  { expenses  = e }
        if let w: [Worker]         = decode(key: workersKey)   { workers   = w }
        if let d: [AppDocument]    = decode(key: documentsKey) { documents = d }
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func seedDefaultStages() {
        stages = [
            BuildStage(name: "Foundation", icon: "⛏️", colorHex: "8E8E93",
                       tasks: [StageTask(title: "Survey & marking"),
                                StageTask(title: "Excavation"),
                                StageTask(title: "Formwork"),
                                StageTask(title: "Reinforcement"),
                                StageTask(title: "Pouring concrete")],
                       notes: "", photos: [], order: 0),
            BuildStage(name: "Walls", icon: "🧱", colorHex: "F5B800",
                       tasks: [StageTask(title: "Block delivery"),
                                StageTask(title: "Lay first course"),
                                StageTask(title: "Window openings"),
                                StageTask(title: "Complete walls")],
                       notes: "", photos: [], order: 1),
            BuildStage(name: "Roof", icon: "🏠", colorHex: "FF6B6B",
                       tasks: [StageTask(title: "Roof trusses"),
                                StageTask(title: "Sheathing"),
                                StageTask(title: "Waterproofing"),
                                StageTask(title: "Roofing tiles")],
                       notes: "", photos: [], order: 2),
            BuildStage(name: "Electrical", icon: "⚡", colorHex: "4ECDC4",
                       tasks: [StageTask(title: "Cable routing"),
                                StageTask(title: "Distribution board"),
                                StageTask(title: "Sockets & switches"),
                                StageTask(title: "Testing")],
                       notes: "", photos: [], order: 3),
            BuildStage(name: "Finishing", icon: "🎨", colorHex: "A8E063",
                       tasks: [StageTask(title: "Plastering"),
                                StageTask(title: "Tiling"),
                                StageTask(title: "Painting"),
                                StageTask(title: "Flooring"),
                                StageTask(title: "Final details")],
                       notes: "", photos: [], order: 4),
        ]
        save()
    }

    // MARK: - Stage CRUD
    func addStage(_ s: BuildStage)    { stages.append(s); save() }
    func updateStage(_ s: BuildStage) {
        if let i = stages.firstIndex(where: { $0.id == s.id }) { stages[i] = s; save() }
    }
    func deleteStages(at offsets: IndexSet) { stages.remove(atOffsets: offsets); save() }

    // MARK: - Material CRUD
    func addMaterial(_ m: Material)    { materials.append(m); save() }
    func updateMaterial(_ m: Material) {
        if let i = materials.firstIndex(where: { $0.id == m.id }) { materials[i] = m; save() }
    }
    func deleteMaterials(at offsets: IndexSet) { materials.remove(atOffsets: offsets); save() }

    // MARK: - Expense CRUD
    func addExpense(_ e: Expense)    { expenses.append(e); save() }
    func updateExpense(_ e: Expense) {
        if let i = expenses.firstIndex(where: { $0.id == e.id }) { expenses[i] = e; save() }
    }
    func deleteExpenses(at offsets: IndexSet) { expenses.remove(atOffsets: offsets); save() }

    // MARK: - Worker CRUD
    func addWorker(_ w: Worker)    { workers.append(w); save() }
    func updateWorker(_ w: Worker) {
        if let i = workers.firstIndex(where: { $0.id == w.id }) { workers[i] = w; save() }
    }
    func deleteWorkers(at offsets: IndexSet) { workers.remove(atOffsets: offsets); save() }

    // MARK: - Document CRUD
    func addDocument(_ d: AppDocument)    { documents.append(d); save() }
    func deleteDocuments(at offsets: IndexSet) { documents.remove(atOffsets: offsets); save() }
}
