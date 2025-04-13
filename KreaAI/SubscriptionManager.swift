//
//  SubscriptionManager.swift
//  KreaAI
//
//  Created by Денис Николаев on 02.04.2025.
//

import SwiftUI
import ApphudSDK

class SubscriptionManager: ObservableObject {
    @Published var hasSubscription = false
    @Published var isLoading = true
    
    init() {
        hasSubscription = Apphud.hasActiveSubscription()
    }
    
    @MainActor func checkSubscriptionStatus() async {
        hasSubscription = Apphud.hasActiveSubscription()
        if let subscriptions = Apphud.subscriptions() {
            hasSubscription = !subscriptions.isEmpty
        }
        print("Subscription status: \(hasSubscription)")
        isLoading = false
    }
}
