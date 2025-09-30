import Foundation
import StoreKit
import Combine

@MainActor
final class DonateViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var errorMessage: String?

    private let store: Store
    private var cancellables = Set<AnyCancellable>()

    init(store: Store = Store()) {
        self.store = store

        store.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.products = $0 }
            .store(in: &cancellables)
    }

    func purchase(_ product: Product) async {
        errorMessage = nil
        do {
            _ = try await store.purchase(product)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
