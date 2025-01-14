import SwiftUI

enum UserRepositoryBuilder {
    @MainActor
    static func build(with user: User) -> UserRepositoryScreen {
        .init(store: .init(
            userRepositoryFetchInteractor: UserRepositoryFetchInteractor(),
            user: user
        ))
    }
}
