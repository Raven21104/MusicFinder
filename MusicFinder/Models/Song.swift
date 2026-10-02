import Foundation

struct Song: Codable, Identifiable, Hashable, Sendable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackViewUrl: String?
    let primaryGenreName: String?
    let releaseDate: String?
    let trackTimeMillis: Int?
    let trackPrice: Double?
    let currency: String?

    var id: Int { trackId }

    var artworkURL: URL? {
        guard let artworkUrl100 else { return nil }
        return URL(string: artworkUrl100.replacingOccurrences(of: "100x100", with: "600x600"))
    }

    var previewURL: URL? { previewUrl.flatMap(URL.init(string:)) }
    var storeURL: URL? { trackViewUrl.flatMap(URL.init(string:)) }

    var durationText: String? {
        guard let trackTimeMillis else { return nil }
        let seconds = trackTimeMillis / 1_000
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    var releaseDateText: String? {
        guard let releaseDate else { return nil }
        let input = ISO8601DateFormatter()
        guard let date = input.date(from: releaseDate) else {
            return String(releaseDate.prefix(4))
        }
        return date.formatted(.dateTime.year().month(.abbreviated).day())
    }
}

struct SearchResponse: Codable, Sendable {
    let resultCount: Int
    let results: [Song]
}

struct TopSongsResponse: Codable, Sendable {
    let feed: TopSongsFeed
}

struct TopSongsFeed: Codable, Sendable {
    let results: [TopSong]
}

struct TopSong: Codable, Sendable {
    let id: String
    let name: String
    let artistName: String
    let artworkUrl100: String?
    let releaseDate: String?
    let url: String?
    let genres: [TopSongGenre]?

    var song: Song {
        Song(
            trackId: Int(id) ?? id.hashValue,
            trackName: name,
            artistName: artistName,
            collectionName: nil,
            artworkUrl100: artworkUrl100,
            previewUrl: nil,
            trackViewUrl: url,
            primaryGenreName: genres?.first?.name,
            releaseDate: releaseDate.map { $0 + "T00:00:00Z" },
            trackTimeMillis: nil,
            trackPrice: nil,
            currency: nil
        )
    }
}

struct TopSongGenre: Codable, Sendable {
    let name: String
}
