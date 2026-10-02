import SwiftUI

struct RootTabView: View {
    @StateObject private var player = AudioPreviewPlayer()

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "sparkles") }

            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack { FavoritesView() }
                .tabItem { Label("Favorites", systemImage: "heart.fill") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(FinderStyle.accent)
        .environmentObject(player)
    }
}

enum FinderStyle {
    static let accent = Color(red: 0.78, green: 0.24, blue: 0.12)
    static let paper = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.09, blue: 0.08, alpha: 1)
            : UIColor(red: 0.97, green: 0.96, blue: 0.93, alpha: 1)
    })
}

struct EditorialHeading: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow.uppercased()).font(.caption2.monospaced().weight(.semibold))
                .tracking(3).foregroundStyle(FinderStyle.accent)
            Text(title).font(.system(.largeTitle, design: .serif).weight(.bold))
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24).padding(.vertical, 20)
    }
}

struct RecordArtwork: View {
    let url: URL?
    var playing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !playing || reduceMotion)) { context in
            ZStack {
                Circle().fill(Color(white: 0.09))
                ForEach(0..<12) { groove in
                    Circle().stroke(.white.opacity(0.08), lineWidth: 1)
                        .padding(CGFloat(8 + groove * 6))
                }
                GeometryReader { geometry in
                    ArtworkView(url: url, cornerRadius: 0)
                        .frame(width: geometry.size.width * 0.43, height: geometry.size.height * 0.43)
                        .clipShape(Circle())
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                Circle().fill(FinderStyle.paper).frame(width: 10, height: 10)
            }
            .rotationEffect(.degrees(playing && !reduceMotion ? context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 18) * 20 : 0))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
