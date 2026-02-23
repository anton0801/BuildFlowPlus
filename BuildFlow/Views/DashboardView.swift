import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showEditProject = false
    @State private var animateProgress  = false

    var currentStage: BuildStage? {
        dataStore.stages.sorted { $0.order < $1.order }.first { $0.completionPercent < 100 }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Project")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.55))
                                Text(dataStore.project.name)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button { showEditProject = true } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(hex: "F5B800"))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Progress Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "0D1F3C"))
                                .shadow(color: .black.opacity(0.35), radius: 12)

                            HStack(spacing: 24) {
                                // Ring
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.08), lineWidth: 14)
                                        .frame(width: 110, height: 110)
                                    Circle()
                                        .trim(from: 0, to: animateProgress ? CGFloat(dataStore.overallProgress / 100) : 0)
                                        .stroke(
                                            AngularGradient(
                                                gradient: Gradient(colors: [Color(hex: "F5B800"), Color(hex: "FF8C00")]),
                                                center: .center
                                            ),
                                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                        )
                                        .frame(width: 110, height: 110)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.3), value: animateProgress)

                                    VStack(spacing: 2) {
                                        Text(dataStore.progressText)
                                            .font(.system(size: 22, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Done")
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.45))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 14) {
                                    InfoRowView(icon: "📍", label: "Current Stage",
                                                value: currentStage?.name ?? "All done! 🎉")
                                    InfoRowView(icon: "🏗️", label: "Stages",
                                                value: "\(dataStore.stages.filter { $0.completionPercent == 100 }.count)/\(dataStore.stages.count)")
                                    InfoRowView(icon: "📐", label: "Area",
                                                value: "\(Int(dataStore.project.area)) m²")
                                }
                                Spacer()
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)
                        .onAppear { animateProgress = true }

                        // Budget Summary
                        BudgetSummaryCard()
                            .padding(.horizontal)

                        // Quick Actions Grid
                        Text("Quick Actions")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
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
                                                subtitle: "Manage costs", color: "FF6B6B")
                            }
                        }
                        .padding(.horizontal)

                        // Stage Overview
                        if !dataStore.stages.isEmpty {
                            Text("Stage Overview")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            ForEach(dataStore.stages.sorted { $0.order < $1.order }.prefix(5)) { stage in
                                StageProgressRow(stage: stage)
                                    .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProject) {
                EditProjectView().environmentObject(dataStore)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Sub-components

struct InfoRowView: View {
    let icon: String; let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(icon) \(label)")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color.white.opacity(0.45))
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct BudgetSummaryCard: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.3), radius: 10)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("💰 Budget Overview")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    let pct = dataStore.project.totalBudget > 0
                        ? min(dataStore.totalSpent / dataStore.project.totalBudget * 100, 100)
                        : 0
                    Text(String(format: "%.0f%%", pct))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "F5B800"))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(hex: "F5B800").opacity(0.15))
                        .cornerRadius(8)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.08)).frame(height: 10)
                        let ratio = dataStore.project.totalBudget > 0
                            ? min(dataStore.totalSpent / dataStore.project.totalBudget, 1.0)
                            : 0
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [Color(hex: "F5B800"), Color(hex: "FF8C00")],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(ratio), height: 10)
                            .animation(.spring(response: 1.0), value: dataStore.totalSpent)
                    }
                }.frame(height: 10)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spent").font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.45))
                        Text(formatCurrency(dataStore.totalSpent))
                            .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text("Budget").font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.45))
                        Text(formatCurrency(dataStore.project.totalBudget))
                            .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(Color(hex: "F5B800"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining").font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.45))
                        Text(formatCurrency(dataStore.budgetRemaining))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(dataStore.budgetRemaining >= 0 ? Color(hex: "4ECDC4") : Color(hex: "FF6B6B"))
                    }
                }
            }
            .padding(20)
        }
    }
}

struct QuickActionCard: View {
    let icon: String; let title: String; let subtitle: String; let color: String
    @State private var pressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.3), radius: 8)
            VStack(alignment: .leading, spacing: 8) {
                Text(icon).font(.system(size: 34))
                Spacer()
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(height: 112)
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: pressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50,
                            pressing: { p in pressed = p }, perform: {})
    }
}

// MARK: - Edit Project
struct EditProjectView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    @State private var name    = ""
    @State private var area    = ""
    @State private var budget  = ""
    @State private var address = ""
    @State private var notes   = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(label: "Project Name", placeholder: "e.g. House 88m²", text: $name)
                        FormField(label: "Area (m²)", placeholder: "88", text: $area, keyboardType: .decimalPad)
                        FormField(label: "Address", placeholder: "Optional address", text: $address)
                        FormField(label: "Total Budget", placeholder: "150000", text: $budget, keyboardType: .decimalPad)
                        FormField(label: "Notes", placeholder: "Project notes...", text: $notes)

                        Button { save() } label: {
                            Text("Save Changes")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "1A2F5E"))
                                .frame(maxWidth: .infinity).frame(height: 54)
                                .background(Color(hex: "F5B800"))
                                .cornerRadius(16)
                        }
                        .scaleButtonStyle()
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }
                        .foregroundColor(Color(hex: "F5B800"))
                }
            }
        }
        .onAppear {
            name    = dataStore.project.name
            area    = String(dataStore.project.area)
            budget  = String(dataStore.project.totalBudget)
            address = dataStore.project.address
            notes   = dataStore.project.notes
        }
    }

    func save() {
        dataStore.project.name         = name.isEmpty ? dataStore.project.name : name
        dataStore.project.area         = Double(area) ?? dataStore.project.area
        dataStore.project.totalBudget  = Double(budget) ?? dataStore.project.totalBudget
        dataStore.project.address      = address
        dataStore.project.notes        = notes
        dataStore.save()
        dismiss.wrappedValue.dismiss()
    }
}
