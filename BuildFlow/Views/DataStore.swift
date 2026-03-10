import Foundation
import Combine

class DataStore: ObservableObject {

    // MARK: - Published data
    @Published var project: Project = Project(
        name: "My House 88m²", area: 88, totalBudget: 150000,
        startDate: Date(), address: "", notes: ""
    )
    @Published var stages:      [BuildStage]    = []
    @Published var materials:   [Material]      = []
    @Published var expenses:    [Expense]       = []
    @Published var workers:     [Worker]        = []
    @Published var documents:   [AppDocument]   = []
    @Published var activityLog: [ActivityLog]   = []
    @Published var quickNotes:  [QuickNote]     = []

    // MARK: - User-scoped keys
    private var uid: String = "local"

    private var projectKey:   String { "bf_\(uid)_project"  }
    private var stagesKey:    String { "bf_\(uid)_stages"   }
    private var materialsKey: String { "bf_\(uid)_materials"}
    private var expensesKey:  String { "bf_\(uid)_expenses" }
    private var workersKey:   String { "bf_\(uid)_workers"  }
    private var documentsKey: String { "bf_\(uid)_documents"}
    private var activityKey:  String { "bf_\(uid)_activity" }
    private var notesKey:     String { "bf_\(uid)_notes"    }

    init() { }

    // Call after login to scope data to user
    func configure(userId: String) {
        uid = userId
        load()
        if stages.isEmpty { seedDefaultStages() }
    }

    // MARK: - Computed
    var totalSpent: Double      { expenses.reduce(0) { $0 + $1.amount } }
    var budgetRemaining: Double { project.totalBudget - totalSpent }
    var overallProgress: Double {
        guard !stages.isEmpty else { return 0 }
        return stages.reduce(0) { $0 + $1.completionPercent } / Double(stages.count)
    }
    var progressText: String    { String(format: "%.0f%%", overallProgress) }

    var materialsTotal: Double  { materials.reduce(0) { $0 + $1.totalCost } }

    var currentStage: BuildStage? {
        stages.sorted { $0.order < $1.order }.first { $0.completionPercent < 100 }
    }

    var upcomingDeadlines: [BuildStage] {
        let soon = Date().addingTimeInterval(7 * 86400)
        return stages.filter {
            guard let d = $0.deadline else { return false }
            return d >= Date() && d <= soon && $0.completionPercent < 100
        }.sorted { ($0.deadline ?? Date()) < ($1.deadline ?? Date()) }
    }

    var recentActivity: [ActivityLog] {
        Array(activityLog.sorted { $0.date > $1.date }.prefix(20))
    }

    // MARK: - Persistence
    func save() {
        encode(project,      key: projectKey)
        encode(stages,       key: stagesKey)
        encode(materials,    key: materialsKey)
        encode(expenses,     key: expensesKey)
        encode(workers,      key: workersKey)
        encode(documents,    key: documentsKey)
        encode(activityLog,  key: activityKey)
        encode(quickNotes,   key: notesKey)
    }

    func load() {
        if let p: Project          = decode(key: projectKey)   { project      = p }
        if let s: [BuildStage]     = decode(key: stagesKey)    { stages       = s }
        if let m: [Material]       = decode(key: materialsKey) { materials    = m }
        if let e: [Expense]        = decode(key: expensesKey)  { expenses     = e }
        if let w: [Worker]         = decode(key: workersKey)   { workers      = w }
        if let d: [AppDocument]    = decode(key: documentsKey) { documents    = d }
        if let a: [ActivityLog]    = decode(key: activityKey)  { activityLog  = a }
        if let n: [QuickNote]      = decode(key: notesKey)     { quickNotes   = n }
    }

    private func encode<T: Encodable>(_ v: T, key: String) {
        if let data = try? JSONEncoder().encode(v) { UserDefaults.standard.set(data, forKey: key) }
    }
    private func decode<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Activity Logger
    private func log(title: String, subtitle: String, icon: String, color: String, cat: ActivityCategory) {
        let entry = ActivityLog(date: Date(), title: title, subtitle: subtitle,
                                icon: icon, colorHex: color, category: cat)
        activityLog.insert(entry, at: 0)
        if activityLog.count > 100 { activityLog = Array(activityLog.prefix(100)) }
        encode(activityLog, key: activityKey)
    }

    // MARK: - Seed
    private func seedDefaultStages() {
        stages = [
            BuildStage(name: "Foundation", icon: "⛏️", colorHex: "8E8E93",
                tasks: [StageTask(title: "Survey & marking"), StageTask(title: "Excavation"),
                        StageTask(title: "Formwork"), StageTask(title: "Reinforcement"),
                        StageTask(title: "Pouring concrete")],
                notes: "", photos: [], order: 0),
            BuildStage(name: "Walls", icon: "🧱", colorHex: "F5B800",
                tasks: [StageTask(title: "Block delivery"), StageTask(title: "Lay first course"),
                        StageTask(title: "Window openings"), StageTask(title: "Complete walls")],
                notes: "", photos: [], order: 1),
            BuildStage(name: "Roof", icon: "🏠", colorHex: "FF6B6B",
                tasks: [StageTask(title: "Roof trusses"), StageTask(title: "Sheathing"),
                        StageTask(title: "Waterproofing"), StageTask(title: "Roofing tiles")],
                notes: "", photos: [], order: 2),
            BuildStage(name: "Electrical", icon: "⚡", colorHex: "4ECDC4",
                tasks: [StageTask(title: "Cable routing"), StageTask(title: "Distribution board"),
                        StageTask(title: "Sockets & switches"), StageTask(title: "Testing")],
                notes: "", photos: [], order: 3),
            BuildStage(name: "Finishing", icon: "🎨", colorHex: "A8E063",
                tasks: [StageTask(title: "Plastering"), StageTask(title: "Tiling"),
                        StageTask(title: "Painting"), StageTask(title: "Flooring"),
                        StageTask(title: "Final details")],
                notes: "", photos: [], order: 4),
        ]
        save()
    }

    // MARK: - Stage CRUD
    func addStage(_ s: BuildStage) {
        stages.append(s); save()
        log(title: "Stage added", subtitle: "\(s.icon) \(s.name)", icon: "plus.circle.fill", color: s.colorHex, cat: .stage)
    }
    func updateStage(_ s: BuildStage) {
        if let i = stages.firstIndex(where: { $0.id == s.id }) { stages[i] = s; save() }
    }
    func deleteStages(at offsets: IndexSet) { stages.remove(atOffsets: offsets); save() }

    // MARK: - Material CRUD
    func addMaterial(_ m: Material) {
        materials.append(m); save()
        log(title: "Material added", subtitle: "\(m.name) · \(formatCurrency(m.totalCost))", icon: "shippingbox.fill", color: "4ECDC4", cat: .material)
    }
    func updateMaterial(_ m: Material) {
        if let i = materials.firstIndex(where: { $0.id == m.id }) { materials[i] = m; save() }
    }
    func deleteMaterials(at offsets: IndexSet) { materials.remove(atOffsets: offsets); save() }

    // MARK: - Expense CRUD
    func addExpense(_ e: Expense) {
        expenses.append(e); save()
        log(title: "Expense logged", subtitle: "\(e.title) · \(formatCurrency(e.amount))", icon: "banknote.fill", color: "FF6B6B", cat: .expense)
    }
    func updateExpense(_ e: Expense) {
        if let i = expenses.firstIndex(where: { $0.id == e.id }) { expenses[i] = e; save() }
    }
    func deleteExpenses(at offsets: IndexSet) { expenses.remove(atOffsets: offsets); save() }

    // MARK: - Worker CRUD
    func addWorker(_ w: Worker) {
        workers.append(w); save()
        log(title: "Worker added", subtitle: "\(w.name) · \(w.specialization)", icon: "person.fill.badge.plus", color: "A8E063", cat: .worker)
    }
    func updateWorker(_ w: Worker) {
        if let i = workers.firstIndex(where: { $0.id == w.id }) { workers[i] = w; save() }
    }
    func deleteWorkers(at offsets: IndexSet) { workers.remove(atOffsets: offsets); save() }

    // MARK: - Document CRUD
    func addDocument(_ d: AppDocument) { documents.append(d); save() }
    func deleteDocuments(at offsets: IndexSet) { documents.remove(atOffsets: offsets); save() }

    // MARK: - Quick Notes CRUD
    func addQuickNote(_ n: QuickNote) { quickNotes.insert(n, at: 0); save() }
    func updateQuickNote(_ n: QuickNote) {
        if let i = quickNotes.firstIndex(where: { $0.id == n.id }) { quickNotes[i] = n; save() }
    }
    func deleteQuickNotes(at offsets: IndexSet) { quickNotes.remove(atOffsets: offsets); save() }
    func togglePinNote(_ n: QuickNote) {
        if var note = quickNotes.first(where: { $0.id == n.id }) {
            note.isPinned.toggle()
            updateQuickNote(note)
        }
    }
}
