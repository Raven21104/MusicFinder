import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        Group {
            if viewModel.query.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        EditorialHeading(eyebrow: "Follow your curiosity", title: "Find your\nnext obsession.", subtitle: "A song, an artist, an album. Start anywhere.")
                        Text("TAKE A SIDE ROAD").font(.caption2.monospaced()).tracking(2)
                            .foregroundStyle(.secondary).padding(.horizontal, 24)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                            ForEach(["Jazz", "Indie", "Soul", "Electronic"], id: \.self) { genre in
                                Button {
                                    viewModel.query = genre
                                } label: {
                                    VStack(alignment: .leading, spacing: 30) {
                                        Image(systemName: "arrow.up.right").frame(maxWidth: .infinity, alignment: .trailing)
                                        Text(genre).font(.system(.title2, design: .serif).bold())
                                    }
                                    .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.primary)
                                    .background(FinderStyle.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Search \(genre)")
                            }
                        }.padding(.horizontal, 24)
                    }
                }
            } else if viewModel.isLoading && viewModel.results.isEmpty {
                LoadingView(message: "Searching…")
            } else if let error = viewModel.errorMessage, viewModel.results.isEmpty {
                ErrorStateView(message: error) { Task { await viewModel.search() } }
            } else if viewModel.results.isEmpty && !viewModel.isLoading {
                ContentUnavailableView.search(text: viewModel.query)
            } else {
                List(viewModel.results) { song in
                    NavigationLink(value: song) { SongRow(song: song) }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 12))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .background(FinderStyle.paper)
        .navigationDestination(for: Song.self) { SongDetailView(song: $0) }
        .searchable(text: $viewModel.query, prompt: "Song, artist, or album")
        .onChange(of: viewModel.query) { _, _ in viewModel.queryChanged() }
        .onSubmit(of: .search) { Task { await viewModel.search() } }
    }
}
