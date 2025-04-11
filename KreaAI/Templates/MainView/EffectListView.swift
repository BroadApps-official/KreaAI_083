//
//  EffectListView.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI

struct EffectListView: View {
    @StateObject private var viewModel = EffectViewModel(service: EffectService())
    
    var body: some View {
        ZStack {
            Color(hex: "#161616").ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(viewModel.sections) { section in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(section.title)
                                        .font(.custom("NanumMyeongjo", size: 20))
                                        .fontWeight(.bold)
                                        .padding(.leading, 16)
                                    Spacer()
                                    NavigationLink(destination: EffectGridView(section: section)) {
                                        Text("See All")
                                            .foregroundColor(.white)
                                            .padding(.trailing, 16)
                                            .font(.custom("NanumMyeongjo", size: 14))
                                    }
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        // Filter out effects with name "Share a bad"
                                        ForEach(section.effects.filter { $0.name != "Share a bed" }) { effect in
                                            NavigationLink(destination: EffectDetailView(effect: effect)) {
                                                EffectCard(effect: effect)
                                                    .frame(width: 120, height: 200)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .task {
                await viewModel.fetchEffectSections()
            }
        }
    }
}

struct EffectCard: View {
    let effect: Effect
    
    var body: some View {
        VStack {
            if let url = URL(string: effect.previewSmall) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(width: 120, height: 160)
                    .scaledToFit()
                    .disabled(true)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onAppear {
                        AVPlayer(url: url).play()
                    }
            } else {
                Image(systemName: "video")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 160)
                    .foregroundColor(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            Text(effect.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(.white)
        }
    }
}

struct EffectCardd: View {
    let effect: Effect
    
    var body: some View {
        VStack {
            if let url = URL(string: effect.previewSmall) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(width: 170, height: 180)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .disabled(true)
                    .onAppear {
                        AVPlayer(url: url).play()
                    }
            } else {
                Image(systemName: "video")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 180)
                    .foregroundColor(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            Text(effect.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(.white)
        }
    }
}

