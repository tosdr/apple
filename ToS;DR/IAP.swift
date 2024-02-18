//
//  IAP.swift
//  ToS;DR
//
//  Created by Erik on 05.11.23.
//

import StoreKit

class Store: ObservableObject {
    private var productIDs = ["1dollardonation", "5dollardonation", "10dollardonation"]
    @Published var products = [Product]()
    var transacitonListener: Task<Void, Error>?

    init() {
        transacitonListener = listenForTransactions()
           Task {
             await requestProducts()
         }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws -> Transaction? {
      let result =
        try await product.purchase()
      switch result {
        case .success(.verified(let transaction)):
          await transaction.finish()
          return transaction
        default:
          return nil
      }
    }

    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            products = products.sorted(by: { $0.price < $1.price })
        } catch {
            print(error)
    }
  }
    
    func listenForTransactions() -> Task < Void, Error > {
     return Task.detached {
       for await result in Transaction.updates {
         switch result {
           case let.verified(transaction):
             guard
                self.products.first(where: {
                    $0.id == transaction.productID
                }) != nil
             else {
               continue
             }
             await transaction.finish()
           default:
             continue
         }
       }
     }
   }
}
