import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataStore:   DataStore
    @State private var showEditProject  = false
    @State private var showNotesSheet   = false
    @State private var animProgress     = false
    @State private var tipIndex         = 0
    @State private var showTipSheet     = false
    @State private var newNote          = ""

    var tip: BuildTip { BuildTip.all[tipIndex % BuildTip.all.count] }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.11).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        // ── Guest banner
                        if authManager.authState == .guest {
                            GuestBanner {
                                // handled in profile sheet
                            }
                            .padding(.horizontal)
                        }

                        // ── Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting()).font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.5))
                                Text(dataStore.project.name)
                                    .font(.system(size: 23, weight: .black, design: .rounded)).foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            Spacer()
                            HStack(spacing: 10) {
                                // Project status badge
                                HStack(spacing: 5) {
                                    Image(systemName: dataStore.project.statusTag.icon).font(.system(size: 11))
                                    Text(dataStore.project.statusTag.rawValue).font(.system(size: 11, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(Color(hex: dataStore.project.statusTag.colorHex))
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .background(Color(hex: dataStore.project.statusTag.colorHex).opacity(0.15))
                                .cornerRadius(8)

                                Button { showEditProject = true } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 28)).foregroundColor(Color(hex: "F5B800"))
                                }
                            }
                        }
                        .padding(.horizontal).padding(.top, 6)

                        // ── Progress Card
                        progressCard.padding(.horizontal)

                        // ── Budget summary
                        BudgetSummaryCard().padding(.horizontal)

                        // ── Upcoming Deadlines
                        if !dataStore.upcomingDeadlines.isEmpty {
                            VStack(spacing: 10) {
                                SectionHeader(title: "⏰ Due Soon",
                                              trailing: "\(dataStore.upcomingDeadlines.count) stage(s)")
                                    .padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(dataStore.upcomingDeadlines) { stage in
                                            DeadlineChip(stage: stage)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // ── Quick Actions
                        SectionHeader(title: "Quick Actions").padding(.horizontal)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 42) {
                            NavigationLink(destination: StagesView().environmentObject(dataStore)) {
                                QuickActionCard(icon: "📋", title: "Stages",
                                                subtitle: "\(dataStore.stages.count) total", color: "F5B800")
                            }
                            NavigationLink(destination: MaterialsView().environmentObject(dataStore)) {
                                QuickActionCard(icon: "📦", title: "Materials",
                                                subtitle: "\(dataStore.materials.count) items", color: "4ECDC4")
                            }
                            NavigationLink(destination: WorkersView().environmentObject(dataStore)) {
                                QuickActionCard(icon: "👷", title: "Crew",
                                                subtitle: "\(dataStore.workers.count) workers", color: "A8E063")
                            }
                            NavigationLink(destination: BudgetView().environmentObject(dataStore)) {
                                QuickActionCard(icon: "💰", title: "Budget",
                                                subtitle: formatCurrency(dataStore.totalSpent), color: "FF6B6B")
                            }
                        }
                        .padding(.horizontal)

                        // ── Daily Tip
                        tipCard.padding(.horizontal)

                        // ── Quick Notes
                        VStack(spacing: 10) {
                            SectionHeader(title: "📝 Quick Notes",
                                          trailing: dataStore.quickNotes.isEmpty ? nil : "\(dataStore.quickNotes.count)")
                                .padding(.horizontal)
                            // Input
                            HStack(spacing: 10) {
                                TextField("Jot something down…", text: $newNote)
                                    .font(.system(size: 14, design: .rounded)).foregroundColor(.white)
                                    .padding(12).background(Color.white.opacity(0.07)).cornerRadius(12)
                                Button {
                                    let text = newNote.trimmingCharacters(in: .whitespaces)
                                    guard !text.isEmpty else { return }
                                    dataStore.addQuickNote(QuickNote(text: text))
                                    newNote = ""
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30)).foregroundColor(Color(hex: "F5B800"))
                                }
                            }
                            .padding(.horizontal)

                            if !dataStore.quickNotes.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(dataStore.quickNotes.prefix(3)) { note in
                                        QuickNoteRow(note: note)
                                            .environmentObject(dataStore)
                                    }
                                }
                                .padding(.horizontal)
                                if dataStore.quickNotes.count > 3 {
                                    Button { showNotesSheet = true } label: {
                                        Text("See all \(dataStore.quickNotes.count) notes →")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(Color(hex: "F5B800"))
                                    }
                                }
                            }
                        }

                        // ── Stage overview
                        if !dataStore.stages.isEmpty {
                            VStack(spacing: 10) {
                                SectionHeader(title: "Stage Overview").padding(.horizontal)
                                ForEach(dataStore.stages.sorted { $0.order < $1.order }.prefix(5)) { s in
                                    StageProgressRow(stage: s).padding(.horizontal)
                                }
                            }
                        }

                        // ── Recent Activity
                        if !dataStore.recentActivity.isEmpty {
                            VStack(spacing: 10) {
                                SectionHeader(title: "🕐 Recent Activity",
                                              trailing: "Last \(min(dataStore.recentActivity.count, 5))")
                                    .padding(.horizontal)
                                ForEach(dataStore.recentActivity.prefix(5)) { entry in
                                    ActivityRow(entry: entry).padding(.horizontal)
                                }
                            }
                        }

                        Spacer(minLength: 28)
                    }
                    .padding(.top, 14)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProject) {
                EditProjectView().environmentObject(dataStore)
            }
            .sheet(isPresented: $showNotesSheet) {
                AllNotesView().environmentObject(dataStore)
            }
            .sheet(isPresented: $showTipSheet) {
                TipDetailView(tip: tip)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { animProgress = true; tipIndex = Int.random(in: 0..<BuildTip.all.count) }
    }

    // MARK: - Progress Card
    var progressCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22).fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.32), radius: 12)
            HStack(spacing: 22) {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.07), lineWidth: 15).frame(width: 112)
                    Circle()
                        .trim(from: 0, to: animProgress ? CGFloat(dataStore.overallProgress/100) : 0)
                        .stroke(AngularGradient(
                            gradient: Gradient(colors: [Color(hex: "F5B800"), Color(hex: "FF8C00")]),
                            center: .center),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 112).rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.3, dampingFraction: 0.8).delay(0.3), value: animProgress)
                    VStack(spacing: 1) {
                        Text(dataStore.progressText)
                            .font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(.white)
                        Text("Done").font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.4))
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    InfoRowV(icon: "📍", label: "Stage",  value: dataStore.currentStage?.name ?? "All done 🎉")
                    InfoRowV(icon: "✅", label: "Tasks",   value: "\(dataStore.stages.flatMap { $0.tasks }.filter { $0.isDone }.count)/\(dataStore.stages.flatMap { $0.tasks }.count)")
                    InfoRowV(icon: "📐", label: "Area",   value: "\(Int(dataStore.project.area)) m²")
                }
                Spacer()
            }
            .padding(20)
        }
    }

    // MARK: - Tip Card
    var tipCard: some View {
        Button { showTipSheet = true } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color(hex: "F5B800").opacity(0.12), Color(hex: "FF8C00").opacity(0.06)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "F5B800").opacity(0.25), lineWidth: 1))
                HStack(spacing: 14) {
                    Text(tip.icon).font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("💡 Pro Tip").font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "F5B800")).tracking(0.8).textCase(.uppercase)
                            Spacer()
                            Text("Tap to read →").font(.system(size: 10, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.3))
                        }
                        Text(tip.title).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                        Text(tip.body).font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.55))
                            .lineLimit(2).lineSpacing(2)
                    }
                }
                .padding(16)
            }
        }
        .scaleButtonStyle()
    }

    func greeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        let name = authManager.currentUser?.displayName.components(separatedBy: " ").first ?? "there"
        if h < 12 { return "Good morning, \(name) 👋" }
        if h < 17 { return "Good afternoon, \(name) 👋" }
        return "Good evening, \(name) 👋"
    }
}

// MARK: - Sub-views

struct InfoRowV: View {
    let icon: String; let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(icon) \(label)").font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.4))
            Text(value).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white).lineLimit(1)
        }
    }
}

struct DeadlineChip: View {
    let stage: BuildStage
    var daysLeft: Int {
        guard let d = stage.deadline else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: d).day ?? 0
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(stage.icon).font(.system(size: 18))
                Text(stage.name).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white)
            }
            Text(daysLeft == 0 ? "Today!" : "\(daysLeft)d left")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(daysLeft <= 2 ? Color(hex: "FF6B6B") : Color(hex: "F5B800"))
        }
        .padding(12)
        .background(Color(hex: "0D1F3C"))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(daysLeft <= 2 ? Color(hex: "FF6B6B").opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct ActivityRow: View {
    let entry: ActivityLog
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color(hex: entry.colorHex).opacity(0.18)).frame(width: 36, height: 36)
                Image(systemName: entry.icon).font(.system(size: 14)).foregroundColor(Color(hex: entry.colorHex))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.white)
                Text(entry.subtitle).font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.45)).lineLimit(1)
            }
            Spacer()
            Text(entry.date, style: .relative)
                .font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.3))
        }
        .padding(12)
        .background(Color(hex: "0D1F3C"))
        .cornerRadius(12)
    }
}

struct QuickNoteRow: View {
    @EnvironmentObject var dataStore: DataStore
    let note: QuickNote
    var body: some View {
        HStack(spacing: 10) {
            if note.isPinned {
                Image(systemName: "pin.fill").font(.system(size: 11)).foregroundColor(Color(hex: "F5B800"))
            }
            Text(note.text).font(.system(size: 13, design: .rounded)).foregroundColor(.white).lineLimit(2)
            Spacer()
            Text(note.date, style: .date).font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.3))
            Button { dataStore.togglePinNote(note) } label: {
                Image(systemName: note.isPinned ? "pin.slash" : "pin")
                    .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.35))
            }
        }
        .padding(12)
        .background(Color(hex: "0D1F3C"))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: note.colorHex).opacity(0.25), lineWidth: 1))
    }
}

struct TipDetailView: View {
    let tip: BuildTip
    @Environment(\.presentationMode) var dismiss
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                VStack(spacing: 24) {
                    Text(tip.icon).font(.system(size: 80)).padding(.top, 30)
                    Text(tip.title).font(.system(size: 24, weight: .black, design: .rounded)).foregroundColor(.white)
                    Text(tip.body).font(.system(size: 16, design: .rounded)).foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center).lineSpacing(6).padding(.horizontal, 30)
                    HStack {
                        Image(systemName: "tag.fill").font(.system(size: 12))
                        Text(tip.category).font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(hex: tip.colorHex))
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Color(hex: tip.colorHex).opacity(0.15)).cornerRadius(10)
                    Spacer()
                }
            }
            .navigationTitle("Pro Tip").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss.wrappedValue.dismiss() }.foregroundColor(Color(hex: "F5B800"))
            }}
        }
    }
}

struct AllNotesView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    @State private var newText = ""
    let noteColors = ["F5B800","4ECDC4","FF6B6B","A8E063","AF52DE"]

    var sortedNotes: [QuickNote] {
        let pinned   = dataStore.quickNotes.filter  { $0.isPinned }.sorted { $0.date > $1.date }
        let unpinned = dataStore.quickNotes.filter  { !$0.isPinned }.sorted { $0.date > $1.date }
        return pinned + unpinned
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.10).ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        TextField("New note…", text: $newText)
                            .font(.system(size: 14, design: .rounded)).foregroundColor(.white)
                            .padding(12).background(Color.white.opacity(0.07)).cornerRadius(12)
                        Button {
                            guard !newText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            dataStore.addQuickNote(QuickNote(text: newText, colorHex: noteColors.randomElement() ?? "F5B800"))
                            newText = ""
                        } label: {
                            Image(systemName: "plus.circle.fill").font(.system(size: 30)).foregroundColor(Color(hex: "F5B800"))
                        }
                    }
                    .padding()

                    List {
                        ForEach(sortedNotes) { note in
                            QuickNoteRow(note: note).environmentObject(dataStore)
                                .listRowBackground(Color.clear).listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete { dataStore.deleteQuickNotes(at: $0) }
                    }
                    .listStyle(.plain).background(Color.clear)
                }
            }
            .navigationTitle("Quick Notes").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss.wrappedValue.dismiss() }.foregroundColor(Color(hex: "F5B800"))
            }}
        }
    }
}

struct QuickActionCard: View {
    let icon: String; let title: String; let subtitle: String; let color: String
    @State private var pressed = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(Color(hex: "0D1F3C")).shadow(color: .black.opacity(0.3), radius: 8)
            VStack(alignment: .leading, spacing: 8) {
                Text(icon).font(.system(size: 34))
                Spacer()
                Text(title).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        }
        .frame(height: 112)
        .scaleEffect(pressed ? 0.95 : 1.0).animation(.spring(response: 0.3), value: pressed)
        // .onLongPressGesture(minimumDuration: 0, maximumDistance: 50, pressing: { pressed = $0 }, perform: {})
    }
}

struct BudgetSummaryCard: View {
    @EnvironmentObject var dataStore: DataStore
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(Color(hex: "0D1F3C")).shadow(color: .black.opacity(0.3), radius: 10)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("💰 Budget Overview").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                    Spacer()
                    let pct = dataStore.project.totalBudget > 0
                        ? min(dataStore.totalSpent / dataStore.project.totalBudget * 100, 100) : 0
                    Text(String(format: "%.0f%%", pct))
                        .font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(Color(hex: "F5B800"))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(hex: "F5B800").opacity(0.15)).cornerRadius(8)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.07)).frame(height: 10)
                        let r = dataStore.project.totalBudget > 0
                            ? min(dataStore.totalSpent / dataStore.project.totalBudget, 1.0) : 0
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [Color(hex: "F5B800"), Color(hex: "FF8C00")], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(r), height: 10)
                            .animation(.spring(response: 1.0), value: dataStore.totalSpent)
                    }
                }.frame(height: 10)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spent").font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.4))
                        Text(formatCurrency(dataStore.totalSpent)).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text("Budget").font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.4))
                        Text(formatCurrency(dataStore.project.totalBudget)).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Color(hex: "F5B800"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Left").font(.system(size: 10, design: .rounded)).foregroundColor(Color.white.opacity(0.4))
                        Text(formatCurrency(dataStore.budgetRemaining))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(dataStore.budgetRemaining >= 0 ? Color(hex: "4ECDC4") : Color(hex: "FF6B6B"))
                    }
                }
            }
            .padding(20)
        }
    }
}

struct EditProjectView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    @State private var name   = ""; @State private var area    = ""
    @State private var budget = ""; @State private var address = ""
    @State private var notes  = ""
    @State private var status: ProjectStatus   = .active
    @State private var priority: ProjectPriority = .medium

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(label: "Project Name",  placeholder: "My House 88m²", text: $name)
                        FormField(label: "Area (m²)",     placeholder: "88", text: $area, keyboardType: .decimalPad)
                        FormField(label: "Address",       placeholder: "Street, City", text: $address)
                        FormField(label: "Total Budget",  placeholder: "150000", text: $budget, keyboardType: .decimalPad)
                        // Status picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status").font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.55))
                            HStack(spacing: 8) {
                                ForEach(ProjectStatus.allCases, id: \.self) { s in
                                    Button { withAnimation { status = s } } label: {
                                        Text(s.rawValue).font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundColor(status == s ? Color(hex: "1A2F5E") : .white)
                                            .padding(.horizontal, 10).padding(.vertical, 7)
                                            .background(status == s ? Color(hex: s.colorHex) : Color.white.opacity(0.07))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        // Priority picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority").font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.55))
                            HStack(spacing: 8) {
                                ForEach(ProjectPriority.allCases, id: \.self) { p in
                                    Button { withAnimation { priority = p } } label: {
                                        Text(p.rawValue).font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundColor(priority == p ? Color(hex: "1A2F5E") : .white)
                                            .padding(.horizontal, 14).padding(.vertical, 7)
                                            .background(priority == p ? Color(hex: p.colorHex) : Color.white.opacity(0.07))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        FormField(label: "Notes", placeholder: "Project notes…", text: $notes)
                        Button { save() } label: {
                            Text("Save Changes").font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "1A2F5E")).frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color(hex: "F5B800")).cornerRadius(14)
                        }
                        .scaleButtonStyle()
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Project").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss.wrappedValue.dismiss() }.foregroundColor(Color(hex: "F5B800"))
            }}
        }
        .onAppear {
            name    = dataStore.project.name;    area    = String(dataStore.project.area)
            budget  = String(dataStore.project.totalBudget); address = dataStore.project.address
            notes   = dataStore.project.notes;   status   = dataStore.project.statusTag
            priority = dataStore.project.priority
        }
    }

    func save() {
        if !name.isEmpty   { dataStore.project.name          = name }
        if let a = Double(area)   { dataStore.project.area         = a }
        if let b = Double(budget) { dataStore.project.totalBudget  = b }
        dataStore.project.address   = address
        dataStore.project.notes     = notes
        dataStore.project.statusTag = status
        dataStore.project.priority  = priority
        dataStore.save()
        dismiss.wrappedValue.dismiss()
    }
}
