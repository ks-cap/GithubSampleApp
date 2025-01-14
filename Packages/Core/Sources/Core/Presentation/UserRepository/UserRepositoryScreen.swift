import SwiftUI

struct UserRepositoryScreen: View {
    @Bindable
    var store: UserRepositoryScreenStore

    var body: some View {
        UserRepositoryScreenContent(
            user: store.user,
            nextPage: store.nextPage,
            repositories: store.repositories,
            onAppear: {
                Task { await store.fetchFirstPage() }
            },
            onBottomReach: {
                Task { await store.fetchNextPage() }
            },
            onRepositoryTap: store.selectRepository(_:),
            error: $store.error,
            url: $store.url
        )
    }
}

struct UserRepositoryScreenContent: View {
    let user: User
    let nextPage: Page?
    let repositories: [UserRepository]

    let onAppear: () -> Void
    let onBottomReach: () -> Void
    let onRepositoryTap: (UserRepository) -> Void

    @Binding var error: AppError?
    @Binding var url: UserRepositoryScreenStore.SelectUrl?

    var body: some View {
        List {
            Section {
                UserRowView(user: user)
            }

            Section("Repository") {
                ForEach(repositories) { repository in
                    UserRepositoryRowView(
                        repository: repository,
                        onTapped: { onRepositoryTap(repository) }
                    )
                }
                
                if nextPage != nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .progressViewStyle(.automatic)
                        .onAppear(perform: onBottomReach)
                }
            }
        }
        .navigationTitle("User")
        .listStyle(.insetGrouped)
        .onAppear(perform: onAppear)
        .fullScreenCover(item: $url) {
            SafariView(url: $0.url)
        }
        .alert(item: $error) {
            Alert(title: Text($0.error.localizedDescription))
        }
    }
}

struct UserRepositoryRowView: View {
    let repository: UserRepository
    let onTapped: () -> Void
    
    var body: some View {
        Button(
            action: onTapped,
            label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(repository.name)
                        .font(.headline)

                    if let description = repository.description {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }

                    HStack {
                        if let language = repository.language {
                            Text(language)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }

                        (Text(Image(systemName: "star")) + Text("\(repository.watchersCount ?? 0)"))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                .foregroundStyle(.black)
            }
        )
    }
}

#Preview {
    let user: User = User(
        id: 1,
        login: "User",
        reposUrl: "https://github.com/sample",
        avatarUrl: "https://placehold.jp/150x150.png"
    )
    
    let repositories: [UserRepository] = (1...10).map { id in
        UserRepository(
            id: id,
            name: "Repository\(id)",
            htmlUrl: "",
            fork: false,
            language: "Swift",
            watchersCount: id,
            description: "description\(id)"
        )
    }

    UserRepositoryScreenContent(
        user: user,
        nextPage: nil,
        repositories: repositories,
        onAppear: {},
        onBottomReach: {},
        onRepositoryTap: { _ in },
        error: .init(get: { nil }, set: { _ in }),
        url: .init(get: { nil }, set: { _ in })
    )
}
