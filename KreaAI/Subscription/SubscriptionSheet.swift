//
//  SubscriptionSheet.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI
import StoreKit
import ApphudSDK

struct SubscriptionSheet: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var subscriptionPlans: [SubscriptionPlan] = []
    @State private var showCloseButton = false
    @State private var showingTerms = false
    @State private var showingPrivacyPolicy = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            Image("paywall")
                                .resizable()
                                .scaledToFill()
                                .frame(maxHeight: geometry.size.height * 0.45)
                                .clipped()
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: geometry.size.height * 0.15)
                            
                            
                            
                        }
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                            VStack {
                                Text("Unlock Your Full Potential!")
                                    .font(.custom("NanumMyeongjoBold", size: min(24, geometry.size.width * 0.07)))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                    .bold()
                            }
                            .padding(.bottom, 8)
                            ForEach(["Unlimited access to all effects and styles", "Exclusive filters and presets", "Faster video processing with no delays"], id: \.self) { text in
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "#7058F7"))
                                    Text(text)
                                        .foregroundColor(.white)
                                        .bold()
                                        .font(.system(size: min(16, geometry.size.width * 0.04)))
                                }
                            }
                        }
                        .padding(.vertical, geometry.size.height * 0.02)
                        .padding(.horizontal, 29)
                        
                        
                        VStack(spacing: geometry.size.height * 0.02) {
                            ForEach($subscriptionPlans) { $plan in
                                Button(action: {
                                    subscriptionPlans.indices.forEach { subscriptionPlans[$0].isSelected = false }
                                    if let index = subscriptionPlans.firstIndex(where: { $0.id == plan.id }) {
                                        subscriptionPlans[index].isSelected = true
                                        viewModel.selectedSubscription = plan.period == "Year" ? .yearly : .weekly
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                                            .foregroundColor(plan.isSelected ? Color(hex: "#0080FF") : .clear)
                                            .overlay(Circle().stroke(Color(hex: "#0080FF"), lineWidth: plan.isSelected ? 2 : 1))
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(plan.price)
                                                .foregroundColor(.white)
                                                .bold()
                                                .font(.system(size: min(24, geometry.size.width * 0.035)))
                                                
                                        +
                                            Text(" / \(plan.period)")
                                                .foregroundColor(.white)
                                                .bold()
                                                .font(.system(size: min(24, geometry.size.width * 0.04)))
                                           
                                                
                                                Text("Auto-renewable. Cancel anytime")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: min(14, geometry.size.width * 0.035)))
                                            
                                        }
                                        .padding(.leading, 15)
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 5) {
                                            
                                        }
                                        .padding(.trailing, 32)
                                    }
                                    .padding()
                                    .background(Color(hex: "#201F1F"))
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#0080FF"), lineWidth: plan.isSelected ? 2 : 0))
                                    
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            viewModel.purchaseSubscription()
                        }) {
                            Text("Get Access")
                                .font(.system(size: min(17, geometry.size.width * 0.045)))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#0080FF"))
                                .cornerRadius(24)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, geometry.size.height * 0.03)
                        .disabled(viewModel.isPurchasing)
                        .opacity(viewModel.isPurchasing ? 0.5 : 1.0)
                        
                        
                        
                        HStack(spacing: geometry.size.width * 0.05) {
                            
                            Button(action: {
                                showingTerms = true
                            }) {
                                Text("Terms")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .fullScreenCover(isPresented: $showingTerms) {
                                TermsAndConditionsView()
                            }

                            Button(action: {
                                showingPrivacyPolicy = true
                            }) {
                                Text("Privacy Policy")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .fullScreenCover(isPresented: $showingPrivacyPolicy) {
                                PrivacyPolicyView()
                            }
                            
                            Button(action: {
                                viewModel.restorePurchases { success in
                                    if success {
                                        print("Purchases restored successfully")
                                    } else {
                                        print("Failed to restore purchases")
                                    }
                                }
                            }) {
                                Text("Restore")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .padding(.top, geometry.size.height * 0.03)
                        .padding(.horizontal, 16)
                        
                    }
                }
            }
            .background(Color.black)
            .foregroundColor(.white)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: showCloseButton ? Button(action: {
                closePaywall()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            } : nil)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showCloseButton = true }
                }
                load()
            }
        }
        .background(Color.black)
    }
    
    private func closePaywall() {
        if let unwrappedPaywall = viewModel.currentPaywall {
            Apphud.paywallClosed(unwrappedPaywall)
        }
        dismiss()
    }
    
    private func load() {
        Apphud.paywallsDidLoadCallback { paywalls, _ in
            guard let paywall = paywalls.first(where: { $0.identifier == "main" }) else {
                print("Paywall 'main' not found")
                return
            }
            Apphud.paywallShown(paywall)
            viewModel.currentPaywall = paywall
            
            let products = paywall.products
            guard !products.isEmpty else {
                print("No available products")
                return
            }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            var newPlans: [SubscriptionPlan] = []
            var weeklyPricePerWeek: Double?
            
            for product in products {
                if let skProduct = product.skProduct, skProduct.subscriptionPeriod?.unit == .week {
                    weeklyPricePerWeek = skProduct.price.doubleValue
                    break
                }
            }
            
            for product in products.reversed() {
                guard let skProduct = product.skProduct else { continue }
                formatter.locale = skProduct.priceLocale
                
                let priceString = formatter.string(from: skProduct.price) ?? "\(skProduct.price)"
                let periodUnit = skProduct.subscriptionPeriod?.unit
                
                let priceValue = skProduct.price.doubleValue
                let pricePerWeek: String
                let periodString: String
                var discountPercentage: Int? = nil
                
                switch periodUnit {
                case .year:
                    periodString = "Yearly"
                    let weeksInYear = 52.0
                    let weeklyPrice = priceValue / weeksInYear
                    pricePerWeek = formatter.string(from: NSNumber(value: weeklyPrice)) ?? "\(weeklyPrice)"
                    if let weeklyPrice = weeklyPricePerWeek {
                        let yearlyCostAtWeeklyRate = weeklyPrice * weeksInYear
                        let savings = yearlyCostAtWeeklyRate - priceValue
                        discountPercentage = Int((savings / yearlyCostAtWeeklyRate) * 100)
                    }
                case .month:
                    periodString = "Month"
                    let weeksInMonth = 4.33
                    let weeklyPrice = priceValue / weeksInMonth
                    pricePerWeek = formatter.string(from: NSNumber(value: weeklyPrice)) ?? "\(weeklyPrice)"
                case .week:
                    periodString = "Weekly"
                    pricePerWeek = priceString
                default:
                    periodString = "Week"
                    pricePerWeek = priceString
                }
                
                let plan = SubscriptionPlan(
                    period: periodString,
                    price: priceString,
                    pricePerWeek: "\(pricePerWeek)/week",
                    isSelected: periodUnit == .year,
                    apphudProduct: product,
                    discountPercentage: discountPercentage
                )
                newPlans.append(plan)
                print(plan)
            }
            
            DispatchQueue.main.async {
                self.subscriptionPlans = newPlans
                self.viewModel.products = products
            }
        }
    }
}


#Preview {
    SubscriptionSheet(viewModel: SubscriptionViewModel())
}



