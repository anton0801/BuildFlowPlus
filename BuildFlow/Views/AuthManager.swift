import Foundation
import Combine

// MARK: ─ Auth State

enum AuthState: Equatable {
    case splash
    case onboarding
    case unauthenticated     // show login screen
    case guest               // logged in as guest (local only)
    case authenticated       // Firebase user
}

// MARK: ─ Auth Error

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailInUse
    case wrongPassword
    case userNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:   return "Please enter a valid email address."
        case .weakPassword:   return "Password must be at least 6 characters."
        case .emailInUse:     return "This email is already registered. Try signing in."
        case .wrongPassword:  return "Incorrect password. Please try again."
        case .userNotFound:   return "No account found with this email."
        case .networkError:   return "Network error. Check your connection."
        case .unknown(let m): return m
        }
    }
}

// MARK: ─ AuthManager
// NOTE: This class is built to plug directly into Firebase Auth SDK.
// Add `import FirebaseAuth` and replace the stub calls with real Firebase calls
// as documented in the README. All method signatures are stable — no other files need changing.

class AuthManager: ObservableObject {

    // MARK: Published state
    @Published var authState: AuthState = .splash
    @Published var currentUser: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: Init
    init() {
        checkInitialState()
    }

    private func checkInitialState() {
        let onboardingDone = UserDefaults.standard.bool(forKey: "bf_onboardingDone")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if !onboardingDone {
                self.authState = .onboarding
                return
            }
            // ── FIREBASE PLUG-IN POINT ──────────────────────────────
            // Replace the block below with:
            //   if let fbUser = Auth.auth().currentUser {
            //       self.currentUser = UserProfile(id: fbUser.uid,
            //                                      displayName: fbUser.displayName ?? "User",
            //                                      email: fbUser.email ?? "",
            //                                      avatarEmoji: "👷",
            //                                      isGuest: fbUser.isAnonymous,
            //                                      joinDate: fbUser.metadata.creationDate ?? Date(),
            //                                      totalProjectsCreated: 0)
            //       self.authState = fbUser.isAnonymous ? .guest : .authenticated
            //   } else { self.authState = .unauthenticated }
            // ────────────────────────────────────────────────────────

            // Stub: check saved user
            if let data = UserDefaults.standard.data(forKey: "bf_currentUser"),
               let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
                self.currentUser = user
                self.authState = user.isGuest ? .guest : .authenticated
            } else {
                self.authState = .unauthenticated
            }
        }
    }

    // MARK: ─ Sign Up
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard isValidEmail(email) else { completion(.failure(.invalidEmail)); return }
        guard password.count >= 6  else { completion(.failure(.weakPassword)); return }

        isLoading = true
        errorMessage = nil

        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // Auth.auth().createUser(withEmail: email, password: password) { result, error in
        //     DispatchQueue.main.async {
        //         self.isLoading = false
        //         if let error = error {
        //             completion(.failure(self.mapFirebaseError(error)))
        //             return
        //         }
        //         let fbUser = result!.user
        //         let changeRequest = fbUser.createProfileChangeRequest()
        //         changeRequest.displayName = name
        //         changeRequest.commitChanges(completion: nil)
        //         let profile = UserProfile(id: fbUser.uid, displayName: name, email: email,
        //                                   avatarEmoji: "👷", isGuest: false,
        //                                   joinDate: Date(), totalProjectsCreated: 0)
        //         self.finishLogin(profile: profile, state: .authenticated)
        //         completion(.success(()))
        //     }
        // }
        // ────────────────────────────────────────────────────────────

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isLoading = false
            // Stub: simulate email-in-use for demo
            if email.lowercased() == "test@test.com" {
                completion(.failure(.emailInUse)); return
            }
            let profile = UserProfile(id: UUID().uuidString, displayName: name, email: email,
                                      avatarEmoji: Self.randomAvatar(),
                                      isGuest: false, joinDate: Date(), totalProjectsCreated: 0)
            self.finishLogin(profile: profile, state: .authenticated)
            completion(.success(()))
        }
    }

    // MARK: ─ Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard isValidEmail(email) else { completion(.failure(.invalidEmail)); return }
        guard !password.isEmpty   else { completion(.failure(.weakPassword)); return }

        isLoading = true
        errorMessage = nil

        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // Auth.auth().signIn(withEmail: email, password: password) { result, error in
        //     DispatchQueue.main.async {
        //         self.isLoading = false
        //         if let error = error { completion(.failure(self.mapFirebaseError(error))); return }
        //         let fbUser = result!.user
        //         let profile = UserProfile(id: fbUser.uid, displayName: fbUser.displayName ?? "User",
        //                                   email: fbUser.email ?? "", avatarEmoji: "👷",
        //                                   isGuest: false, joinDate: Date(), totalProjectsCreated: 0)
        //         self.finishLogin(profile: profile, state: .authenticated)
        //         completion(.success(()))
        //     }
        // }
        // ────────────────────────────────────────────────────────────

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            if password == "wrong" { completion(.failure(.wrongPassword)); return }
            let profile = UserProfile(id: UUID().uuidString, displayName: self.nameFromEmail(email),
                                      email: email, avatarEmoji: Self.randomAvatar(),
                                      isGuest: false, joinDate: Date(), totalProjectsCreated: 0)
            self.finishLogin(profile: profile, state: .authenticated)
            completion(.success(()))
        }
    }

    // MARK: ─ Guest Mode
    func continueAsGuest() {
        isLoading = true
        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // Auth.auth().signInAnonymously { result, error in
        //     DispatchQueue.main.async {
        //         self.isLoading = false
        //         guard let fbUser = result?.user else { return }
        //         let profile = UserProfile(id: fbUser.uid, displayName: "Guest User",
        //                                   email: "", avatarEmoji: "👤", isGuest: true,
        //                                   joinDate: Date(), totalProjectsCreated: 0)
        //         self.finishLogin(profile: profile, state: .guest)
        //     }
        // }
        // ────────────────────────────────────────────────────────────

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.finishLogin(profile: .guestProfile, state: .guest)
        }
    }

    // MARK: ─ Sign Out
    func signOut() {
        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // try? Auth.auth().signOut()
        // ────────────────────────────────────────────────────────────
        UserDefaults.standard.removeObject(forKey: "bf_currentUser")
        currentUser = nil
        authState = .unauthenticated
    }

    // MARK: ─ Delete Account
    func deleteAccount(completion: @escaping (Result<Void, AuthError>) -> Void) {
        isLoading = true
        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // Auth.auth().currentUser?.delete { error in
        //     DispatchQueue.main.async {
        //         self.isLoading = false
        //         if let error = error { completion(.failure(self.mapFirebaseError(error))); return }
        //         self.clearAllData()
        //         self.authState = .unauthenticated
        //         completion(.success(()))
        //     }
        // }
        // ────────────────────────────────────────────────────────────

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.clearAllData()
            completion(.success(()))
        }
    }

    // MARK: ─ Reset Password
    func resetPassword(email: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard isValidEmail(email) else { completion(.failure(.invalidEmail)); return }
        isLoading = true
        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // Auth.auth().sendPasswordReset(withEmail: email) { error in
        //     DispatchQueue.main.async {
        //         self.isLoading = false
        //         if let error = error { completion(.failure(self.mapFirebaseError(error))); return }
        //         completion(.success(()))
        //     }
        // }
        // ────────────────────────────────────────────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.isLoading = false
            completion(.success(()))
        }
    }

    // MARK: ─ Update Profile
    func updateProfile(name: String, emoji: String) {
        guard var user = currentUser else { return }
        user.displayName = name
        user.avatarEmoji = emoji
        currentUser = user
        saveCurrentUser(user)
        // ── FIREBASE PLUG-IN POINT ──────────────────────────────────
        // let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        // changeRequest?.displayName = name
        // changeRequest?.commitChanges(completion: nil)
        // ────────────────────────────────────────────────────────────
    }

    // MARK: ─ Helpers
    private func finishLogin(profile: UserProfile, state: AuthState) {
        currentUser = profile
        authState   = state
        saveCurrentUser(profile)
    }

    private func saveCurrentUser(_ user: UserProfile) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "bf_currentUser")
        }
    }

    private func clearAllData() {
        UserDefaults.standard.removeObject(forKey: "bf_currentUser")
        UserDefaults.standard.removeObject(forKey: "bf_project")
        UserDefaults.standard.removeObject(forKey: "bf_stages")
        UserDefaults.standard.removeObject(forKey: "bf_materials")
        UserDefaults.standard.removeObject(forKey: "bf_expenses")
        UserDefaults.standard.removeObject(forKey: "bf_workers")
        UserDefaults.standard.removeObject(forKey: "bf_documents")
        UserDefaults.standard.removeObject(forKey: "bf_notes")
        UserDefaults.standard.removeObject(forKey: "bf_activityLog")
        currentUser = nil
        authState   = .unauthenticated
    }

    private func isValidEmail(_ e: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return e.range(of: regex, options: .regularExpression) != nil
    }

    private func nameFromEmail(_ email: String) -> String {
        let local = email.components(separatedBy: "@").first ?? "User"
        return local.prefix(1).uppercased() + local.dropFirst()
    }

    private static func randomAvatar() -> String {
        ["👷","🧑‍🔧","👩‍🔧","🧑‍💼","👩‍💼","🏗️","🔨","⚙️"].randomElement() ?? "👷"
    }

    // MARK: ─ Firebase Error Mapper
    // Uncomment when adding Firebase SDK:
    // private func mapFirebaseError(_ error: Error) -> AuthError {
    //     let code = AuthErrorCode(rawValue: (error as NSError).code)
    //     switch code {
    //     case .invalidEmail:         return .invalidEmail
    //     case .emailAlreadyInUse:    return .emailInUse
    //     case .weakPassword:         return .weakPassword
    //     case .wrongPassword:        return .wrongPassword
    //     case .userNotFound:         return .userNotFound
    //     case .networkError:         return .networkError
    //     default:                    return .unknown(error.localizedDescription)
    //     }
    // }
}
