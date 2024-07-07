import Foundation
import AuthenticationServices
import SwiftUI

class ProfileViewModel: NSObject, ObservableObject {
    @Published var userDetails: (name: PersonNameComponents?, email: String?)?
    @Published var errorMessage: String?
    
    func fetchUserDetails(for userId: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { (credentialState, error) in
            DispatchQueue.main.async {
                if credentialState == .authorized {
                    // User is authorized, but we can't fetch new details here
                    // We'll just use the userId to indicate the user is signed in
                    self.userDetails = (nil, nil)
                } else {
                    self.errorMessage = "User not authorized"
                }
            }
        }
    }
}

extension ProfileViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            DispatchQueue.main.async {
                self.userDetails = (appleIDCredential.fullName, appleIDCredential.email)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            print("Error fetching user details: \(error.localizedDescription)")
        }
    }
}

extension ProfileViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}

