import SwiftUI

struct CreateView: View {
    @EnvironmentObject var state: AppState
    @State private var showNew: Bool = false
    @State private var selectedProject: Project? = nil
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Creation Studio").font(.title2).bold()
                        Spacer()
                        Button("New Project") { showNew = true }.buttonStyle(.borderedProminent)
                    }
                    Text("Templates").font(.headline)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(["iOS App","Website","Game","Script","Document","Other"], id: \.self) { t in
                            Button(t) { showNew = true }.buttonStyle(.bordered)
                        }
                    }
                    Text("Recent Projects").font(.headline)
                    ForEach(state.projects) { p in
                        VStack(alignment: .leading) {
                            HStack { Text(p.name).bold(); Spacer(); Text("\(Int(p.progress*100))%").font(.caption) }
                            Text("\(p.category) · \(p.files) files").font(.caption).foregroundStyle(.secondary)
                            ProgressView(value: p.progress)
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture { selectedProject = p }
                    }
                    Text("Categories").font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SampleData.projectCategories, id: \.self) { c in
                                Text(c).font(.caption).padding(8).background(.gray.opacity(0.12)).clipShape(Capsule())
                            }
                        }
                    }
                }.padding()
            }
            .navigationTitle("Create")
            .sheet(isPresented: $showNew) { NewProjectView() }
            .sheet(item: $selectedProject) { p in ProjectDetailView(project: p) }
        }
    }
}

struct NewProjectView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var category: String = SampleData.projectCategories[0]
    var body: some View {
        NavigationStack {
            Form {
                TextField("Project name", text: $name)
                Picker("Category", selection: $category) {
                    ForEach(SampleData.projectCategories, id: \.self) { Text($0) }
                }
                Button("Create") {
                    guard !name.isEmpty else { return }
                    state.projects.insert(Project(id: "p\(Date().timeIntervalSince1970)", name: name, category: category, updated: "now", progress: 0, files: 0), at: 0)
                    dismiss()
                }.buttonStyle(.borderedProminent)
            }
            .navigationTitle("New Project")
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    @State private var tab: Int = 0
    var body: some View {
        NavigationStack {
            VStack {
                Text(project.name).font(.title2).bold()
                Text("\(project.category) · \(project.files) files").font(.caption).foregroundStyle(.secondary)
                ProgressView(value: project.progress)
                Picker("Tab", selection: $tab) {
                    Text("Files").tag(0); Text("Tasks").tag(1); Text("Chat").tag(2); Text("History").tag(3)
                }.pickerStyle(.segmented).padding()
                if tab == 0 {
                    List(["README.md","src/App.swift","Package.swift"], id: \.self) { Text("📄 \($0)") }
                } else if tab == 1 {
                    List(["Set up project","Design UI","Implement features","Write tests"], id: \.self) { Text("☐ \($0)") }
                } else if tab == 2 {
                    VStack { Text("Project conversation (simulated)").foregroundStyle(.secondary); TextField("Message...", text: .constant("")).textFieldStyle(.roundedBorder) }
                        .padding()
                } else {
                    VStack(alignment: .leading) { Text("• Project created"); Text("• Files scaffolded"); Text("• Last edited 3h ago") }.font(.caption).foregroundStyle(.secondary).padding()
                }
            }
            .padding()
            .navigationTitle(project.name)
        }
    }
}

extension SampleData {
    static let projectCategories = ["iOS applications","Windows applications","Websites","Games","Scripts","Documents","Other creative projects"]
}