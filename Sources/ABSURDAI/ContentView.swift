import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ChatView()
                .tabItem { Label("Chat", systemImage: "message") }
            CreateView()
                .tabItem { Label("Create", systemImage: "plus.square") }
            AgentsView()
                .tabItem { Label("Agents", systemImage: "cpu") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .tint(Color(red: 0.49, green: 0.36, blue: 1.0))
    }
}