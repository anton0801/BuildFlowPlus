import SwiftUI

struct StagesView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAddStage    = false
    @State private var selectedStage: BuildStage? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()

                if dataStore.stages.isEmpty {
                    VStack(spacing: 16) {
                        Text("📋").font(.system(size: 70))
                        Text("No stages yet")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Tap + to add your first stage")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(dataStore.stages.sorted { $0.order < $1.order }) { stage in
                                Button { selectedStage = stage } label: {
                                    StageCard(stage: stage)
                                        .padding(.horizontal)
                                }
                            }
                            Spacer(minLength: 30)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Stages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddStage = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "F5B800"))
                    }
                }
            }
            .sheet(isPresented: $showAddStage) {
                AddStageView().environmentObject(dataStore)
            }
            .sheet(item: $selectedStage) { stage in
                StageDetailView(stage: stage).environmentObject(dataStore)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Stage Card
struct StageCard: View {
    let stage: BuildStage

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.3), radius: 10)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: stage.colorHex))
                    .frame(width: 5)
                    .cornerRadius(3)
                    .padding(.vertical, 12)
                    .padding(.leading, 12)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(stage.icon).font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stage.name)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(stage.tasks.filter { $0.isDone }.count)/\(stage.tasks.count) tasks")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.45))
                        }
                        Spacer()
                        CircularProgressView(
                            progress: stage.completionPercent / 100,
                            color: Color(hex: stage.colorHex),
                            size: 50
                        )
                    }

                    // Task preview
                    if !stage.tasks.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(stage.tasks.prefix(3)) { task in
                                HStack(spacing: 8) {
                                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isDone ? Color(hex: stage.colorHex) : Color.white.opacity(0.25))
                                        .font(.system(size: 13))
                                    Text(task.title)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(task.isDone ? Color.white.opacity(0.35) : Color.white.opacity(0.8))
                                        .strikethrough(task.isDone, color: Color.white.opacity(0.35))
                                }
                            }
                            if stage.tasks.count > 3 {
                                Text("+ \(stage.tasks.count - 3) more...")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.3))
                            }
                        }
                    }

                    if let deadline = stage.deadline {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar").font(.system(size: 11))
                            Text("Deadline: \(deadline, style: .date)")
                                .font(.system(size: 11, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "F5B800").opacity(0.8))
                    }
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Stage Detail
struct StageDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    @State var stage: BuildStage
    @State private var newTaskText = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.10).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // Header
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: stage.colorHex).opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: stage.colorHex).opacity(0.25), lineWidth: 1)
                                )
                            HStack {
                                Text(stage.icon).font(.system(size: 52))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stage.name)
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(String(format: "%.0f%% complete", stage.completionPercent))
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color(hex: stage.colorHex))
                                }
                                Spacer()
                                CircularProgressView(
                                    progress: stage.completionPercent / 100,
                                    color: Color(hex: stage.colorHex),
                                    size: 62
                                )
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)

                        // Tasks Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Tasks")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(stage.tasks.filter { $0.isDone }.count)/\(stage.tasks.count)")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.45))
                            }

                            ForEach(stage.tasks.indices, id: \.self) { i in
                                TaskRow(task: stage.tasks[i], color: Color(hex: stage.colorHex)) {
                                    withAnimation(.spring(response: 0.3)) {
                                        stage.tasks[i].isDone.toggle()
                                        dataStore.updateStage(stage)
                                    }
                                }
                            }

                            // Add Task Row
                            HStack(spacing: 10) {
                                TextField("Add new task...", text: $newTaskText)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.white.opacity(0.07))
                                    .cornerRadius(10)
                                Button {
                                    guard !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                    withAnimation {
                                        stage.tasks.append(StageTask(title: newTaskText))
                                        dataStore.updateStage(stage)
                                        newTaskText = ""
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color(hex: "F5B800"))
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Deadline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deadline")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            HStack {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { stage.deadline ?? Date() },
                                        set: { stage.deadline = $0; dataStore.updateStage(stage) }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .labelsHidden()
                                Spacer()
                                if stage.deadline != nil {
                                    Button {
                                        stage.deadline = nil
                                        dataStore.updateStage(stage)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.white.opacity(0.35))
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            ZStack(alignment: .topLeading) {
                                if stage.notes.isEmpty {
                                    Text("Write notes about this stage...")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color.white.opacity(0.25))
                                        .padding(14)
                                }
                                TextEditor(text: Binding(
                                    get: { stage.notes },
                                    set: { stage.notes = $0; dataStore.updateStage(stage) }
                                ))
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white)
                                .frame(minHeight: 100)
                                .padding(10)
                                .background(Color.clear)
                            }
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(stage.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss.wrappedValue.dismiss() }
                        .foregroundColor(Color(hex: "F5B800"))
                }
            }
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: StageTask
    let color: Color
    let onTap: () -> Void
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { scale = 0.92 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.25)) { scale = 1.0 }
                onTap()
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(task.isDone ? color : Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)
                    if task.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Text(task.title)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(task.isDone ? Color.white.opacity(0.38) : .white)
                    .strikethrough(task.isDone, color: Color.white.opacity(0.38))
                Spacer()
            }
            .padding(12)
            .background(Color(hex: "0D1F3C"))
            .cornerRadius(12)
        }
        .scaleEffect(scale)
    }
}

// MARK: - Add Stage
struct AddStageView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    @State private var name     = ""
    @State private var icon     = "🔨"
    @State private var colorHex = "F5B800"
    @State private var notes    = ""

    let icons  = ["🔨","⛏️","🧱","🏠","⚡","🎨","🪟","🚪","🔧","🪛","📐","🪚","🏗️","🚿","🪵"]
    let colors = ["F5B800","FF6B6B","4ECDC4","A8E063","8E8E93","FF9500","AF52DE","007AFF","34C759","FF3B30"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // Icon picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Icon")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                                ForEach(icons, id: \.self) { ic in
                                    Button { withAnimation(.spring(response: 0.3)) { icon = ic } } label: {
                                        Text(ic).font(.system(size: 28))
                                            .frame(width: 52, height: 52)
                                            .background(icon == ic ? Color(hex: colorHex).opacity(0.25) : Color.white.opacity(0.06))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(icon == ic ? Color(hex: colorHex) : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Color")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                                ForEach(colors, id: \.self) { c in
                                    Button { withAnimation(.spring(response: 0.3)) { colorHex = c } } label: {
                                        Circle()
                                            .fill(Color(hex: c))
                                            .frame(width: 36, height: 36)
                                            .overlay(Circle().stroke(Color.white, lineWidth: colorHex == c ? 3 : 0))
                                            .scaleEffect(colorHex == c ? 1.15 : 1.0)
                                            .animation(.spring(response: 0.3), value: colorHex)
                                    }
                                }
                            }
                        }

                        FormField(label: "Stage Name", placeholder: "e.g. Plumbing", text: $name)
                        FormField(label: "Notes", placeholder: "Optional notes...", text: $notes)

                        Button {
                            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let s = BuildStage(name: name, icon: icon, colorHex: colorHex,
                                               tasks: [], notes: notes, photos: [],
                                               order: dataStore.stages.count)
                            dataStore.addStage(s)
                            dismiss.wrappedValue.dismiss()
                        } label: {
                            Text("Add Stage")
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
            .navigationTitle("New Stage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }
                        .foregroundColor(Color(hex: "F5B800"))
                }
            }
        }
    }
}
