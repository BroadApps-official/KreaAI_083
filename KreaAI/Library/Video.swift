//
//  Video.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import Foundation

struct Videos {
    let url: URL
}

struct APIResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [Generation]
}

struct Generation: Codable {
    let id: Int
    let status: Int
    let prompt: String?
    let photo: String
    let result: String?
}

struct Video: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: String
    let thumbnailURL: String
    let photoResult: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case thumbnailURL
        case photoResult = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled"
        thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? "N/A"
        photoResult = try container.decode(String.self, forKey: .photoResult)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(thumbnailURL, forKey: .thumbnailURL)
        try container.encode(photoResult, forKey: .photoResult)
    }
    
    init(id: UUID, title: String, date: String, thumbnailURL: String, photoResult: String) {
        self.id = id
        self.title = title
        self.date = date
        self.thumbnailURL = thumbnailURL
        self.photoResult = photoResult
    }
}
