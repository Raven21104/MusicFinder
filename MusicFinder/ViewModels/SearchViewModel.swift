import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [Song] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var searchTask: Task<Void, Never>?

    func queryChanged() {
        searchTask?.cancel()
        errorMessage = nil
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            isLoading = false
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled else { return }
            await search()
        }
    }

    func search() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let defaults = UserDefaults.standard
            let storedLimit = defaults.integer(forKey: "resultLimit")
            results = try await MusicService.shared.search(
                term: term,
                country: defaults.string(forKey: "storeCountry") ?? "us",
                limit: storedLimit == 0 ? 25 : storedLimit
            )
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit { searchTask?.cancel() }
}
