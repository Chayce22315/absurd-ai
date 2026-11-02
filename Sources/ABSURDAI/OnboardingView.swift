import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var page = 0
    let pages: [(String, String, [Color])] = [
        ("Welcome to ABSURD AI", "Your all-in-one multi-model AI operating system.", [.purple, .blue]),
        ("Multi-Model Intelligence", "Switch between ABSURD, Ollama, and custom providers.", [.blue, .cyan]),
        ("Agent Headquarters", "Spawn planners, coders, testers, and reviewers.", [.purple, .pink]),
        ("Remote Computing", "Control your PC from your iPhone.", [.indigo, .purple]),
        ("Ready to Begin", "Connect a provider and start creating.", [.purple, .blue])
    ]

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 24) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: icon(for: i))
                                .font(.system(size: 72))
                                .foregroundStyle(LinearGradient(colors: pages[i].2, startPoint: .top, endPoint: .bottom))
                                .symbolEffect(.bounce, value: page)
                            Text(pages[i].0).font(.title).bold().multilineTextAlignment(.center)
                            Text(pages[i].1).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                            Spacer()
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                HStack {
                    Button("Skip") { hasOnboarded = true }.buttonStyle(.plain)
                    Spacer()
                    Button(page == pages.count - 1 ? "Get Started" : "Next") {
                        if page == pages.count - 1 { hasOnboarded = true } else { withAnimation { page += 1 } }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }

    func icon(for i: Int) -> String {
        ["sparkles", "cpu", "person.3", "desktopcomputer", "arrow.right.circle"][i]
    }
}