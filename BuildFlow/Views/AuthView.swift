import SwiftUI

enum AuthTab { case signIn, signUp }

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tab: AuthTab = .signIn
    @State private var showForgot    = false

    var body: some View {
        ZStack {
            Color(hex: "0A1628").ignoresSafeArea()
            BlueprintGridView().opacity(0.14).ignoresSafeArea()

            // Glow blobs
            Circle().fill(Color(hex: "F5B800").opacity(0.07))
                .frame(width: 400).blur(radius: 90).offset(x: 120, y: -200)
            Circle().fill(Color(hex: "4ECDC4").opacity(0.05))
                .frame(width: 350).blur(radius: 80).offset(x: -140, y: 250)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex: "F5B800"), Color(hex: "E6960A")],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: Color(hex: "F5B800").opacity(0.5), radius: 20)
                            Text("🏗️").font(.system(size: 38))
                        }
                        Text("Build Flow Plus")
                            .font(.system(size: 26, weight: .black, design: .rounded)).foregroundColor(.white)
                        Text("Construction Manager Pro")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.4)).tracking(1.4).textCase(.uppercase)
                    }
                    .padding(.top, 60).padding(.bottom, 36)

                    // Tab switcher
                    HStack(spacing: 0) {
                        ForEach([(AuthTab.signIn, "Sign In"), (AuthTab.signUp, "Create Account")], id: \.0) { t, label in
                            Button { withAnimation(.spring(response: 0.3)) { tab = t } } label: {
                                Text(label)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(tab == t ? Color(hex: "1A2F5E") : Color.white.opacity(0.5))
                                    .frame(maxWidth: .infinity).frame(height: 42)
                                    .background(tab == t ? Color(hex: "F5B800") : Color.clear)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    // Form card
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "0D1F3C"))
                            .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
                        Group {
                            if tab == .signIn {
                                SignInForm(onForgot: { showForgot = true })
                            } else {
                                SignUpForm()
                            }
                        }
                        .padding(24)
                    }
                    .padding(.horizontal, 24)

                    // Divider
                    HStack(spacing: 14) {
                        Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                        Text("or").font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.35))
                        Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    }
                    .padding(.horizontal, 24).padding(.vertical, 20)

                    // Guest button
                    Button(action: { authManager.continueAsGuest() }) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.crop.circle").font(.system(size: 18))
                            Text("Continue as Guest")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.white.opacity(0.07))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        .cornerRadius(14)
                    }
                    .scaleButtonStyle()
                    .padding(.horizontal, 24)

                    Text("Guest data is local only and won't sync across devices")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40).padding(.top, 10).padding(.bottom, 40)
                }
            }

            // Loading overlay
            if authManager.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView().progressViewStyle(.circular).tint(Color(hex: "F5B800")).scaleEffect(1.4)
                    Text("Please wait…").font(.system(size: 14, design: .rounded)).foregroundColor(.white)
                }
                .padding(32)
                .background(Color(hex: "0D1F3C").opacity(0.95))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.4), radius: 20)
            }
        }
        .sheet(isPresented: $showForgot) { ForgotPasswordView() }
    }
}

// MARK: - Sign In Form
struct SignInForm: View {
    @EnvironmentObject var authManager: AuthManager
    var onForgot: () -> Void
    @State private var email    = ""
    @State private var password = ""
    @State private var showPass = false
    @State private var errorMsg = ""
    @State private var shake    = false

    var body: some View {
        VStack(spacing: 16) {
            // Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email").font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
                HStack {
                    Image(systemName: "envelope").foregroundColor(Color.white.opacity(0.35)).font(.system(size: 15))
                    TextField("you@example.com", text: $email)
                        .keyboardType(.emailAddress).autocapitalization(.none).autocorrectionDisabled()
                        .font(.system(size: 15, design: .rounded)).foregroundColor(.white)
                }
                .padding(14).background(Color.white.opacity(0.07)).cornerRadius(12)
            }

            // Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password").font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
                HStack {
                    Image(systemName: "lock").foregroundColor(Color.white.opacity(0.35)).font(.system(size: 15))
                    Group {
                        if showPass { TextField("••••••••", text: $password) }
                        else        { SecureField("••••••••", text: $password) }
                    }
                    .font(.system(size: 15, design: .rounded)).foregroundColor(.white)
                    Button { showPass.toggle() } label: {
                        Image(systemName: showPass ? "eye.slash" : "eye")
                            .foregroundColor(Color.white.opacity(0.35)).font(.system(size: 15))
                    }
                }
                .padding(14).background(Color.white.opacity(0.07)).cornerRadius(12)
            }

            // Forgot
            HStack {
                Spacer()
                Button(action: onForgot) {
                    Text("Forgot password?")
                        .font(.system(size: 12, design: .rounded)).foregroundColor(Color(hex: "F5B800"))
                }
            }

            // Error
            if !errorMsg.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(hex: "FF6B6B"))
                    Text(errorMsg).font(.system(size: 12, design: .rounded)).foregroundColor(Color(hex: "FF6B6B"))
                    Spacer()
                }
                .padding(12).background(Color(hex: "FF6B6B").opacity(0.1)).cornerRadius(10)
                .offset(x: shake ? -6 : 0)
            }

            // Sign In Button
            Button(action: doSignIn) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Sign In").font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color(hex: "1A2F5E"))
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(Color(hex: "F5B800")).cornerRadius(14)
                .shadow(color: Color(hex: "F5B800").opacity(0.4), radius: 12, y: 4)
            }
            .scaleButtonStyle()
        }
    }

    func doSignIn() {
        errorMsg = ""
        authManager.signIn(email: email, password: password) { result in
            if case .failure(let err) = result {
                errorMsg = err.localizedDescription ?? "Error"
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3).repeatCount(3)) { shake.toggle() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shake = false }
            }
        }
    }
}

// MARK: - Sign Up Form
struct SignUpForm: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""
    @State private var showPass = false
    @State private var errorMsg = ""
    @State private var shake    = false

    var body: some View {
        VStack(spacing: 16) {
            FormFieldIcon(label: "Full Name",        placeholder: "John Builder", text: $name,     icon: "person")
            FormFieldIcon(label: "Email",            placeholder: "you@example.com", text: $email, icon: "envelope",
                          keyboard: .emailAddress, autocap: .none)
            PasswordFieldCustom(label: "Password",   placeholder: "Min 6 characters", text: $password, showPass: $showPass)
            PasswordFieldCustom(label: "Confirm",    placeholder: "Repeat password",   text: $confirm,  showPass: $showPass)

            // Password strength
            if !password.isEmpty {
                PasswordStrengthBar(password: password)
            }

            if !errorMsg.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color(hex: "FF6B6B"))
                    Text(errorMsg).font(.system(size: 12, design: .rounded)).foregroundColor(Color(hex: "FF6B6B"))
                    Spacer()
                }
                .padding(12).background(Color(hex: "FF6B6B").opacity(0.1)).cornerRadius(10)
                .offset(x: shake ? -6 : 0)
            }

            Button(action: doSignUp) {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("Create Account").font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color(hex: "1A2F5E"))
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(Color(hex: "F5B800")).cornerRadius(14)
                .shadow(color: Color(hex: "F5B800").opacity(0.4), radius: 12, y: 4)
            }
            .scaleButtonStyle()
        }
    }

    func doSignUp() {
        errorMsg = ""
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { errorMsg = "Please enter your name."; return }
        guard password == confirm else { errorMsg = "Passwords do not match."; triggerShake(); return }
        authManager.signUp(email: email, password: password, name: name) { result in
            if case .failure(let err) = result {
                errorMsg = err.localizedDescription ?? "Error"
                triggerShake()
            }
        }
    }

    func triggerShake() {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.3).repeatCount(3)) { shake.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shake = false }
    }
}

// MARK: - Forgot Password
struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var dismiss
    @State private var email   = ""
    @State private var sent    = false
    @State private var errorMsg = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.12).ignoresSafeArea()
                VStack(spacing: 24) {
                    if sent {
                        VStack(spacing: 16) {
                            Text("📧").font(.system(size: 64))
                            Text("Check Your Email")
                                .font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(.white)
                            Text("We sent password reset instructions to\n\(email)")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6)).multilineTextAlignment(.center).lineSpacing(4)
                        }
                        .padding(.top, 40)
                        Spacer()
                        Button { dismiss.wrappedValue.dismiss() } label: {
                            Text("Back to Sign In")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "1A2F5E"))
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color(hex: "F5B800")).cornerRadius(14)
                        }
                        .scaleButtonStyle().padding()
                    } else {
                        Text("Enter the email associated with your account and we'll send reset instructions.")
                            .font(.system(size: 15, design: .rounded)).foregroundColor(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center).lineSpacing(4).padding(.horizontal)

                        FormFieldIcon(label: "Email", placeholder: "you@example.com", text: $email,
                                      icon: "envelope", keyboard: .emailAddress, autocap: .none)
                            .padding(.horizontal)

                        if !errorMsg.isEmpty {
                            Text(errorMsg).font(.system(size: 12, design: .rounded)).foregroundColor(Color(hex: "FF6B6B"))
                        }

                        Button {
                            authManager.resetPassword(email: email) { result in
                                switch result {
                                case .success: sent = true
                                case .failure(let e): errorMsg = e.localizedDescription ?? ""
                                }
                            }
                        } label: {
                            Text("Send Reset Email")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "1A2F5E"))
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color(hex: "F5B800")).cornerRadius(14)
                        }
                        .scaleButtonStyle().padding(.horizontal)
                        Spacer()
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }.foregroundColor(Color(hex: "F5B800"))
                }
            }
        }
    }
}

// MARK: - Helper Form Components
struct FormFieldIcon: View {
    let label: String; let placeholder: String
    @Binding var text: String
    var icon: String = "pencil"
    var keyboard: UIKeyboardType = .default
    var autocap: UITextAutocapitalizationType = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
            HStack {
                Image(systemName: icon).foregroundColor(Color.white.opacity(0.35)).font(.system(size: 15))
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .font(.system(size: 15, design: .rounded)).foregroundColor(.white)
            }
            .padding(14).background(Color.white.opacity(0.07)).cornerRadius(12)
        }
    }
}

struct PasswordFieldCustom: View {
    let label: String; let placeholder: String
    @Binding var text: String
    @Binding var showPass: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
            HStack {
                Image(systemName: "lock").foregroundColor(Color.white.opacity(0.35)).font(.system(size: 15))
                Group {
                    if showPass { TextField(placeholder, text: $text) }
                    else        { SecureField(placeholder, text: $text) }
                }.font(.system(size: 15, design: .rounded)).foregroundColor(.white)
                Button { showPass.toggle() } label: {
                    Image(systemName: showPass ? "eye.slash" : "eye")
                        .foregroundColor(Color.white.opacity(0.35)).font(.system(size: 15))
                }
            }
            .padding(14).background(Color.white.opacity(0.07)).cornerRadius(12)
        }
    }
}

struct PasswordStrengthBar: View {
    let password: String

    var strength: Int {
        var s = 0
        if password.count >= 6  { s += 1 }
        if password.count >= 10 { s += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { s += 1 }
        if password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { s += 1 }
        return s
    }
    var label: String  { ["Weak","Fair","Good","Strong","Very Strong"][min(strength, 4)] }
    var color: Color   { [Color(hex:"FF6B6B"), Color(hex:"FF9500"), Color(hex:"F5B800"),
                           Color(hex:"A8E063"), Color(hex:"34C759")][min(strength, 4)] }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                ForEach(0..<4) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < strength ? color : Color.white.opacity(0.1))
                        .frame(height: 4).animation(.spring(response: 0.3), value: strength)
                }
            }
            Text(label).font(.system(size: 11, design: .rounded)).foregroundColor(color)
        }
    }
}
