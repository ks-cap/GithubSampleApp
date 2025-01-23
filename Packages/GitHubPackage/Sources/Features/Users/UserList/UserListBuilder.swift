import UseCase

package enum UserListBuilder {
    @MainActor
    package static func build() -> UserListScreen {
        .init(store: .init(usersFetchUseCase: UsersFetchInteractor()))
    }
}
