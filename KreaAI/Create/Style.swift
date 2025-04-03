//
//  Style.swift
//  KreaAI
//
//  Created by Денис Николаев on 27.03.2025.
//

import Foundation

struct Style: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    var promt: String?
}
