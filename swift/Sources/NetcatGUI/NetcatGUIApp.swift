import SwiftUI

@main
struct NetcatGUIApp: App {
    var body: some Scene {
        WindowGroup("NetCat GUI") {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
