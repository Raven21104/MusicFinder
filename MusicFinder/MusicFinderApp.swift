import SwiftData
import SwiftUI

@main
struct MusicFinderApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: FavoriteSong.self)
    }
}
