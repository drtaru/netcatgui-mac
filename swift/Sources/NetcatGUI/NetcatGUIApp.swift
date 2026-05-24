import SwiftUI

@main
struct NetcatGUIApp: App {
    @StateObject private var bookmarkStore = BookmarkStore()

    var body: some Scene {
        WindowGroup("NetCat GUI") {
            ContentView()
                .environmentObject(bookmarkStore)
        }
        .windowResizability(.contentSize)
    }
}
