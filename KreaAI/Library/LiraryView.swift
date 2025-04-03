//
//  LibraryView.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI
import AVKit
import AVFoundation

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#161616").ignoresSafeArea()
                if viewModel.videos.isEmpty {
                    VStack {
                        Text("Your videos will appear here")
                            .foregroundColor(.white)
                            .font(.custom("NanumMyeongjo", size: 24))
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Create your first one and make \n something amazing")
                            .foregroundColor(.gray)
                            .font(.custom("NanumMyeongjo", size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        Button(action: {
                            // Add action for the "Start" button, e.g., navigate to a video creation view
                        }) {
                            Text("Start")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#0080FF"))
                                .cornerRadius(25)
                        }
                        .padding(.top, 46)
                        .padding(.horizontal, 50)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(viewModel.videos) { video in
                                VideoThumbnailView(video: video)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                print("Вызываем fetchVideos()")
                viewModel.fetchVideos()
            }
        }
    }
}

struct VideoThumbnailView: View {
    let video: Video
    @State private var thumbnailImage: UIImage? = nil
    @State private var isShowingVideoPlayer = false

    var body: some View {
        VStack {
            ZStack {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                       // .scaledToFill()
                        .frame(height: 170)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    ProgressView()
                        .frame(height: 150)
                }
                
                Text(video.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 5)
                    .padding(.trailing, 5)

                Button(action: {
                    isShowingVideoPlayer = true
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                .background(
                    NavigationLink(
                        destination: VideoResultView(videoURLString: video.thumbnailURL),
                        isActive: $isShowingVideoPlayer
                    ) {
                        EmptyView()
                    }
                    .hidden()
                )
            }

            Text(video.date)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            print("Загружаем миниатюру для: \(video.photoResult)")
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        guard let url = URL(string: video.photoResult) else {
            print("Неверный URL миниатюры: \(video.photoResult)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка загрузки: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let image = UIImage(data: data) else {
                print("Неверный ответ сервера или данные: \(String(describing: response))")
                return
            }
            
            DispatchQueue.main.async {
                self.thumbnailImage = image
                print("Миниатюра успешно загружена для: \(video.photoResult)")
            }
        }.resume()
    }
}
