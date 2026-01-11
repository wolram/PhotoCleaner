import SwiftUI
import SwiftData

struct MainSidebar: View {
    @EnvironmentObject private var appState: AppState
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "duplicate" })
    private var duplicateGroups: [PhotoGroupEntity]
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "similar" })
    private var similarGroups: [PhotoGroupEntity]

    var body: some View {
        List(selection: $appState.selectedDestination) {
            Section("Library") {
                NavigationLink(value: NavigationDestination.library) {
                    Label("All Photos", systemImage: "photo.on.rectangle")
                }

                NavigationLink(value: NavigationDestination.scan) {
                    Label {
                        HStack {
                            Text("Scan")
                            Spacer()
                            if appState.isScanning {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }

            Section("Cleanup") {
                NavigationLink(value: NavigationDestination.duplicates) {
                    Label {
                        HStack {
                            Text("Duplicates")
                            Spacer()
                            if !duplicateGroups.isEmpty {
                                Text("\(duplicateGroups.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.red.opacity(0.2))
                                    .foregroundStyle(.red)
                                    .clipShape(Capsule())
                            }
                        }
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }

                NavigationLink(value: NavigationDestination.similar) {
                    Label {
                        HStack {
                            Text("Similar")
                            Spacer()
                            if !similarGroups.isEmpty {
                                Text("\(similarGroups.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.orange.opacity(0.2))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                            }
                        }
                    } icon: {
                        Image(systemName: "square.stack.3d.up")
                    }
                }

                NavigationLink(value: NavigationDestination.quality) {
                    Label("Quality", systemImage: "sparkles")
                }

                NavigationLink(value: NavigationDestination.battle) {
                    Label {
                        HStack {
                            Text("Battle")
                            Spacer()
                            Text("FUN")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.purple.opacity(0.2))
                                .foregroundStyle(.purple)
                                .clipShape(Capsule())
                        }
                    } icon: {
                        Image(systemName: "gamecontroller")
                    }
                }
            }

            Section("Organize") {
                NavigationLink(value: NavigationDestination.categories) {
                    Label {
                        HStack {
                            Text("Categories")
                            Spacer()
                            Text("SOON")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.2))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    } icon: {
                        Image(systemName: "folder")
                    }
                }
            }

            if appState.spaceRecoverable > 0 {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Space Recoverable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(appState.formatBytes(appState.spaceRecoverable))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("PhotoCleaner")
        .toolbar {
            ToolbarItem {
                Button {
                    // Open settings
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
    }
}

#Preview {
    MainSidebar()
        .environmentObject(AppState())
        .frame(width: 250)
}
