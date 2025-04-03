//
//  SettingsViewModel.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import Foundation
import SwiftUI
import StoreKit
import UserNotifications

class SettingsViewModel: ObservableObject {
    @Published var isPremiumUnlocked: Bool = false
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            updateNotificationSettings()
        }
    }
    
    private let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/1mOa5eM4uNk90QoexRb-6NjTBhEWBi6_GEFkrxR44t5A/edit?usp=sharing")!
    private let termsAndConditionsURL = URL(string: "https://docs.google.com/document/d/1_KQp4a87-GM38omlAIOXPJYSgslxoLc2_AX2PJZglqw/edit?usp=sharing")!
    private let supportURL = URL(string: "https://docs.google.com/forms/d/1_0ArhDdfbyCcwqsuGkPiqS3h77crDwtM7d93zLKS2k8/edit")!
    
    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        if UserDefaults.standard.object(forKey: "notificationsEnabled") == nil {
            self.notificationsEnabled = false
        }
    }
    
    func unlockPremium() {
        isPremiumUnlocked = true
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/us/app/6743793678")!
        let activityController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }
    
    func restorePurchase() {
        print("Restoring purchases...")
    }
    
    func getPrivacyPolicyURL() -> URL {
        return privacyPolicyURL
    }
    
    func getTermsAndConditionsURL() -> URL {
        return termsAndConditionsURL
    }
    
    func getSupportURL() -> URL {
        return supportURL
    }
    
    private func updateNotificationSettings() {
        if notificationsEnabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        print("Notifications enabled")
                    } else {
                        self.notificationsEnabled = false
                        UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                        print("Notification permission denied")
                    }
                    if let error = error {
                        print("Error requesting notifications: \(error)")
                    }
                }
            }
        } else {
            print("Notifications disabled")
        }
    }
}
