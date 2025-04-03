//
//  SubscriptionPlan.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//


import SwiftUI
import ApphudSDK

struct SubscriptionPlan: Identifiable {
    let id = UUID()
    let period: String
    let price: String
    let pricePerWeek: String
    var isSelected: Bool
    let apphudProduct: ApphudProduct
    let discountPercentage: Int?
}
