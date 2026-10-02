import SwiftData
import SwiftUI

struct SongDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var player: AudioPreviewPlayer
    @Query private var favorites: [FavoriteSong]
    @State private var song: Song
    @State private var isEnriching = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(song: Song) {
        _song = State(initialValue: song)
    }

    private var isFavorite: Bool { favorites.contains { $0.trackID == song.trackId } }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Text("THE LISTENING ROOM")
                    Spacer()
                    Image(systemName: "waveform")
                }
                .font(.caption2.monospaced()).tracking(2)
                .foregroundStyle(FinderStyle.accent)

                RecordArtwork(url: song.artworkURL, playing: song.previewURL != nil && player.playingURL == song.previewURL)
                    .frame(maxWidth: 310)
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: .black.opacity(0.24), radius: 24, y: 14)

                VStack(spacing: 7) {
                    Text(song.trackName)
                        .font(.system(.largeTitle, design: .serif).bold())
                        .multilineTextAlignment(.center)
                    Text(song.artistName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    if let album = song.collectionName {
                        Text(album)
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                }

                HStack(spacing: 14) {
                    if let previewURL = song.previewURL {
                        VStack(spacing: 5) {
                            Button {
                                player.toggle(previewURL)
                            } label: {
                                Label(
                                    player.playingURL == previewURL ? "Stop Preview" : "Play Preview",
                                    systemImage: player.playingURL == previewURL ? "stop.fill" : "play.fill"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryCapsuleButtonStyle())

                            Text("Preview provided courtesy of iTunes")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } else if isEnriching {
                        ProgressView().frame(maxWidth: .infinity).padding()
                    } else {
                        Text("Preview unavailable for this song")
                            .font(.footnote).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }

                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isFavorite ? FinderStyle.accent : Color.primary)
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 54, height: 54)
                            .background(.thinMaterial, in: Circle())
                    }
                    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                }

                metadata

                if let storeURL = song.storeURL {
                    Link(destination: storeURL) {
                        Label("Open in Apple Music", systemImage: "arrow.up.right.square")
                    }
                    .font(.headline)
                }
            }
            .padding(20)
        }
        .background(FinderStyle.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadFullDetailsIfNeeded() }
        .onDisappear { player.stop() }
    }

    private var metadata: some View {
        HStack {
            MetadataItem(title: "Genre", value: song.primaryGenreName ?? "Music")
            Divider()
            MetadataItem(title: "Released", value: song.releaseDateText ?? "—")
            Divider()
            MetadataItem(title: "Duration", value: song.durationText ?? "—")
        }
        .frame(minHeight: 58)
        .padding()
        .background(FinderStyle.accent.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
    }

    private func toggleFavorite() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.7)) {
            if let existing = favorites.first(where: { $0.trackID == song.trackId }) {
                modelContext.delete(existing)
            } else {
                modelContext.insert(FavoriteSong(song: song))
            }
            try? modelContext.save()
        }
    }

    private func loadFullDetailsIfNeeded() async {
        guard song.previewURL == nil else { return }
        isEnriching = true
        defer { isEnriching = false }
        let country = UserDefaults.standard.string(forKey: "storeCountry") ?? "us"
        if let enriched = try? await MusicService.shared.song(id: song.trackId, country: country) {
            song = enriched
        }
    }
}

private struct MetadataItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 5) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.caption.weight(.semibold)).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PrimaryCapsuleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(minHeight: 54)
            .background(
                FinderStyle.accent,
                in: Capsule()
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
