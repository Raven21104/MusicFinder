import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioPreviewPlayer: ObservableObject {
    @Published private(set) var playingURL: URL?
    @Published private(set) var isLoading = false

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    func toggle(_ url: URL) {
        if playingURL == url {
            stop()
        } else {
            play(url)
        }
    }

    func stop() {
        player?.pause()
        player = nil
        playingURL = nil
        isLoading = false
        removeEndObserver()
    }

    private func play(_ url: URL) {
        stop()
        isLoading = true
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer
        playingURL = url
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.stop() }
        }
        newPlayer.play()
        isLoading = false
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    deinit {
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    }
}
