import SwiftUI

struct ArtworkView: View {
    let url: URL?
    var cornerRadius: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                placeholder
            case .empty:
                ZStack { placeholder; ProgressView().tint(.white) }
            @unknown default:
                placeholder
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    private var placeholder: some View {
        ZStack {
            FinderStyle.accent.opacity(0.8)
            Image(systemName: "music.note")
                .font(.title)
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}
