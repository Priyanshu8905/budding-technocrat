import SwiftUI

struct SmartListsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // Glass Hero Header Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Theme.primary.opacity(0.15), Theme.primaryBg], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Theme.primary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Build Cart Instantly")
                                .font(.title3.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Upload a photo or paste your ordering list, and AI will assemble your cart in seconds.")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.9), Theme.primary.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                    
                    // Glass Action Card 1: Camera Upload
                    Button {
                        // Photo upload action
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primaryBg)
                                    .frame(width: 46, height: 46)
                                Image(systemName: "camera.fill")
                                    .font(.headline)
                                    .foregroundColor(Theme.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upload Photo of List")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Handwritten notes, receipts, JPEG & PNG")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Theme.primary)
                        }
                        .padding(16)
                        .background(.regularMaterial)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: true)
                    
                    // Glass Action Card 2: Text / Paste
                    Button {
                        // Type or paste action
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.08))
                                    .frame(width: 46, height: 46)
                                Image(systemName: "doc.text.fill")
                                    .font(.headline)
                                    .foregroundColor(Color.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Type or Paste List")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Paste text, WhatsApp items, or Excel notes")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Color.blue)
                        }
                        .padding(16)
                        .background(.regularMaterial)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: true)
                    
                    // Upload Tips Button
                    Button {
                        // Upload tips
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Theme.offer)
                            Text("Tips for accurate list parsing")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial)
                        .background(Color.white.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    
                    // Previous List Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Smart List")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.successLight)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(Theme.success)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Order Draft #1042")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("3 items processed · 2 mins ago")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Spacer()
                            
                            Button {
                                // Delete recent list
                            } label: {
                                Image(systemName: "trash")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textMuted)
                                    .padding(8)
                            }
                            .sensoryFeedback(.impact(weight: .light), trigger: true)
                        }
                        .padding(14)
                        .background(.regularMaterial)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.9), lineWidth: 1)
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Smart Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
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
