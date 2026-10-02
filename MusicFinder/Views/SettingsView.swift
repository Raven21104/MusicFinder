import SwiftUI

struct SettingsView: View {
    @AppStorage("storeCountry") private var storeCountry = "us"
    @AppStorage("resultLimit") private var resultLimit = 25

    private let countries = [
        ("us", "United States"), ("gb", "United Kingdom"), ("au", "Australia"),
        ("ca", "Canada"), ("jp", "Japan"), ("sg", "Singapore"), ("th", "Thailand")
    ]

    var body: some View {
        Form {
            EditorialHeading(eyebrow: "Make yourself at home", title: "Your listening,\nyour way.", subtitle: "A few small adjustments for your next discovery.")
                .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            Section {
                Picker("Storefront", selection: $storeCountry) {
                    ForEach(countries, id: \.0) { country in
                        Text(country.1).tag(country.0)
                    }
                }
                Picker("Results", selection: $resultLimit) {
                    Text("10 songs").tag(10)
                    Text("25 songs").tag(25)
                    Text("50 songs").tag(50)
                }
            } header: {
                Text("Music Catalog")
            } footer: {
                Text("Changes apply the next time Home is refreshed or you perform a search.")
            }

            Section("About") {
                LabeledContent("App", value: "MusicFinder")
                LabeledContent("Version", value: "1.0")
                LabeledContent("Data", value: "Apple Music / iTunes")
            }

            Section {
                Label("Your collection stays on this device, ready when you return.", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(FinderStyle.paper)
    }
}
