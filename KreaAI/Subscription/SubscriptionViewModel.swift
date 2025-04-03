//
//  SubscriptionViewModel.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI
import Combine
import StoreKit
import ApphudSDK

class SubscriptionViewModel: ObservableObject {
    @Published var isPurchasing = false
    @Published var selectedSubscription: SubscriptionPeriod = .yearly
    @Published var products: [ApphudProduct] = []
    var currentPaywall: ApphudPaywall?
    
    var buyPublisher = PassthroughSubject<Int, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    enum SubscriptionPeriod {
        case weekly
        case yearly
    }
    
    init() {
        buyPublisher
            .sink { _ in
                NotificationCenter.default.post(name: .reloadApp, object: nil)
            }
            .store(in: &cancellables)
    }
    
    @MainActor func purchaseSubscription() {
        guard let selectedPlan = products.first(where: { product in
            guard let skProduct = product.skProduct else { return false }
            let periodUnit = skProduct.subscriptionPeriod?.unit
            return (periodUnit == .year && selectedSubscription == .yearly) ||
                   (periodUnit == .week && selectedSubscription == .weekly)
        }) else {
            print("Selected product not found")
            return
        }
        
        isPurchasing = true
        startPurchase(product: selectedPlan) { [weak self] success in
            DispatchQueue.main.async {
                self?.isPurchasing = false
                if success {
                    print("Purchase successful!")
                } else {
                    print("Purchase failed")
                }
            }
        }
    }
    
    @MainActor private func startPurchase(product: ApphudProduct, escaping: @escaping (Bool) -> Void) {
        Apphud.purchase(product) { result in
            if let error = result.error {
                print(error.localizedDescription)
                escaping(false)
                return
            }
            if let subscription = result.subscription, subscription.isActive() {
                self.buyPublisher.send(1)
                escaping(true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                self.buyPublisher.send(1)
                escaping(true)
            } else if Apphud.hasActiveSubscription() {
                self.buyPublisher.send(1)
                escaping(true)
            } else {
                escaping(false)
            }
        }
    }
    
    @MainActor func restorePurchases(completion: @escaping (Bool) -> Void) {
        print("Starting restore purchases...")
        Apphud.restorePurchases { subscriptions, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Restore failed: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                if subscriptions?.first?.isActive() == true || Apphud.hasActiveSubscription() {
                    self.buyPublisher.send(1)
                    print("Restore successful!")
                    completion(true)
                } else {
                    print("No active subscriptions found to restore")
                    completion(false)
                }
            }
        }
    }
}

extension Notification.Name {
    static let reloadApp = Notification.Name("reloadApp")
}
