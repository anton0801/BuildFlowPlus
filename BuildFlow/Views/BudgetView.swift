import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAdd             = false
    @State private var editExpense: Expense? = nil
    @State private var selectedCategory: ExpenseCategory? = nil

    var filteredExpenses: [Expense] {
        dataStore.expenses
            .filter { selectedCategory == nil || $0.category == selectedCategory }
            .sorted { $0.date > $1.date }
    }

    func categoryTotal(_ c: ExpenseCategory) -> Double {
        dataStore.expenses.filter { $0.category == c }.reduce(0) { $0 + $1.amount }
    }

    var topCategory: ExpenseCategory? {
        ExpenseCategory.allCases
            .filter { categoryTotal($0) > 0 }
            .max { categoryTotal($0) < categoryTotal($1) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Summary Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "0D1F3C"))
                                .shadow(color: .black.opacity(0.35), radius: 12)
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Total Budget")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.45))
                                        Text(formatCurrency(dataStore.project.totalBudget))
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                            .foregroundColor(Color(hex: "F5B800"))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Remaining")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.45))
                                        Text(formatCurrency(dataStore.budgetRemaining))
                                            .font(.system(size: 24, weight: .black, design: .rounded))
                                            .foregroundColor(dataStore.budgetRemaining >= 0
                                                             ? Color(hex: "4ECDC4") : Color(hex: "FF6B6B"))
                                    }
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 16)
                                        let ratio = dataStore.project.totalBudget > 0
                                            ? min(dataStore.totalSpent / dataStore.project.totalBudget, 1.0) : 0
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(LinearGradient(
                                                colors: [Color(hex: "F5B800"), Color(hex: "FF6B6B")],
                                                startPoint: .leading, endPoint: .trailing))
                                            .frame(width: geo.size.width * CGFloat(ratio), height: 16)
                                            .animation(.spring(response: 1.0), value: dataStore.totalSpent)
                                    }
                                }.frame(height: 16)

                                HStack {
                                    HStack(spacing: 6) {
                                        Circle().fill(Color(hex: "F5B800")).frame(width: 8, height: 8)
                                        Text("Spent: \(formatCurrency(dataStore.totalSpent))")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.6))
                                    }
                                    Spacer()
                                    if let tc = topCategory {
                                        HStack(spacing: 4) {
                                            Text("Top:")
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(Color.white.opacity(0.4))
                                            Text(tc.rawValue)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color(hex: tc.colorHex))
                                        }
                                    }
                                }
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)

                        // Category Breakdown
                        let activeCats = ExpenseCategory.allCases.filter { categoryTotal($0) > 0 }
                        if !activeCats.isEmpty {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20).fill(Color(hex: "0D1F3C"))
                                VStack(spacing: 12) {
                                    Text("By Category")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    let maxVal = activeCats.map { categoryTotal($0) }.max() ?? 1
                                    ForEach(activeCats, id: \.self) { cat in
                                        let total = categoryTotal(cat)
                                        HStack(spacing: 10) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(hex: cat.colorHex))
                                                .frame(width: 18)
                                            Text(cat.rawValue)
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundColor(.white)
                                                .frame(width: 75, alignment: .leading)
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.white.opacity(0.07)).frame(height: 8)
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color(hex: cat.colorHex))
                                                        .frame(width: geo.size.width * CGFloat(total / maxVal), height: 8)
                                                        .animation(.spring(response: 0.8), value: total)
                                                }
                                            }.frame(height: 8)
                                            Text(formatCurrency(total))
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: cat.colorHex))
                                                .frame(width: 64, alignment: .trailing)
                                        }
                                    }
                                }
                                .padding(20)
                            }
                            .padding(.horizontal)
                        }

                        // Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterPill(title: "All", isSelected: selectedCategory == nil) { selectedCategory = nil }
                                ForEach(ExpenseCategory.allCases, id: \.self) { c in
                                    FilterPill(title: c.rawValue, isSelected: selectedCategory == c) { selectedCategory = c }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Expenses
                        if filteredExpenses.isEmpty {
                            VStack(spacing: 14) {
                                Text("💳").font(.system(size: 52))
                                Text(dataStore.expenses.isEmpty ? "No expenses yet" : "No results")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 20)
                        } else {
                            ForEach(filteredExpenses) { expense in
                                ExpenseRow(expense: expense)
                                    .padding(.horizontal)
                                    .onTapGesture { editExpense = expense }
                            }
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Budget")
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
                AddExpenseView().environmentObject(dataStore)
            }
            .sheet(item: $editExpense) { e in
                AddExpenseView(existing: e).environmentObject(dataStore)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Expense Row
struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.2), radius: 6)
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: expense.category.colorHex).opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: expense.category.icon)
                        .foregroundColor(Color(hex: expense.category.colorHex))
                        .font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    HStack(spacing: 5) {
                        Text(expense.category.rawValue)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color(hex: expense.category.colorHex))
                        Text("·").foregroundColor(Color.white.opacity(0.25))
                        Text(expense.date, style: .date)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.38))
                    }
                }
                Spacer()
                Text(formatCurrency(expense.amount))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(14)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Add / Edit Expense
struct AddExpenseView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var dismiss
    var existing: Expense? = nil

    @State private var title    = ""
    @State private var amount   = ""
    @State private var category: ExpenseCategory = .materials
    @State private var date     = Date()
    @State private var notes    = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(label: "Title", placeholder: "e.g. Cement delivery", text: $title)
                        FormField(label: "Amount", placeholder: "0.00", text: $amount, keyboardType: .decimalPad)

                        // Category grid
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { c in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { category = c }
                                    } label: {
                                        VStack(spacing: 5) {
                                            Image(systemName: c.icon)
                                                .font(.system(size: 20))
                                                .foregroundColor(category == c ? Color(hex: "1A2F5E") : Color(hex: c.colorHex))
                                            Text(c.rawValue)
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(category == c ? Color(hex: "1A2F5E") : .white)
                                        }
                                        .frame(maxWidth: .infinity).frame(height: 62)
                                        .background(category == c ? Color(hex: c.colorHex) : Color.white.opacity(0.06))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .labelsHidden()
                                .padding(12)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
                        }

                        FormField(label: "Notes", placeholder: "Optional notes", text: $notes)

                        Button { saveExpense() } label: {
                            Text(existing == nil ? "Add Expense" : "Save Changes")
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
            .navigationTitle(existing == nil ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }
                        .foregroundColor(Color(hex: "F5B800"))
                }
            }
        }
        .onAppear {
            guard let e = existing else { return }
            title = e.title; amount = String(e.amount)
            category = e.category; date = e.date; notes = e.notes
        }
    }

    func saveExpense() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let amt = Double(amount), amt > 0 else { return }
        let e = Expense(id: existing?.id ?? UUID(), title: title, amount: amt,
                        category: category, date: date, notes: notes)
        if existing != nil { dataStore.updateExpense(e) } else { dataStore.addExpense(e) }
        dismiss.wrappedValue.dismiss()
    }
}
