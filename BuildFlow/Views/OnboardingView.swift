import SwiftUI

private struct OBPage {
    let icon: String; let title: String; let subtitle: String
    let accent: Color; let bg: [Color]
}

private let pages: [OBPage] = [
    OBPage(icon: "🏗️", title: "Manage Your Build",
           subtitle: "Track every stage of your construction from foundation to final details.",
           accent: Color(hex: "F5B800"), bg: [Color(hex: "1A2F5E"), Color(hex: "0D1F3C")]),
    OBPage(icon: "📦", title: "Track Materials",
           subtitle: "Log every item, quantity, and price. Know your costs at a glance.",
           accent: Color(hex: "4ECDC4"), bg: [Color(hex: "1A3A5C"), Color(hex: "0F2740")]),
    OBPage(icon: "💰", title: "Control Budget",
           subtitle: "Monitor spending vs. plan. Never let costs spiral out of control.",
           accent: Color(hex: "FF6B6B"), bg: [Color(hex: "1E2D5A"), Color(hex: "10193A")]),
    OBPage(icon: "👷", title: "Manage Your Crew",
           subtitle: "Keep track of workers, specializations, and work history in one place.",
           accent: Color(hex: "A8E063"), bg: [Color(hex: "1A3550"), Color(hex: "0D2035")]),
    OBPage(icon: "🔒", title: "Your Account, Your Data",
           subtitle: "Sign up for cloud backup or continue as a guest. Your choice, your privacy.",
           accent: Color(hex: "F5B800"), bg: [Color(hex: "1A2F5E"), Color(hex: "0D1F3C")]),
]

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var page  = 0
    @State private var iconS: CGFloat = 0.5
    @State private var iconO: Double  = 0
    @State private var txtY:  CGFloat = 40
    @State private var txtO:  Double  = 0

    private var p: OBPage {
        get {
            pages[page]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: p.bg, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea().animation(.easeInOut(duration: 0.45), value: page)
            BlueprintGridView().opacity(0.14).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                // Icon
                ZStack {
                    Circle().fill(p.accent.opacity(0.12)).frame(width: 200, height: 200)
                    Circle().stroke(p.accent.opacity(0.3), lineWidth: 1.5).frame(width: 200, height: 200)
                    Circle().stroke(p.accent.opacity(0.1), lineWidth: 1.5).frame(width: 230, height: 230)
                    Text(p.icon).font(.system(size: 90))
                }
                .scaleEffect(iconS).opacity(iconO)

                Spacer().frame(height: 44)

                VStack(spacing: 16) {
                    Text(p.title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white).multilineTextAlignment(.center)
                    Text(p.subtitle)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.62))
                        .multilineTextAlignment(.center).padding(.horizontal, 36).lineSpacing(4)
                }
                .offset(y: txtY).opacity(txtO)

                Spacer()

                // Dots
                HStack(spacing: 7) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? p.accent : Color.white.opacity(0.22))
                            .frame(width: i == page ? 26 : 7, height: 7)
                            .animation(.spring(response: 0.35), value: page)
                    }
                }.padding(.bottom, 30)

                // Button
                Button(action: advance) {
                    HStack(spacing: 8) {
                        Text(page == pages.count-1 ? "Get Started" : "Next")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Image(systemName: page == pages.count-1 ? "checkmark" : "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "1A2F5E"))
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(p.accent).cornerRadius(16)
                    .padding(.horizontal, 32)
                    .shadow(color: p.accent.opacity(0.4), radius: 14, y: 5)
                }
                .scaleButtonStyle().padding(.bottom, 52)
            }
        }
        .gesture(DragGesture().onEnded { v in
            if v.translation.width < -50 { advance() }
            else if v.translation.width > 50 && page > 0 {
                withAnimation { page -= 1 }; animatePage()
            }
        })
        .onAppear { animatePage() }
    }

    func advance() {
        if page < pages.count - 1 {
            withAnimation(.spring(response: 0.35)) { page += 1 }
            animatePage()
        } else {
            UserDefaults.standard.set(true, forKey: "bf_onboardingDone")
            authManager.authState = .unauthenticated
        }
    }

    func animatePage() {
        iconS = 0.5; iconO = 0; txtY = 40; txtO = 0
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) { iconS = 1; iconO = 1 }
        withAnimation(.easeOut(duration: 0.38).delay(0.2)) { txtY = 0; txtO = 1 }
    }
}
