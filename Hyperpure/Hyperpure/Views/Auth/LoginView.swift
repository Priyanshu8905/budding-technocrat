import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                HStack(spacing: 2) {
                    Text("hyper").font(.largeTitle.weight(.bold)).foregroundColor(Theme.textPrimary)
                    Text("pure").font(.largeTitle.weight(.bold)).foregroundColor(Theme.primary)
                }
                Text("by zomato")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textMuted)
                
                Text(authViewModel.loginStep == 1 ? "Enter your mobile number to get started" : "Enter 4-digit OTP sent to +91 \(authViewModel.phoneInput)")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Theme.primary)
                    .padding(.horizontal)
            }
            
            if authViewModel.loginStep == 1 {
                HStack {
                    Text("+91")
                        .font(.headline)
                        .foregroundColor(Theme.textMuted)
                    
                    TextField("Enter 10-digit mobile number", text: Bindable(authViewModel).phoneInput)
                        .keyboardType(.numberPad)
                        .font(.headline)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                
                Button {
                    authViewModel.sendOTP()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send OTP")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    }
                }
            } else {
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { idx in
                        TextField("", text: Binding(
                            get: { authViewModel.otpInput[idx] },
                            set: { newValue in
                                if newValue.count <= 1 {
                                    authViewModel.otpInput[idx] = newValue
                                }
                            }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .frame(width: 50, height: 50)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    }
                }
                
                Button {
                    authViewModel.verifyOTP()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verify & Login")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    }
                }
                
                Button {
                    authViewModel.loginStep = 1
                } label: {
                    Text("Change Number")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.primary)
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
