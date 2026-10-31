import SwiftUI

@main
struct ABSURDAIApp: App {
    @StateObject private var state = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(state)
        }
    }
}