import SwiftUI

struct MaterialsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAdd        = false
    @State private var editMaterial: Material? = nil
    @State private var searchText     = ""
    @State private var filterStatus: MaterialStatus? = nil

    var filtered: [Material] {
        dataStore.materials.filter { m in
            let ms = filterStatus == nil || m.status == filterStatus
            let mt = searchText.isEmpty || m.name.localizedCaseInsensitiveContains(searchText)
            return ms && mt
        }
    }
    var totalCost: Double { dataStore.materials.reduce(0) { $0 + $1.totalCost } }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(Color.white.opacity(0.4))
                        TextField("Search materials...", text: $searchText)
                            .foregroundColor(.white)
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.white.opacity(0.35))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(title: "All", isSelected: filterStatus == nil) { filterStatus = nil }
                            ForEach(MaterialStatus.allCases, id: \.self) { s in
                                FilterPill(title: s.rawValue, isSelected: filterStatus == s) { filterStatus = s }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)

                    // Summary
                    HStack {
                        Text("Total: \(formatCurrency(totalCost))")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "F5B800"))
                        Spacer()
                        Text("\(filtered.count) items")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.45))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            Text("📦").font(.system(size: 60))
                            Text(dataStore.materials.isEmpty ? "No materials yet" : "No results")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            if dataStore.materials.isEmpty {
                                Text("Tap + to add your first material")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.45))
                            }
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filtered) { material in
                                MaterialRow(material: material)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                    .onTapGesture { editMaterial = material }
                            }
                            .onDelete { offsets in
                                let ids = offsets.map { filtered[$0].id }
                                dataStore.materials.removeAll { ids.contains($0.id) }
                                dataStore.save()
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("Materials")
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
                AddMaterialView().environmentObject(dataStore)
            }
            .sheet(item: $editMaterial) { m in
                AddMaterialView(existing: m).environmentObject(dataStore)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Material Row
struct MaterialRow: View {
    let material: Material

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.2), radius: 6)
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: material.status.color).opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(Color(hex: material.status.color))
                        .font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(material.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Text("\(String(format: "%g", material.quantity)) \(material.unit.rawValue)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.45))
                        if !material.supplier.isEmpty {
                            Text("·").foregroundColor(Color.white.opacity(0.25))
                            Text(material.supplier)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.45))
                                .lineLimit(1)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(formatCurrency(material.totalCost))
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "F5B800"))
                    Text(material.status.rawValue)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: material.status.color))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color(hex: material.status.color).opacity(0.15))
                        .cornerRadius(6)
                }
            }
            .padding(14)
        }
        .padding(.horizontal)
    }
}

#Preview {
    BuildNotificationView(store: Store())
}

struct BuildNotificationView: View {
    @ObservedObject var store: Store
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image("notifications_screen_bg")
                    .resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea().opacity(0.9)
                
                if geometry.size.width < geometry.size.height {
                    VStack(spacing: 12) {
                        Spacer(); titleText
                            .multilineTextAlignment(.center); subtitleText
                            .multilineTextAlignment(.center); actionButtons
                    }.padding(.bottom, 24)
                } else {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 12) { Spacer(); titleText; subtitleText }
                        Spacer()
                        VStack { Spacer(); actionButtons }
                        Spacer()
                    }.padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
    
    private var titleText: some View {
        Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
    }
    
    private var subtitleText: some View {
        Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 12)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button { store.dispatch(.permissionRequested) } label: {
                Image("notifications_screen_button").resizable().frame(width: 300, height: 55)
            }
            Button { store.dispatch(.permissionDeferred) } label: {
                Text("Skip").font(.headline).foregroundColor(.gray)
            }
        }.padding(.horizontal, 12)
    }
}

// MARK: - Add / Edit Material
struct AddMaterialView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    var existing: Material? = nil

    @State private var name         = ""
    @State private var quantity     = ""
    @State private var unit: MaterialUnit   = .pcs
    @State private var pricePerUnit = ""
    @State private var supplier     = ""
    @State private var status: MaterialStatus = .planned
    @State private var notes        = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(label: "Material Name", placeholder: "e.g. Cement", text: $name)

                        HStack(spacing: 12) {
                            FormField(label: "Quantity", placeholder: "0", text: $quantity, keyboardType: .decimalPad)
                            // Unit menu
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Unit")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.6))
                                Menu {
                                    ForEach(MaterialUnit.allCases, id: \.self) { u in
                                        Button(u.rawValue) { unit = u }
                                    }
                                } label: {
                                    HStack {
                                        Text(unit.rawValue)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.white.opacity(0.45))
                                    }
                                    .padding(14)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                                }
                            }
                        }

                        FormField(label: "Price per Unit", placeholder: "0.00", text: $pricePerUnit, keyboardType: .decimalPad)
                        FormField(label: "Supplier", placeholder: "Supplier name", text: $supplier)

                        // Status
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                            HStack(spacing: 8) {
                                ForEach(MaterialStatus.allCases, id: \.self) { s in
                                    Button { withAnimation(.spring(response: 0.3)) { status = s } } label: {
                                        Text(s.rawValue)
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundColor(status == s ? Color(hex: "1A2F5E") : .white)
                                            .padding(.horizontal, 10).padding(.vertical, 8)
                                            .background(status == s ? Color(hex: s.color) : Color.white.opacity(0.07))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }

                        FormField(label: "Notes", placeholder: "Optional notes", text: $notes)

                        // Total preview
                        if let q = Double(quantity), let p = Double(pricePerUnit), q > 0, p > 0 {
                            HStack {
                                Text("Total Cost:")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.7))
                                Spacer()
                                Text(formatCurrency(q * p))
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(Color(hex: "F5B800"))
                            }
                            .padding(16)
                            .background(Color(hex: "F5B800").opacity(0.08))
                            .cornerRadius(12)
                        }

                        Button { saveMaterial() } label: {
                            Text(existing == nil ? "Add Material" : "Save Changes")
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
            .navigationTitle(existing == nil ? "Add Material" : "Edit Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }
                        .foregroundColor(Color(hex: "F5B800"))
                }
            }
        }
        .onAppear {
            guard let m = existing else { return }
            name = m.name; quantity = String(m.quantity); unit = m.unit
            pricePerUnit = String(m.pricePerUnit); supplier = m.supplier
            status = m.status; notes = m.notes
        }
    }

    func saveMaterial() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let m = Material(
            id: existing?.id ?? UUID(),
            name: name,
            quantity: Double(quantity) ?? 0,
            unit: unit,
            pricePerUnit: Double(pricePerUnit) ?? 0,
            supplier: supplier,
            status: status,
            notes: notes
        )
        if existing != nil { dataStore.updateMaterial(m) } else { dataStore.addMaterial(m) }
        dismiss.wrappedValue.dismiss()
    }
}
