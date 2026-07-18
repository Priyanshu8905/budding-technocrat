import SwiftUI

struct SmartListsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Video Banner (Screenshot 3)
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.radiusLg)
                            .fill(Color(red: 215/255, green: 195/255, blue: 165/255))
                            .frame(height: 180)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shopping list")
                                    .font(.caption.weight(.bold))
                                    .padding(4)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                Text("Potato .... 20kg")
                                    .font(.caption2)
                                Text("Onion .... 16kg")
                                    .font(.caption2)
                                Text("Paneer .... 5kg")
                                    .font(.caption2)
                            }
                            .padding(.leading, 16)
                            
                            Spacer()
                            
                            // Play Button Icon
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "play.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("INTRODUCING")
                            .font(.caption2.weight(.bold))
                            .tracking(2)
                            .foregroundColor(Theme.textMuted)
                        
                        Text("Smart Lists")
                            .font(.title.weight(.black))
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("Upload your ordering list and get a cart built instantly!")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 4)
                    
                    Text("GET STARTED")
                        .font(.caption2.weight(.bold))
                        .tracking(3)
                        .foregroundColor(Theme.textMuted)
                    
                    // Card 1: Upload Photo Card
                    Button {
                        // Photo upload
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 254/255, green: 235/255, blue: 238/255))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "camera.badge.ellipsis")
                                    .font(.title3)
                                    .foregroundColor(Theme.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upload photos of your list")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("jpeg & png files supported")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Theme.textMuted)
                        }
                        .padding(16)
                        .hyperpureCardStyle()
                    }
                    
                    Text("OR")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Theme.textMuted)
                    
                    // Card 2: Type/Paste Card
                    Button {
                        // Type or paste
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 254/255, green: 235/255, blue: 238/255))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "doc.plaintext")
                                    .font(.title3)
                                    .foregroundColor(Theme.primary)
                            }
                            
                            Text("Type in or paste your list here")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Theme.textMuted)
                        }
                        .padding(16)
                        .hyperpureCardStyle()
                    }
                    
                    Button {
                        // Upload tips
                    } label: {
                        Text("Upload tips")
                            .font(.subheadline.weight(.semibold))
                            .underline()
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Previous List")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("1 items • Text Processing")
                                    .font(.subheadline.weight(.bold))
                                Text("View smart list >")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            Spacer()
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundColor(Theme.textMuted)
                        }
                        .padding(14)
                        .hyperpureCardStyle()
                    }
                    .padding(.top, 12)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
        }
    }
}

#Preview {
    SmartListsView()
}
