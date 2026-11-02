import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house.fill") }
            ChatView().tabItem { Label("Chat", systemImage: "message.fill") }
            CreateView().tabItem { Label("Create", systemImage: "plus.square.fill") }
            AgentsView().tabItem { Label("Agents", systemImage: "cpu.fill") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.purple)
        .background(AnimatedBackground().ignoresSafeArea())
    }
}