import SwiftUI

struct ModelsView: View {
    @EnvironmentObject var state: AppState
    @State private var query: String = ""
    @State private var category: String = "All"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var models: [AIModel] {
        state.providerModels.isEmpty ? SampleData.models : state.providerModels
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Category", selection: $category) {
                    Text("All").tag("All")
                    ForEach(SampleData.providers, id: \.self) { p in Text(p).tag(p) }
                }.pickerStyle(.segmented).padding()
                if isLoading {
                    ProgressView().padding()
                }
                if let err = errorMessage {
                    Text(err).foregroundStyle(.red).font(.caption).padding()
                }
                List {
                    Section("Recently Used") {
                        ForEach(models.filter { $0.recent }) { m in modelRow(m) }
                    }
                    Section("All Models") {
                        ForEach(models.filter { category == "All" || $0.provider == category }.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }) { m in modelRow(m) }
                    }
                }
            }
            .searchable(text: $query)
            .navigationTitle("Model Selector")
            .toolbar {
                Button("Fetch") { fetchModels() }
                Button("Auto") { state.selectedModel = "auto" }
            }
            .onAppear { if state.providerModels.isEmpty { fetchModels() } }
        }
    }

    func fetchModels() {
        isLoading = true
        errorMessage = nil
        Task {
            let client = OpenAICompatibleClient(baseURL: state.providerBaseURL, apiKey: state.apiKey)
            do {
                let fetched = try await client.fetchModels()
                await MainActor.run {
                    state.providerModels = fetched
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    func modelRow(_ m: AIModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(m.name).bold()
                    if m.free { Text("Free").font(.caption2).padding(4).background(.green.opacity(0.2)).clipShape(Capsule()) }
                    if m.auto { Text("Auto").font(.caption2).padding(4).background(.purple.opacity(0.2)).clipShape(Capsule()) }
                }
                Text("\(m.provider) · \(m.desc)").font(.caption).foregroundStyle(.secondary)
                HStack { ForEach(m.caps, id: \.self) { Text($0).font(.caption2).padding(4).background(.blue.opacity(0.15)).clipShape(Capsule()) } }
            }
            Spacer()
            if state.selectedModel == m.id { Image(systemName: "checkmark").foregroundStyle(.purple) }
        }
        .contentShape(Rectangle())
        .onTapGesture { state.selectedModel = m.id }
    }
}