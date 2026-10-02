import Foundation

enum MusicServiceError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: "The request could not be created."
        case .invalidResponse: "The music service returned an unexpected response."
        }
    }
}

actor MusicService {
    static let shared = MusicService()

    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func topSongs(country: String = "us", limit: Int = 25) async throws -> [Song] {
        guard let url = URL(string: "https://rss.marketingtools.apple.com/api/v2/\(country)/music/most-played/\(limit)/songs.json") else {
            throw MusicServiceError.invalidURL
        }
        let response: TopSongsResponse = try await request(url)
        return response.feed.results.map(\.song)
    }

    func search(term: String, country: String = "us", limit: Int = 25) async throws -> [Song] {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = components?.url else { throw MusicServiceError.invalidURL }
        let response: SearchResponse = try await request(url)
        return response.results
    }

    func song(id: Int, country: String = "us") async throws -> Song? {
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [
            URLQueryItem(name: "id", value: String(id)),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "entity", value: "song")
        ]
        guard let url = components?.url else { throw MusicServiceError.invalidURL }
        let response: SearchResponse = try await request(url)
        return response.results.first(where: { $0.trackId == id })
    }

    private func request<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("MusicFinder/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw MusicServiceError.invalidResponse
        }
        return try decoder.decode(T.self, from: data)
    }
}
