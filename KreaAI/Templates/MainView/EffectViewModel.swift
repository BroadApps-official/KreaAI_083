//
//  EffectViewModel.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//


import SwiftUI

@MainActor
class EffectViewModel: ObservableObject {
    @Published var sections: [EffectSection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var manager = Manager.shared
    
    private let service: EffectServiceProtocol
    
    init(service: EffectServiceProtocol = EffectService()) {
        self.service = service
    }
    
    func fetchEffectSections() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedSections = try await service.fetchEffectSections(appId: manager.appId, userId: manager.userId)
            sections = fetchedSections
        } catch {
            errorMessage = "Failed to load effects: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
