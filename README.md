# MusicFinder

MusicFinder is a SwiftUI iOS application for discovering top songs, searching the iTunes catalog, playing available 30-second previews, and saving favorites locally with SwiftData.

## Run

1. Open `MusicFinder.xcodeproj` in Xcode 15 or newer.
2. Select an iPhone simulator (iOS 17+).
3. Build and run.

No API key is required. Home uses Apple Marketing Tools' public RSS feed, while search, song details, artwork, and previews use the public iTunes Search API.

## Persistence demo

Open any song, tap the heart, then stop and relaunch the app. The song remains on the Favorites tab because it is stored in the local SwiftData container.
