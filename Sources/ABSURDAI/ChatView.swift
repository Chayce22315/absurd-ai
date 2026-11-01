import SwiftUI
import UIKit

struct ChatView: View {
    @EnvironmentObject var state: AppState
    @StateObject private var viewModel = ChatViewModel()
    @State private var showHistory: Bool = false
    @State private var showModel: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("History") { showHistory = true }.buttonStyle(.plain)
                    Spacer()
                    Text(state.selectedModel).foregroundStyle(.purple).font(.caption)
                    Spacer()
                    Button("New") { viewModel.messages = [] }.buttonStyle(.plain)
                }.padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if viewModel.messages.isEmpty {
                            Text("Start a conversation.").foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center).padding(.top, 80)
                        }
                        ForEach(viewModel.messages) { m in
                            HStack {
                                if m.role == "user" { Spacer() }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(m.text)
                                    if m.role == "assistant" && !viewModel.isStreaming {
                                        HStack(spacing: 12) {
                                            Button("Copy") { UIPasteboard.general.string = m.text }
                                            Button("Regenerate") { viewModel.regenerate(state: state) }
                                        }.font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(10)
                                .background(m.role == "user" ? Color.purple : Color.gray.opacity(0.2))
                                .foregroundStyle(m.role == "user" ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                if m.role != "user" { Spacer() }
                            }
                        }
                        if viewModel.isStreaming {
                            ProgressView().padding(.leading)
                        }
                        if let err = viewModel.errorMessage {
                            Text(err).foregroundStyle(.red).font(.caption)
                        }
                    }.padding()
                }

                HStack {
                    TextField("Message...", text: $viewModel.input).textFieldStyle(.roundedBorder)
                    Button("Send") { viewModel.send(state: state) }.buttonStyle(.borderedProminent)
                }.padding()
            }
            .navigationTitle("Chat")
            .onAppear {
                viewModel.configure(baseURL: state.providerBaseURL, apiKey: state.apiKey)
            }
            .sheet(isPresented: $showHistory) {
                List(state.conversations) { c in
                    Button(c.title) { viewModel.messages = c.messages; showHistory = false }
                }
            }
            .sheet(isPresented: $showModel) {
                ModelsView()
            }
        }
    }
}