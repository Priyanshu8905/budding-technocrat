import Foundation
import Observation

struct UserSession: Identifiable, Codable {
    var id: String { phone }
    let name: String
    let phone: String
    let businessName: String
}

@Observable
final class AuthViewModel {
    var isLoggedIn: Bool = false
    var isLoginSheetPresented: Bool = false
    var currentUser: UserSession? = nil
    
    var phoneInput: String = ""
    var otpInput: [String] = ["", "", "", ""]
    var loginStep: Int = 1 // 1: Phone, 2: OTP
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    func sendOTP() {
        guard phoneInput.count == 10 else {
            errorMessage = "Please enter a valid 10-digit mobile number"
            return
        }
        errorMessage = nil
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.isLoading = false
            self?.loginStep = 2
        }
    }
    
    func verifyOTP() {
        let code = otpInput.joined()
        guard code.count == 4 else {
            errorMessage = "Please enter the complete 4-digit OTP"
            return
        }
        errorMessage = nil
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.currentUser = UserSession(name: "Restaurant Owner", phone: self.phoneInput, businessName: "My Kitchen")
            self.isLoggedIn = true
            self.isLoginSheetPresented = false
            self.resetForm()
        }
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        resetForm()
    }
    
    func resetForm() {
        phoneInput = ""
        otpInput = ["", "", "", ""]
        loginStep = 1
        isLoading = false
        errorMessage = nil
    }
}
