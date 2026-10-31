import SwiftUI

struct ModelsView: View {
    @EnvironmentObject var state: AppState
    @State private var query: String = ""
    @State private var category: String = "All"
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Category", selection: $category) {
                    Text("All").tag("All")
                    ForEach(SampleData.providers, id: \.self) { p in Text(p).tag(p) }
                }.pickerStyle(.segmented).padding()
                List {
                    Section("Recently Used") {
                        ForEach(SampleData.models.filter { $0.recent }) { m in modelRow(m) }
                    }
                    Section("All Models") {
                        ForEach(SampleData.models.filter { category == "All" || $0.provider == category }.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }) { m in modelRow(m) }
                    }
                }
            }
            .searchable(text: $query)
            .navigationTitle("Model Selector")
            .toolbar {
                Button("Auto") { state.selectedModel = "auto" }
            }
        }
    }
    func modelRow(_ m: AIModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(m.name).bold()
                    if m.auto { Text("Auto").font(.caption2).padding(4).background(.purple.opacity(0.2)).clipShape(Capsule()) }
                    if m.recent { Text("Recent").font(.caption2).padding(4).background(.gray.opacity(0.2)).clipShape(Capsule()) }
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

extension SampleData {
    static let providers = ["ABSURD","OpenAI-like","Anthropic-like","Google-like","Meta-like","DeepSeek-like","Mistral-like"]
}