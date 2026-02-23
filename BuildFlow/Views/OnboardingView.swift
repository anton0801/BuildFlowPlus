import SwiftUI

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let bgColors: [Color]
}

let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "🏗️",
        title: "Manage Your Build",
        subtitle: "Track every stage of your construction project from foundation to finish line.",
        accentColor: Color(hex: "F5B800"),
        bgColors: [Color(hex: "1A2F5E"), Color(hex: "0D1F3C")]
    ),
    OnboardingPage(
        icon: "📦",
        title: "Track Materials",
        subtitle: "Log every item, quantity, and price. Know your costs at a glance.",
        accentColor: Color(hex: "4ECDC4"),
        bgColors: [Color(hex: "1A3A5C"), Color(hex: "0F2740")]
    ),
    OnboardingPage(
        icon: "💰",
        title: "Control Budget",
        subtitle: "Monitor spending vs. plan. Never let costs spiral out of control.",
        accentColor: Color(hex: "FF6B6B"),
        bgColors: [Color(hex: "1E2D5A"), Color(hex: "10193A")]
    ),
    OnboardingPage(
        icon: "👷",
        title: "Manage Your Crew",
        subtitle: "Keep track of workers, specializations, and work history in one place.",
        accentColor: Color(hex: "A8E063"),
        bgColors: [Color(hex: "1A3550"), Color(hex: "0D2035")]
    ),
    OnboardingPage(
        icon: "📐",
        title: "Built-in Calculators",
        subtitle: "Instantly calculate brick, concrete, tile, and paint needs for any space.",
        accentColor: Color(hex: "F5B800"),
        bgColors: [Color(hex: "1A2F5E"), Color(hex: "0D1F3C")]
    )
]

struct OnboardingView: View {
    @Binding var isFinished: Bool
    @State private var currentPage = 0
    @State private var iconScale: CGFloat  = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOffset: CGFloat = 40
    @State private var textOpacity: Double = 0

    var page: OnboardingPage { onboardingPages[currentPage] }

    var body: some View {
        ZStack {
            LinearGradient(colors: page.bgColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            BlueprintGridView().opacity(0.15).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(page.accentColor.opacity(0.15))
                        .frame(width: 190, height: 190)
                    Circle()
                        .stroke(page.accentColor.opacity(0.35), lineWidth: 2)
                        .frame(width: 190, height: 190)
                    Circle()
                        .stroke(page.accentColor.opacity(0.15), lineWidth: 2)
                        .frame(width: 220, height: 220)
                    Text(page.icon)
                        .font(.system(size: 88))
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                Spacer().frame(height: 48)

                // Text
                VStack(spacing: 18) {
                    Text(page.title)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .lineSpacing(4)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)

                Spacer()

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<onboardingPages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? page.accentColor : Color.white.opacity(0.25))
                            .frame(width: i == currentPage ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.35), value: currentPage)
                    }
                }
                .padding(.bottom, 36)

                // Button
                Button(action: advance) {
                    HStack(spacing: 8) {
                        Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: currentPage == onboardingPages.count - 1 ? "checkmark" : "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "1A2F5E"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(page.accentColor)
                    .cornerRadius(16)
                    .padding(.horizontal, 32)
                    .shadow(color: page.accentColor.opacity(0.45), radius: 14, y: 6)
                }
                .scaleButtonStyle()
                .padding(.bottom, 52)
            }
        }
        .gesture(
            DragGesture().onEnded { val in
                if val.translation.width < -50 { advance() }
                else if val.translation.width > 50 && currentPage > 0 {
                    withAnimation(.spring(response: 0.4)) { currentPage -= 1 }
                    animatePage()
                }
            }
        )
        .onAppear { animatePage() }
    }

    func advance() {
        if currentPage < onboardingPages.count - 1 {
            withAnimation(.spring(response: 0.35)) { currentPage += 1 }
            animatePage()
        } else {
            UserDefaults.standard.set(true, forKey: "onboardingDone")
            withAnimation(.easeOut(duration: 0.4)) { isFinished = false }
        }
    }

    func animatePage() {
        iconScale = 0.5; iconOpacity = 0; textOffset = 40; textOpacity = 0
        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.12)) {
            iconScale = 1.0; iconOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.22)) {
            textOffset = 0; textOpacity = 1.0
        }
    }
}
