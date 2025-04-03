//
//  StylesView.swift
//  KreaAI
//
//  Created by Денис Николаев on 27.03.2025.
//

import SwiftUI
import Foundation

struct StylesView: View {
    @StateObject private var viewModel = StylesViewModel()
    @Environment(\.dismiss) var dismiss
    var onStyleSelected: (Style) -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#161616").ignoresSafeArea()
            ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.styles) { style in
                            Button(action: {
                                onStyleSelected(style)
                                dismiss()
                            }) {
                                VStack {
                                    Image(style.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 115)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        
                                    Text(style.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Styles")
                        .font(.custom("NanumMyeongjo", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                viewModel.fetchStyles()
            }
        }
    }
}


