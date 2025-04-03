//
//  EffectServiceProtocol.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//


//import Foundation
//
//protocol EffectServiceProtocol {
//    func fetchEffectSections() async throws -> [EffectSection]
//}
//
//class EffectService: EffectServiceProtocol {
//    private let urlString = "https://api.example.com/effect_sections" // Замените на реальный URL
//
//    func fetchEffectSections() async throws -> [EffectSection] {
////        guard let url = URL(string: urlString) else {
////            throw URLError(.badURL)
////        }
////
////        let (data, _) = try await URLSession.shared.data(from: url)
////        let sections = try JSONDecoder().decode([EffectSection].self, from: data)
////        return sections
//        return [EffectSection]()
//    }
//}
//
//class MockEffectService: EffectServiceProtocol {
//    func fetchEffectSections() async throws -> [EffectSection] {
//        return Effect.mockData
//    }
//}
