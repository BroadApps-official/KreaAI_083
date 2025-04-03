//
//  KreaAIApp.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

@main
struct KreaAIApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var manager = Manager.shared
    init() {
        Apphud.start(apiKey: "app_GhtbAprGvwhaqCBSwc63Pt6K54Yks8") { result in
            let apphudUserId = Apphud.userID()
            Manager.shared.updateUserId(apphudUserId)
        }
        fetchIDFA()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .sheet(isPresented: $appState.shouldShowFeedback) {
                    FeedbackView()
                        .environmentObject(appState)
                }
        }
    }
}

func fetchIDFA() {
    if #available (iOS 14.5, *) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                guard status == .authorized else { return }
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
            }
        }
    }
}
