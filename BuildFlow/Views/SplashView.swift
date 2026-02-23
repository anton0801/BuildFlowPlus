import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    @State private var logoScale: CGFloat    = 0.3
    @State private var logoOpacity: Double   = 0
    @State private var titleOffset: CGFloat  = 30
    @State private var titleOpacity: Double  = 0
    @State private var gridOpacity: Double   = 0
    @State private var ringScale: CGFloat    = 0.5
    @State private var ringOpacity: Double   = 0
    @State private var particles: [SplashParticle] = []

    var body: some View {
        ZStack {
            Color(hex: "1A2F5E").ignoresSafeArea()

            // Blueprint grid
            BlueprintGridView()
                .opacity(gridOpacity)
                .ignoresSafeArea()

            // Animated ring
            Circle()
                .stroke(Color(hex: "F5B800").opacity(0.15), lineWidth: 60)
                .frame(width: 280, height: 280)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            Circle()
                .stroke(Color(hex: "F5B800").opacity(0.08), lineWidth: 30)
                .frame(width: 340, height: 340)
                .scaleEffect(ringScale * 0.95)
                .opacity(ringOpacity)

            // Particles
            ForEach(particles) { p in
                Circle()
                    .fill(Color(hex: "F5B800").opacity(p.opacity))
                    .frame(width: p.size, height: p.size)
                    .position(p.position)
            }

            // Logo + text
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F5B800"), Color(hex: "FF8C00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "F5B800").opacity(0.5), radius: 24)

                    VStack(spacing: 0) {
                        Text("🏗️")
                            .font(.system(size: 52))
                        Text("BF")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "1A2F5E"))
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("Build Flow")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Your Construction Manager")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.55))
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)
            }
        }
        .onAppear { runAnimation() }
    }

    func runAnimation() {
        // Grid fade
        withAnimation(.easeIn(duration: 0.8)) { gridOpacity = 0.25 }

        // Ring expand
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.2)) {
            ringScale = 1.0; ringOpacity = 1.0
        }

        // Logo pop
        withAnimation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.3)) {
            logoScale = 1.0; logoOpacity = 1.0
        }

        // Title slide
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.55)) {
            titleOffset = 0; titleOpacity = 1.0
        }

        // Particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            spawnParticles()
        }

        // Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.5)) { isFinished = false }
        }
    }

    func spawnParticles() {
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        particles = (0..<30).map { _ in
            SplashParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenW),
                    y: CGFloat.random(in: 0...screenH)
                ),
                size: CGFloat.random(in: 2...7),
                opacity: Double.random(in: 0.15...0.6)
            )
        }
    }
}

struct SplashParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}
