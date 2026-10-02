import Foundation
import SwiftData

@Model
final class FavoriteSong {
    @Attribute(.unique) var trackID: Int
    var title: String
    var artist: String
    var album: String?
    var artworkURL: String?
    var previewURL: String?
    var storeURL: String?
    var genre: String?
    var releaseDate: String?
    var durationMilliseconds: Int?
    var dateAdded: Date

    init(song: Song) {
        trackID = song.trackId
        title = song.trackName
        artist = song.artistName
        album = song.collectionName
        artworkURL = song.artworkUrl100
        previewURL = song.previewUrl
        storeURL = song.trackViewUrl
        genre = song.primaryGenreName
        releaseDate = song.releaseDate
        durationMilliseconds = song.trackTimeMillis
        dateAdded = .now
    }

    var song: Song {
        Song(
            trackId: trackID,
            trackName: title,
            artistName: artist,
            collectionName: album,
            artworkUrl100: artworkURL,
            previewUrl: previewURL,
            trackViewUrl: storeURL,
            primaryGenreName: genre,
            releaseDate: releaseDate,
            trackTimeMillis: durationMilliseconds,
            trackPrice: nil,
            currency: nil
        )
    }
}
