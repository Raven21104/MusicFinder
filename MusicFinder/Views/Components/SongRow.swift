import SwiftUI

struct SongRow: View {
    let song: Song
    var rank: Int? = nil

    var body: some View {
        HStack(spacing: 13) {
            if let rank {
                Text(String(rank))
                    .font(.callout.monospacedDigit().weight(.bold))
                    .foregroundStyle(rank <= 3 ? FinderStyle.accent : Color.secondary)
                    .frame(width: 25)
            }

            ArtworkView(url: song.artworkURL, cornerRadius: 5)
                .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(song.trackName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(song.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let album = song.collectionName {
                    Text(album).font(.caption).foregroundStyle(.tertiary).lineLimit(1)
                }
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
