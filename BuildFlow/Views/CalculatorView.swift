import SwiftUI

class CalculatorViewModel: ObservableObject {
    enum CalcType: String, CaseIterable {
        case brick    = "Brick"
        case concrete = "Concrete"
        case tile     = "Tile"
        case paint    = "Paint"

        var icon: String {
            switch self {
            case .brick:    return "🧱"
            case .concrete: return "🪨"
            case .tile:     return "⬜"
            case .paint:    return "🎨"
            }
        }
    }

    @Published var calcType: CalcType = .brick
    @Published var wastePercent: Double = 10
    @Published var result: String = ""

    // Brick
    @Published var wallLength    = ""
    @Published var wallHeight    = ""
    @Published var wallThickness = ""

    // Concrete
    @Published var concLength = ""
    @Published var concWidth  = ""
    @Published var concDepth  = ""

    // Tile
    @Published var roomArea  = ""
    @Published var tileSize  = ""

    // Paint
    @Published var paintArea     = ""
    @Published var coats         = "2"
    @Published var coveragePerL  = "10"

    func calculate() {
        let waste = 1.0 + wastePercent / 100.0
        switch calcType {

        case .brick:
            let l = Double(wallLength) ?? 0
            let h = Double(wallHeight) ?? 0
            let t = Double(wallThickness) ?? 0.25
            guard l > 0 && h > 0 else { result = "⚠️ Please fill in all fields."; return }
            let wallArea = l * h
            let bricksPerM2: Double = t <= 0.12 ? 51 : (t <= 0.25 ? 102 : 153)
            let total = Int((wallArea * bricksPerM2 * waste).rounded(.up))
            let mortar = wallArea * t * 0.3 * waste
            result = """
            Wall area: \(String(format: "%.1f", wallArea)) m²
            Bricks needed: \(total) pcs
            Mortar volume: \(String(format: "%.2f", mortar)) m³
            (incl. \(Int(wastePercent))% waste)
            """

        case .concrete:
            let l = Double(concLength) ?? 0
            let w = Double(concWidth)  ?? 0
            let d = Double(concDepth)  ?? 0
            guard l > 0 && w > 0 && d > 0 else { result = "⚠️ Please fill in all fields."; return }
            let vol = l * w * d * waste
            let cement = Int((vol * 7).rounded(.up))
            result = """
            Volume: \(String(format: "%.2f", vol)) m³
            Cement bags (50 kg): \(cement)
            Sand: \(String(format: "%.1f", vol * 0.5)) m³
            Gravel: \(String(format: "%.1f", vol * 0.85)) m³
            (incl. \(Int(wastePercent))% waste)
            """

        case .tile:
            let area = Double(roomArea) ?? 0
            let sz   = Double(tileSize) ?? 0
            guard area > 0 && sz > 0 else { result = "⚠️ Please fill in all fields."; return }
            let tileArea = sz * sz
            let total = Int((area / tileArea * waste).rounded(.up))
            let boxes = Int((Double(total) / 10).rounded(.up))
            result = """
            Room area: \(String(format: "%.1f", area)) m²
            Tiles needed: \(total) pcs
            Boxes (~10 tiles): \(boxes)
            Grout needed: \(String(format: "%.1f", area * 0.15)) kg
            (incl. \(Int(wastePercent))% waste)
            """

        case .paint:
            let area     = Double(paintArea)    ?? 0
            let nCoats   = Double(coats)        ?? 2
            let coverage = Double(coveragePerL) ?? 10
            guard area > 0 && coverage > 0 else { result = "⚠️ Please fill in all fields."; return }
            let liters = area * nCoats / coverage * waste
            result = """
            Surface area: \(String(format: "%.1f", area)) m²
            Paint needed: \(String(format: "%.1f", liters)) L
            Coats: \(Int(nCoats))
            Coverage rate: \(Int(coverage)) m²/L
            (incl. \(Int(wastePercent))% waste)
            """
        }
    }

    func reset() {
        wallLength = ""; wallHeight = ""; wallThickness = ""
        concLength = ""; concWidth = ""; concDepth = ""
        roomArea = ""; tileSize = ""
        paintArea = ""; coats = "2"; coveragePerL = "10"
        result = ""
    }
}

struct CalculatorView: View {
    @StateObject private var vm = CalculatorViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Type Tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(CalculatorViewModel.CalcType.allCases, id: \.self) { t in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            vm.calcType = t
                                            vm.result = ""
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(t.icon).font(.system(size: 30))
                                            Text(t.rawValue)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .foregroundColor(vm.calcType == t ? Color(hex: "1A2F5E") : .white)
                                        }
                                        .padding(.horizontal, 20).padding(.vertical, 12)
                                        .background(vm.calcType == t ? Color(hex: "F5B800") : Color.white.opacity(0.08))
                                        .cornerRadius(16)
                                        .shadow(color: vm.calcType == t ? Color(hex: "F5B800").opacity(0.4) : .clear, radius: 8, y: 4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Input Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "0D1F3C"))
                                .shadow(color: .black.opacity(0.3), radius: 12)

                            VStack(spacing: 14) {
                                switch vm.calcType {
                                case .brick:
                                    CalcFieldView(label: "Wall Length (m)", text: $vm.wallLength)
                                    CalcFieldView(label: "Wall Height (m)", text: $vm.wallHeight)
                                    CalcFieldView(label: "Wall Thickness (m)", text: $vm.wallThickness, placeholder: "0.25")
                                case .concrete:
                                    CalcFieldView(label: "Length (m)", text: $vm.concLength)
                                    CalcFieldView(label: "Width (m)",  text: $vm.concWidth)
                                    CalcFieldView(label: "Depth (m)",  text: $vm.concDepth, placeholder: "0.20")
                                case .tile:
                                    CalcFieldView(label: "Room Area (m²)", text: $vm.roomArea)
                                    CalcFieldView(label: "Tile Size (m)",  text: $vm.tileSize, placeholder: "0.30")
                                case .paint:
                                    CalcFieldView(label: "Surface Area (m²)", text: $vm.paintArea)
                                    CalcFieldView(label: "Number of Coats",   text: $vm.coats, placeholder: "2")
                                    CalcFieldView(label: "Coverage (m²/L)",   text: $vm.coveragePerL, placeholder: "10")
                                }

                                // Waste slider
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Waste / Spare")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(Color.white.opacity(0.6))
                                        Spacer()
                                        Text("\(Int(vm.wastePercent))%")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: "F5B800"))
                                    }
                                    Slider(value: $vm.wastePercent, in: 0...30, step: 1)
                                        .accentColor(Color(hex: "F5B800"))
                                }

                                // Calculate Button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) { vm.calculate() }
                                }) {
                                    Text("Calculate")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "1A2F5E"))
                                        .frame(maxWidth: .infinity).frame(height: 52)
                                        .background(Color(hex: "F5B800"))
                                        .cornerRadius(14)
                                        .shadow(color: Color(hex: "F5B800").opacity(0.4), radius: 10, y: 4)
                                }
                                .scaleButtonStyle()
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)

                        // Result Card
                        if !vm.result.isEmpty {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "0D1F3C"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "F5B800").opacity(0.3), lineWidth: 1.5)
                                    )
                                    .shadow(color: Color(hex: "F5B800").opacity(0.15), radius: 12)

                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("📊 Result")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: "F5B800"))
                                        Spacer()
                                        Text(vm.calcType.icon).font(.system(size: 24))
                                        Button { withAnimation { vm.result = "" } } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color.white.opacity(0.3))
                                        }
                                    }

                                    Divider().background(Color.white.opacity(0.12))

                                    Text(vm.result)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineSpacing(5)
                                }
                                .padding(20)
                            }
                            .padding(.horizontal)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Calculators")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { withAnimation { vm.reset() } } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(Color(hex: "F5B800"))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct CalcFieldView: View {
    let label: String
    @Binding var text: String
    var placeholder: String = "0"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(Color.white.opacity(0.55))
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color.white.opacity(0.07))
                .cornerRadius(10)
        }
    }
}
