import SwiftUI
import WebKit

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataStore:   DataStore
    @Environment(\.presentationMode) var dismiss
    @State private var showEditProfile    = false
    @State private var showSignOutAlert   = false
    @State private var showDeleteAlert    = false
    @State private var showUpgradeSheet   = false
    @State private var showDeleteConfirm  = ""
    @State private var deleteError        = ""
    @State private var successMessage     = ""

    var user: UserProfile { authManager.currentUser ?? .guestProfile }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                BlueprintGridView().opacity(0.10).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // ── Avatar + Name card
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(LinearGradient(colors: [Color(hex: "0D1F3C"), Color(hex: "162848")],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .shadow(color: .black.opacity(0.3), radius: 12)
                            VStack(spacing: 14) {
                                AvatarCircle(emoji: user.avatarEmoji, size: 88)

                                VStack(spacing: 5) {
                                    Text(user.displayName)
                                        .font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(.white)
                                    if !user.email.isEmpty {
                                        Text(user.email)
                                            .font(.system(size: 13, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
                                    }
                                    // Badge
                                    HStack(spacing: 6) {
                                        Image(systemName: user.isGuest ? "person.crop.circle" : "checkmark.seal.fill")
                                            .font(.system(size: 11))
                                        Text(user.isGuest ? "Guest Mode" : "Verified Account")
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(user.isGuest ? Color(hex: "FF9500") : Color(hex: "34C759"))
                                    .padding(.horizontal, 12).padding(.vertical, 5)
                                    .background((user.isGuest ? Color(hex: "FF9500") : Color(hex: "34C759")).opacity(0.12))
                                    .cornerRadius(10)
                                }

                                if !user.isGuest {
                                    Button { showEditProfile = true } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "pencil")
                                            Text("Edit Profile")
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(Color(hex: "F5B800"))
                                        .padding(.horizontal, 18).padding(.vertical, 8)
                                        .background(Color(hex: "F5B800").opacity(0.12))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "F5B800").opacity(0.3), lineWidth: 1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(24)
                        }
                        .padding(.horizontal)

                        // ── Guest upgrade prompt
                        if user.isGuest {
                            GuestBanner { showUpgradeSheet = true }.padding(.horizontal)
                        }

                        // ── Stats row
                        HStack(spacing: 12) {
                            StatCard(value: "\(dataStore.stages.count)",    label: "Stages",    color: "F5B800")
                            StatCard(value: "\(dataStore.materials.count)", label: "Materials", color: "4ECDC4")
                            StatCard(value: "\(dataStore.workers.count)",   label: "Crew",      color: "A8E063")
                        }
                        .padding(.horizontal)

                        // ── Account section
                        ProfileSection(title: "Account") {
                            if !user.isGuest {
                                ProfileRow(icon: "envelope.fill", label: "Email", value: user.email, iconColor: "4ECDC4")
                                Divider().background(Color.white.opacity(0.07))
                                ProfileRow(icon: "calendar", label: "Member since",
                                           value: user.joinDate.formatted(.dateTime.month().year()),
                                           iconColor: "A8E063")
                            }
                            ProfileRow(icon: "chart.bar.fill", label: "Overall Progress",
                                       value: dataStore.progressText, iconColor: "F5B800")
                            Divider().background(Color.white.opacity(0.07))
                            ProfileRow(icon: "banknote.fill", label: "Total Spent",
                                       value: formatCurrency(dataStore.totalSpent), iconColor: "FF6B6B")
                        }
                        .padding(.horizontal)

                        // ── App section
                        ProfileSection(title: "App") {
                            ProfileRow(icon: "info.circle.fill", label: "Version", value: "2.0.0", iconColor: "8E8E93")
                            Divider().background(Color.white.opacity(0.07))
                            ProfileRow(icon: "lock.shield.fill", label: "Privacy Policy", value: "", iconColor: "4ECDC4", isLink: true)
                            Divider().background(Color.white.opacity(0.07))
                            ProfileRow(icon: "questionmark.circle.fill", label: "Support", value: "", iconColor: "F5B800", isLink: true)
                        }
                        .padding(.horizontal)

                        // ── Success
                        if !successMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "34C759"))
                                Text(successMessage).font(.system(size: 13, design: .rounded)).foregroundColor(Color(hex: "34C759"))
                            }
                            .padding(14)
                            .background(Color(hex: "34C759").opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // ── Sign Out
                        Button { showSignOutAlert = true } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 16))
                                Text("Sign Out").font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(Color(hex: "FF9500"))
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .background(Color(hex: "FF9500").opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FF9500").opacity(0.3), lineWidth: 1))
                            .cornerRadius(14)
                        }
                        .scaleButtonStyle().padding(.horizontal)

                        // ── Delete Account
                        if !user.isGuest {
                            Button { showDeleteAlert = true } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "trash.fill").font(.system(size: 15))
                                    Text("Delete Account").font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(Color(hex: "FF6B6B"))
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Color(hex: "FF6B6B").opacity(0.08))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FF6B6B").opacity(0.25), lineWidth: 1))
                                .cornerRadius(14)
                            }
                            .scaleButtonStyle().padding(.horizontal)
                            Text("Permanently deletes your account and all data. This cannot be undone.")
                                .font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.28))
                                .multilineTextAlignment(.center).padding(.horizontal, 40)
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss.wrappedValue.dismiss() }.foregroundColor(Color(hex: "F5B800"))
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) { authManager.signOut() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    authManager.deleteAccount { result in
                        if case .failure = result { deleteError = "Failed to delete. Try again." }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView().environmentObject(authManager)
            }
            .sheet(isPresented: $showUpgradeSheet) {
                AuthView().environmentObject(authManager)
            }
        }
    }
}

// MARK: - Sub-components

struct StatCard: View {
    let value: String; let label: String; let color: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14).fill(Color(hex: "0D1F3C"))
                .shadow(color: .black.opacity(0.2), radius: 6)
            VStack(spacing: 4) {
                Text(value).font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: color))
                Text(label).font(.system(size: 11, design: .rounded)).foregroundColor(Color.white.opacity(0.45))
            }
            .padding(.vertical, 14)
        }
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.4)).tracking(0.8).textCase(.uppercase)
                .padding(.horizontal, 4).padding(.bottom, 8)
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(Color(hex: "0D1F3C"))
                VStack(spacing: 0) { content() }.padding(.vertical, 4)
            }
        }
    }
}

struct ProfileRow: View {
    let icon: String; let label: String; let value: String; let iconColor: String
    var isLink: Bool = false
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color(hex: iconColor).opacity(0.18)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(Color(hex: iconColor))
            }
            Text(label).font(.system(size: 14, design: .rounded)).foregroundColor(.white)
            Spacer()
            if !value.isEmpty {
                Text(value).font(.system(size: 13, design: .rounded)).foregroundColor(Color.white.opacity(0.45))
            }
            if isLink {
                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(Color.white.opacity(0.25))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

// MARK: - Edit Profile
struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var dismiss
    @State private var name  = ""
    @State private var emoji = "👷"

    let emojis = ["👷","🧑‍🔧","👩‍🔧","🧑‍💼","👩‍💼","🏗️","🔨","⚙️","🧱","📐","👨‍💻","👩‍💻"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A2F5E").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // Emoji picker
                        VStack(spacing: 12) {
                            AvatarCircle(emoji: emoji, size: 90)
                            Text("Choose your avatar")
                                .font(.system(size: 13, design: .rounded)).foregroundColor(Color.white.opacity(0.5))
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                                ForEach(emojis, id: \.self) { e in
                                    Button { withAnimation(.spring(response: 0.3)) { emoji = e } } label: {
                                        Text(e).font(.system(size: 28))
                                            .frame(width: 50, height: 50)
                                            .background(emoji == e ? Color(hex: "F5B800").opacity(0.25) : Color.white.opacity(0.06))
                                            .cornerRadius(12)
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(emoji == e ? Color(hex: "F5B800") : Color.clear, lineWidth: 2))
                                    }
                                }
                            }
                        }
                        FormField(label: "Display Name", placeholder: "Your name", text: $name)

                        Button {
                            authManager.updateProfile(name: name, emoji: emoji)
                            dismiss.wrappedValue.dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "1A2F5E"))
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color(hex: "F5B800")).cornerRadius(14)
                        }
                        .scaleButtonStyle()
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }.foregroundColor(Color(hex: "F5B800"))
                }
            }
            .onAppear {
                name  = authManager.currentUser?.displayName ?? ""
                emoji = authManager.currentUser?.avatarEmoji ?? "👷"
            }
        }
    }
}

// MARK: - BuildWebView (Redux)

struct BuildWebView: View {
    @State private var targetURL: String? = ""
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            if isActive, let urlString = targetURL, let url = URL(string: urlString) {
                WebContainer(url: url).ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { initialize() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in reload() }
    }
    
    private func initialize() {
        let temp = UserDefaults.standard.string(forKey: "temp_url")
        let stored = UserDefaults.standard.string(forKey: "bf_endpoint_target") ?? ""
        targetURL = temp ?? stored
        isActive = true
        if temp != nil { UserDefaults.standard.removeObject(forKey: "temp_url") }
    }
    
    private func reload() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            isActive = false
            targetURL = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isActive = true }
        }
    }
}

struct WebContainer: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> WebCoordinator { WebCoordinator() }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = buildWebView(coordinator: context.coordinator)
        context.coordinator.webView = webView
        context.coordinator.loadURL(url, in: webView)
        Task { await context.coordinator.loadCookies(in: webView) }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func buildWebView(coordinator: WebCoordinator) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        let script = WKUserScript(
            source: """
            (function() {
                const meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(meta);
                const style = document.createElement('style');
                style.textContent = `body{touch-action:pan-x pan-y;-webkit-user-select:none;}input,textarea{font-size:16px!important;}`;
                document.head.appendChild(style);
                document.addEventListener('gesturestart', e => e.preventDefault());
                document.addEventListener('gesturechange', e => e.preventDefault());
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(script)
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        return webView
    }
}

final class WebCoordinator: NSObject {
    weak var webView: WKWebView?
    private var redirectCount = 0, maxRedirects = 70
    private var lastURL: URL?, checkpoint: URL?
    private var popups: [WKWebView] = []
    private let cookieJar = "build_cookies"
    
    func loadURL(_ url: URL, in webView: WKWebView) {
        print("🏗️ [Build] Load: \(url.absoluteString)")
        redirectCount = 0
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(request)
    }
    
    func loadCookies(in webView: WKWebView) async {
        guard let cookieData = UserDefaults.standard.object(forKey: cookieJar) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let cookies = cookieData.values.flatMap { $0.values }.compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    private func saveCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            var cookieData: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            for cookie in cookies {
                var domainCookies = cookieData[cookie.domain] ?? [:]
                if let properties = cookie.properties { domainCookies[cookie.name] = properties }
                cookieData[cookie.domain] = domainCookies
            }
            UserDefaults.standard.set(cookieData, forKey: self.cookieJar)
        }
    }
}

extension WebCoordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
        lastURL = url
        let scheme = (url.scheme ?? "").lowercased()
        let path = url.absoluteString.lowercased()
        let allowedSchemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let specialPaths = ["srcdoc", "about:blank", "about:srcdoc"]
        if allowedSchemes.contains(scheme) || specialPaths.contains(where: { path.hasPrefix($0) }) || path == "about:blank" {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        redirectCount += 1
        if redirectCount > maxRedirects { webView.stopLoading(); if let recovery = lastURL { webView.load(URLRequest(url: recovery)) }; redirectCount = 0; return }
        lastURL = webView.url; saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current; print("✅ [Build] Commit: \(current.absoluteString)") }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current }; redirectCount = 0; saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorHTTPTooManyRedirects, let recovery = lastURL { webView.load(URLRequest(url: recovery)) }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension WebCoordinator: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        let popup = WKWebView(frame: webView.bounds, configuration: configuration)
        popup.navigationDelegate = self; popup.uiDelegate = self; popup.allowsBackForwardNavigationGestures = true
        webView.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: webView.topAnchor),
            popup.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ])
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(closePopup(_:)))
        gesture.edges = .left; popup.addGestureRecognizer(gesture)
        popups.append(popup)
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" { popup.load(navigationAction.request) }
        return popup
    }
    
    @objc private func closePopup(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        if let last = popups.last { last.removeFromSuperview(); popups.removeLast() } else { webView?.goBack() }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { completionHandler() }
}
