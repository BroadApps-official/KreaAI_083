//
//  StylesViewModel.swift
//  KreaAI
//
//  Created by Денис Николаев on 27.03.2025.
//

import SwiftUI
import Combine

class StylesViewModel: ObservableObject {
    @Published var styles: [Style] = []

    func fetchStyles() {
        self.styles = [
            Style(id: "1", name: "SET UP", imageName: "setup"),
            Style(id: "2", name: "Sketch", imageName: "sketch", promt: "Convert video to Sketch style"),
            Style(id: "3", name: "Oil Painting", imageName: "oil", promt: "Convert video to Oil Painting style"),
            Style(id: "4", name: "Anime", imageName: "anime", promt: "Convert video to Anime style"),
            Style(id: "5", name: "Fantasy 3D", imageName: "fantasy3d", promt: "Convert video to Fantasy 3D style"),
            Style(id: "6", name: "Van Gogh", imageName: "vangogh", promt: "Convert video to Van Gogh style"),
            Style(id: "7", name: "Cartoon", imageName: "cartoon", promt: "Convert video to Cartoon style")
        ]
    }
}

