import SwiftUI

struct BlogView: View {
    private let posts = MockContent.blogs
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(post.category)
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Theme.primaryBg)
                                    .foregroundColor(Theme.primary)
                                    .clipShape(Capsule())
                                
                                Spacer()
                                
                                Text("\(post.date) • \(post.readTime)")
                                    .font(.caption2)
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Text(post.title)
                                .font(.headline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text(post.excerpt)
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                                .lineLimit(3)
                            
                            HStack {
                                Text("By \(post.author)")
                                    .font(.caption2.weight(.medium))
                                    .foregroundColor(Theme.textMuted)
                                Spacer()
                                HStack(spacing: 2) {
                                    Text("Read Article")
                                        .font(.caption.weight(.bold))
                                    Image(systemName: "chevron.right")
                                        .font(.caption2.weight(.bold))
                                }
                                .foregroundColor(Theme.primary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(14)
                        .cardStyle()
                    }
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Blogs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BlogView()
}
