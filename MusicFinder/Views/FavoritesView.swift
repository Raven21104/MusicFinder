import SwiftData
import SwiftUI

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteSong.dateAdded, order: .reverse) private var favorites: [FavoriteSong]

    var body: some View {
        Group {
            if favorites.isEmpty {
                ScrollView {
                    EditorialHeading(eyebrow: "Your personal collection", title: "Keep the\ngood ones.", subtitle: "For the songs you always come back to.")
                    RecordArtwork(url: nil).frame(width: 210, height: 210).padding(32)
                    Text("Your first find is out there.")
                        .font(.system(.title2, design: .serif))
                    Text("Tap a song’s heart to save it here.")
                        .font(.subheadline).foregroundStyle(.secondary).padding(.top, 4)
                }.frame(maxWidth: .infinity)
            } else {
                List {
                    EditorialHeading(eyebrow: "Your personal collection", title: "The keepers.", subtitle: "\(favorites.count) saved \(favorites.count == 1 ? "song" : "songs") · Always yours to revisit")
                        .listRowInsets(EdgeInsets()).listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    ForEach(favorites) { favorite in
                        NavigationLink(value: favorite.song) { SongRow(song: favorite.song) }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 12))
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .background(FinderStyle.paper)
        .navigationDestination(for: Song.self) { SongDetailView(song: $0) }
        .toolbar {
            if !favorites.isEmpty { EditButton() }
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(favorites[index]) }
            try? modelContext.save()
        }
    }
}
