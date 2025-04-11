//
//  EffectServiceProtocol.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import Foundation

protocol EffectServiceProtocol {
    func fetchEffectSections(appId: String, userId: String) async throws -> [EffectSection]
}

class EffectService: EffectServiceProtocol {
    private var manager = Manager.shared
    private let baseURL = "https://futuretechapps.shop"
    private let bearerToken = "0e9560af-ab3c-4480-8930-5b6c76b03eea"
    
    func fetchEffectSections(appId: String, userId: String) async throws -> [EffectSection] {
        guard let url = URL(string: "\(baseURL)/filters?appId=\(appId)&userId=\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(manager.token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(FilterResponse.self, from: data)
        
        let section = EffectSection(title: "Transformation", effects: result.data)
        return [section]
    }
}

