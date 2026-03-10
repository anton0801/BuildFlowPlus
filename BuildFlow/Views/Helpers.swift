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

// MARK: - Currency
func formatCurrency(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.maximumFractionDigits = 0
    return f.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
extension View {
    func scaleButtonStyle() -> some View { buttonStyle(ScaleButtonStyle()) }
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) { return AnyView(self.scrollContentBackground(.hidden)) }
        return AnyView(self)
    }
}

// MARK: - Blueprint Grid
struct BlueprintGridView: View {
    var body: some View {
        Canvas { ctx, size in
            let sp: CGFloat = 32
            var x: CGFloat = 0
            while x <= size.width {
                var p = Path(); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))
                ctx.stroke(p, with: .color(.white.opacity(0.13)), lineWidth: 0.5)
                x += sp
            }
            var y: CGFloat = 0
            while y <= size.height {
                var p = Path(); p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(p, with: .color(.white.opacity(0.13)), lineWidth: 0.5)
                y += sp
            }
        }
    }
}

// MARK: - Circular Progress
struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    var lineWidth: CGFloat = 5

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.08), lineWidth: lineWidth).frame(width: size, height: size)
            Circle().trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size).rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.9), value: progress)
            Text(String(format: "%.0f%%", progress * 100))
                .font(.system(size: size * 0.20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? Color(hex: "1A2F5E") : Color.white.opacity(0.65))
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(isSelected ? Color(hex: "F5B800") : Color.white.opacity(0.08))
                .cornerRadius(20)
        }
    }
}

// MARK: - Form Field
struct FormField: View {
    let label: String; let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.55))
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.system(size: 15, design: .rounded)).foregroundColor(.white)
                .padding(14).background(Color.white.opacity(0.07)).cornerRadius(12)
        }
    }
}

// MARK: - Stage Progress Row
struct StageProgressRow: View {
    let stage: BuildStage
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14).fill(Color(hex: "0D1F3C"))
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color(hex: stage.colorHex).opacity(0.18)).frame(width: 44, height: 44)
                    Text(stage.icon).font(.system(size: 20))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.name).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.08)).frame(height: 6)
                            RoundedRectangle(cornerRadius: 4).fill(Color(hex: stage.colorHex))
                                .frame(width: geo.size.width * CGFloat(stage.completionPercent / 100), height: 6)
                                .animation(.spring(response: 0.9), value: stage.completionPercent)
                        }
                    }.frame(height: 6)
                }
                Text(String(format: "%.0f%%", stage.completionPercent))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: stage.colorHex)).frame(width: 38, alignment: .trailing)
            }.padding(14)
        }
    }
}

// MARK: - BF Card Background
struct BFCard: View {
    var cornerRadius: CGFloat = 18
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(hex: "0D1F3C"))
            .shadow(color: .black.opacity(0.28), radius: 10, y: 4)
    }
}

// MARK: - Avatar View
struct AvatarCircle: View {
    let emoji: String
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: "F5B800").opacity(0.75), Color(hex: "FF8C00").opacity(0.55)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
                .shadow(color: Color(hex: "F5B800").opacity(0.35), radius: size * 0.18)
            Text(emoji).font(.system(size: size * 0.45))
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var body: some View {
        HStack {
            Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
            Spacer()
            if let t = trailing {
                Text(t).font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.4))
            }
        }
    }
}

// MARK: - Guest Banner
struct GuestBanner: View {
    let onUpgrade: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 20)).foregroundColor(Color(hex: "F5B800"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Guest Mode").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("Data won't sync across devices").font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
            }
            Spacer()
            Button(action: onUpgrade) {
                Text("Sign Up").font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1A2F5E")).padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color(hex: "F5B800")).cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color(hex: "F5B800").opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "F5B800").opacity(0.3), lineWidth: 1))
        .cornerRadius(14)
    }
}
