import SwiftUI

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Currency Formatter
func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func scaleButtonStyle() -> some View {
        buttonStyle(ScaleButtonStyle())
    }
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            return AnyView(self.scrollContentBackground(.hidden))
        }
        return AnyView(self)
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Blueprint Grid
struct BlueprintGridView: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            var x: CGFloat = 0
            while x < size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.15)), lineWidth: 0.5)
                x += spacing
            }
            var y: CGFloat = 0
            while y < size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white.opacity(0.15)), lineWidth: 0.5)
                y += spacing
            }
        }
    }
}

// MARK: - Circular Progress
struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8), value: progress)
            Text(String(format: "%.0f%%", progress * 100))
                .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? Color(hex: "1A2F5E") : Color.white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(hex: "F5B800") : Color.white.opacity(0.08))
                .cornerRadius(20)
        }
    }
}

// MARK: - Form Field
struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color.white.opacity(0.6))
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.white)
                .padding(14)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
        }
    }
}

// MARK: - Stage Progress Row
struct StageProgressRow: View {
    let stage: BuildStage

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0D1F3C"))
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: stage.colorHex).opacity(0.2))
                        .frame(width: 44, height: 44)
                    Text(stage.icon).font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: stage.colorHex))
                                .frame(width: geo.size.width * CGFloat(stage.completionPercent / 100), height: 6)
                                .animation(.spring(response: 0.8), value: stage.completionPercent)
                        }
                    }.frame(height: 6)
                }
                Text(String(format: "%.0f%%", stage.completionPercent))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: stage.colorHex))
                    .frame(width: 40, alignment: .trailing)
            }
            .padding(14)
        }
    }
}
