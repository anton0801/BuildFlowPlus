import SwiftUI

struct WorkersView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAdd               = false
    @State private var selectedWorker: Worker? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()

                if dataStore.workers.isEmpty {
                    VStack(spacing: 18) {
                        Text("👷").font(.system(size: 72))
                        Text("No crew members yet")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Add your first worker to get started")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.45))
                        Button { showAdd = true } label: {
                            Text("Add Worker")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "1A2F5E"))
                                .padding(.horizontal, 36).padding(.vertical, 14)
                                .background(Color(hex: "F5B800"))
                                .cornerRadius(14)
                                .shadow(color: Color(hex: "F5B800").opacity(0.4), radius: 10, y: 4)
                        }
                        .scaleButtonStyle()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Summary bar
                            HStack {
                                Text("👷 \(dataStore.workers.count) workers")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "F5B800"))
                                Spacer()
                                let totalDaily = dataStore.workers.reduce(0) { $0 + $1.dailyRate }
                                Text("Daily: \(formatCurrency(totalDaily))")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.45))
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)

                            ForEach(dataStore.workers) { worker in
                                WorkerCard(worker: worker)
                                    .padding(.horizontal)
                                    .onTapGesture { selectedWorker = worker }
                            }
                            Spacer(minLength: 24)
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("Crew")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "F5B800"))
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddWorkerView().environmentObject(dataStore)
            }
            .sheet(item: $selectedWorker) { w in
                WorkerDetailView(worker: w).environmentObject(dataStore)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Worker Card
struct WorkerCard: View {
    let worker: Worker

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.3), radius: 8)
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "F5B800").opacity(0.7), Color(hex: "FF8C00").opacity(0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 54, height: 54)
                    Text(String(worker.name.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(worker.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(worker.specialization)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.45))
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < worker.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(i < worker.rating ? Color(hex: "F5B800") : Color.white.opacity(0.18))
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(worker.dailyRate))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "F5B800"))
                    Text("/ day")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.35))
                    if !worker.phone.isEmpty {
                        Text(worker.phone)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.3))
                    }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Worker Detail
struct WorkerDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    @State var worker: Worker

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.10).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "F5B800"), Color(hex: "FF8C00")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 90, height: 90)
                                    .shadow(color: Color(hex: "F5B800").opacity(0.4), radius: 14)
                                Text(String(worker.name.prefix(1)).uppercased())
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Text(worker.specialization)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.55))
                        }
                        .padding(.top, 10)

                        // Info card
                        ZStack {
                            RoundedRectangle(cornerRadius: 18).fill(Color(hex: "0D1F3C"))
                            VStack(spacing: 14) {
                                WorkerDetailRow(label: "Full Name",       value: worker.name)
                                Divider().background(Color.white.opacity(0.08))
                                WorkerDetailRow(label: "Specialization",  value: worker.specialization)
                                Divider().background(Color.white.opacity(0.08))
                                WorkerDetailRow(label: "Phone",           value: worker.phone.isEmpty ? "—" : worker.phone)
                                Divider().background(Color.white.opacity(0.08))
                                WorkerDetailRow(label: "Daily Rate",      value: formatCurrency(worker.dailyRate))

                                Divider().background(Color.white.opacity(0.08))

                                // Star rating
                                HStack {
                                    Text("Rating")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(Color.white.opacity(0.45))
                                    Spacer()
                                    HStack(spacing: 6) {
                                        ForEach(1...5, id: \.self) { i in
                                            Button {
                                                withAnimation(.spring(response: 0.3)) {
                                                    worker.rating = i
                                                    dataStore.updateWorker(worker)
                                                }
                                            } label: {
                                                Image(systemName: i <= worker.rating ? "star.fill" : "star")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(i <= worker.rating ? Color(hex: "F5B800") : Color.white.opacity(0.18))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(18)
                        }
                        .padding(.horizontal)

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            ZStack(alignment: .topLeading) {
                                if worker.notes.isEmpty {
                                    Text("Notes about this worker...")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color.white.opacity(0.25))
                                        .padding(14)
                                }
                                TextEditor(text: Binding(
                                    get: { worker.notes },
                                    set: { worker.notes = $0; dataStore.updateWorker(worker) }
                                ))
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white)
                                .frame(minHeight: 90)
                                .padding(10)
                                .background(Color.clear)
                            }
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Work history
                        if !worker.workHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Work History")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                ForEach(worker.workHistory) { entry in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12).fill(Color(hex: "0D1F3C"))
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.stageName)
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                Text(entry.startDate, style: .date)
                                                    .font(.system(size: 11, design: .rounded))
                                                    .foregroundColor(Color.white.opacity(0.38))
                                                if !entry.notes.isEmpty {
                                                    Text(entry.notes)
                                                        .font(.system(size: 11, design: .rounded))
                                                        .foregroundColor(Color.white.opacity(0.4))
                                                }
                                            }
                                            Spacer()
                                            Text(formatCurrency(entry.amount))
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "F5B800"))
                                        }
                                        .padding(14)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Delete
                        Button {
                            if let i = dataStore.workers.firstIndex(where: { $0.id == worker.id }) {
                                dataStore.deleteWorkers(at: IndexSet(integer: i))
                            }
                            dismiss.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash").font(.system(size: 15))
                                Text("Remove Worker")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(Color(hex: "FF6B6B").opacity(0.12))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                }
            }
            .navigationTitle(worker.name)
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

struct WorkerDetailRow: View {
    let label: String; let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color.white.opacity(0.45))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Add Worker
struct AddWorkerView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss

    @State private var name           = ""
    @State private var phone          = ""
    @State private var specialization = ""
    @State private var dailyRate      = ""
    @State private var rating         = 3
    @State private var notes          = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(label: "Full Name",       placeholder: "e.g. John Smith",  text: $name)
                        FormField(label: "Phone",           placeholder: "+1 555 000 0000",   text: $phone, keyboardType: .phonePad)
                        FormField(label: "Specialization",  placeholder: "e.g. Electrician",  text: $specialization)
                        FormField(label: "Daily Rate ($)",  placeholder: "0.00",              text: $dailyRate, keyboardType: .decimalPad)

                        // Rating picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Initial Rating")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                            HStack(spacing: 10) {
                                ForEach(1...5, id: \.self) { i in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { rating = i }
                                    } label: {
                                        Image(systemName: i <= rating ? "star.fill" : "star")
                                            .font(.system(size: 30))
                                            .foregroundColor(i <= rating ? Color(hex: "F5B800") : Color.white.opacity(0.2))
                                    }
                                }
                            }
                        }

                        FormField(label: "Notes", placeholder: "Any notes...", text: $notes)

                        Button {
                            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let w = Worker(name: name, phone: phone, specialization: specialization,
                                           dailyRate: Double(dailyRate) ?? 0, rating: rating,
                                           notes: notes, workHistory: [])
                            dataStore.addWorker(w)
                            dismiss.wrappedValue.dismiss()
                        } label: {
                            Text("Add Worker")
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
            .navigationTitle("Add Worker")
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
