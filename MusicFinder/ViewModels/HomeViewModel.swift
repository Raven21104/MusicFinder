import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var songs: [Song] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    func load(force: Bool = false) async {
        guard songs.isEmpty || force else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let defaults = UserDefaults.standard
            songs = try await MusicService.shared.topSongs(
                country: defaults.string(forKey: "storeCountry") ?? "us",
                limit: defaults.integer(forKey: "resultLimit").nonZeroOr(25)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension Int {
    func nonZeroOr(_ fallback: Int) -> Int { self == 0 ? fallback : self }
}
