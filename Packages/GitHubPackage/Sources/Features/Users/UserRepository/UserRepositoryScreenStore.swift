import Foundation
import GitHubCore
import UICore

@MainActor
@Observable
final class UserRepositoryScreenStore {
    let argument: Argument
    private let userReposRepository: UserReposRepository

    private(set) var viewState: LoadingState<[UserRepository]>
    private(set) var nextPage: Page?
    private(set) var selectUrl: URL?
    private(set) var error: Error?

    struct Argument {
        let user: User
    }

    init(
        argument: Argument,
        userReposRepository: UserReposRepository = UserReposDefaultRepository()
    ) {
        self.userReposRepository = userReposRepository
        self.argument = argument
        self.viewState = .idle
        self.nextPage = nil
        self.selectUrl = nil
        self.error = nil
    }
    
    @Sendable func fetchFirstPage() async {
        guard viewState != .loading else { return }

        viewState = .loading

        do {
            let response = try await userReposRepository.fetch(username: argument.user.login)
            
            viewState = .success(response.repositories)
            nextPage = response.nextPage
        } catch {
            viewState = .failure
            self.error = error
        }
    }
    
    @Sendable func fetchNextPage() async {
        guard case .success(let loaded) = viewState, let nextPage else { return }

        do {
            let response = try await userReposRepository.fetch(username: argument.user.login, nextPage: nextPage)
            let newRepositories = loaded + response.repositories

            viewState = .success(newRepositories)
            self.nextPage = response.nextPage
        } catch {
            self.error = error
        }
    }
    
    @Sendable func refresh() async {
        guard viewState != .loading else { return }

        do {
            let response = try await userReposRepository.fetch(username: argument.user.login)
            
            viewState = .success(response.repositories)
            nextPage = response.nextPage
        } catch {
            self.error = error
        }
    }

    func selectRepository(_ repository: UserRepository) {
        do {
            let url = try repository.url
            self.selectUrl = url
        } catch {
            self.error = error
        }
    }
    
    func onErrorAlertDismiss() {
        error = nil
    }
    
    func onSafariDismiss() {
        selectUrl = nil
    }
}
