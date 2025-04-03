//
//  Manager.swift
//  KreaAI
//
//  Created by Денис Николаев on 02.04.2025.
//


import Foundation
import ApphudSDK
import Combine

class Manager: ObservableObject {
    static let shared = Manager()
    
    @Published var isSubscribed: Bool = false
    @Published private(set) var userId: String = ""
    @Published private(set) var token: String = "0e9560af-ab3c-4480-8930-5b6c76b03eea"
    @Published private(set) var paywalls: [ApphudPaywall] = []
    let appName = "com.aid.a1hugc1n"
    let appId = "com.test.test"
    
    private init() {
        
    }
    
    func updateUserId(_ id: String) {
        self.userId = id
    }
}
