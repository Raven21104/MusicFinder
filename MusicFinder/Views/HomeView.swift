import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.songs.isEmpty {
                LoadingView(message: "Finding today’s hits…")
            } else if let error = viewModel.errorMessage, viewModel.songs.isEmpty {
                ErrorStateView(message: error) { Task { await viewModel.load(force: true) } }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        EditorialHeading(eyebrow: "MusicFinder / On rotation", title: "Good music.\nNew discoveries.", subtitle: "A little less scrolling. A little more listening.")
                        if let song = viewModel.songs.first {
                            NavigationLink(value: song) { spotlight(song) }
                                .buttonStyle(.plain).padding(.horizontal, 24)
                        }
                        HStack {
                            Text("The current rotation").font(.system(.title2, design: .serif).bold())
                            Spacer()
                            Text("TOP \(viewModel.songs.count)").font(.caption2.monospaced()).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24).padding(.top, 20)
                        ForEach(Array(viewModel.songs.enumerated()), id: \.element.id) { index, song in
                            NavigationLink(value: song) {
                                SongRow(song: song, rank: index + 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .refreshable { await viewModel.load(force: true) }
            }
        }
        .background(FinderStyle.paper)
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Song.self) { SongDetailView(song: $0) }
        .task { await viewModel.load() }
    }

    private func spotlight(_ song: Song) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label("IN THE SPOTLIGHT", systemImage: "smallcircle.filled.circle")
                Spacer()
                Text("01 /")
            }
            .font(.caption2.monospaced().weight(.medium)).tracking(2)
            RecordArtwork(url: song.artworkURL)
                .frame(maxWidth: 250)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 10)
                .frame(maxWidth: .infinity)
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(song.trackName).font(.system(.title2, design: .serif).bold()).lineLimit(2)
                    Text(song.artistName).font(.subheadline).opacity(0.8).lineLimit(1)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right").font(.title3)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.15), in: Circle())
            }
        }
        .padding(24).foregroundStyle(.white)
        .background(FinderStyle.accent, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}
