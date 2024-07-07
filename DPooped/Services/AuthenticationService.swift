import Foundation
import AuthenticationServices
import Security

class AuthenticationService: NSObject, ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var userId: String?
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var errorMessage: String?
    
    private let keychainService = "com.yourapp.authentication"
    
    override init() {
        self.isAuthenticated = false
        super.init()
        self.loadAuthenticationState()
    }
    
    private func loadAuthenticationState() {
        if let userId = KeychainHelper.load(service: keychainService, account: "userId"),
           let userName = KeychainHelper.load(service: keychainService, account: "userName"),
           let userEmail = KeychainHelper.load(service: keychainService, account: "userEmail") {
            self.userId = String(data: userId, encoding: .utf8)
            self.userName = String(data: userName, encoding: .utf8)
            self.userEmail = String(data: userEmail, encoding: .utf8)
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func signOut() {
        KeychainHelper.delete(service: keychainService, account: "userId")
        KeychainHelper.delete(service: keychainService, account: "userName")
        KeychainHelper.delete(service: keychainService, account: "userEmail")
        isAuthenticated = false
        userId = nil
        userName = nil
        userEmail = nil
    }
}

extension AuthenticationService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let userName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let userEmail = appleIDCredential.email ?? ""
            
            KeychainHelper.save(userId.data(using: .utf8)!, service: self.keychainService, account: "userId")
            KeychainHelper.save(userName.data(using: .utf8)!, service: self.keychainService, account: "userName")
            KeychainHelper.save(userEmail.data(using: .utf8)!, service: self.keychainService, account: "userEmail")
            
            DispatchQueue.main.async {
                self.userId = userId
                self.userName = userName
                self.userEmail = userEmail
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
}

extension AuthenticationService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}


