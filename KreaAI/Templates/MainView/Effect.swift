//
//  Effect.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI
import AVKit
import PhotosUI
import UniformTypeIdentifiers

// Effect.swift
struct Effect: Identifiable, Codable {
    let id: Int
    let name: String
    let imageUrl: String
    let previewSmall: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case imageUrl = "preview"
        case previewSmall = "preview_small"
    }
}

struct EffectSection: Identifiable {
    let id = UUID()
    let title: String
    let effects: [Effect]
}

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

struct FilterResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [Effect]
}

struct IdentifiableURL: Identifiable {
    let id = UUID() // Unique identifier
    let url: URL
}

// VideoResultView
struct VideooResultView: View {
    let videoURL: URL
    
    var body: some View {
        ZStack {
            Color(hex: "#161616").ignoresSafeArea()
            VStack {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(20)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Generated Video")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EffectDetailView: View {
    let effect: Effect
    
    @State private var player: AVPlayer? = nil
    @State private var showSourcePicker = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showDocumentPicker = false
    @State private var selectedImage: UIImage?
    @State private var isGenerating = false
    @State private var generatedVideoURL: IdentifiableURL?
    @State private var showLoadView = false
    @State private var generationStatus = ""
    @State private var showSubscriptionSheet = false // New state for subscription sheet
    @StateObject private var subscriptionManager = SubscriptionManager() // Add subscription manager
    @StateObject private var appState = AppStateManager()
    var body: some View {
        ZStack {
            Color(hex: "#161616").ignoresSafeArea()
            VStack {
                if let url = URL(string: effect.previewSmall) {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(20)
                        .padding()
                        .onAppear {
                            let avPlayer = AVPlayer(url: url)
                            avPlayer.play()
                            self.player = avPlayer
                        }
                        .onDisappear {
                            player?.pause()
                        }
                        .disabled(true)
                } else {
                    Image(systemName: "video")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.gray)
                        .cornerRadius(20)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    if subscriptionManager.hasSubscription {
                        impactFeedback.impactOccurred()
                        showSourcePicker = true
                        appState.incrementVideoGeneration()
                    } else {
                        impactFeedback.impactOccurred()
                        showSubscriptionSheet = true
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                        Text(isGenerating ? "Generating..." : "Generate")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGenerating ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                }
                .disabled(isGenerating)
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(effect.name)
                        .font(.custom("NanumMyeongjo", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $showSourcePicker) {
                ActionSheet(
                    title: Text("Choose Source"),
                    message: Text("Select a source to provide an image."),
                    buttons: [
                        .default(Text("Photo Gallery")) { showPhotoPicker = true },
                        .default(Text("Camera")) { showCamera = true },
                        .default(Text("Documents")) { showDocumentPicker = true },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil { generateVideo() }
                    }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil { generateVideo() }
                    }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil { generateVideo() }
                    }
            }
            .fullScreenCover(isPresented: $showLoadView) {
                Loadview()
            }
            .fullScreenCover(item: $generatedVideoURL) { identifiableURL in
                VideooResultView(videoURL: identifiableURL.url)
            }
            .fullScreenCover(isPresented: $showSubscriptionSheet) {
                SubscriptionSheet(viewModel: SubscriptionViewModel())
            }
        }
    }
    
    private func generateVideo() {
        guard let image = selectedImage else { return }
        isGenerating = true
        showLoadView = true
        generationStatus = "Starting generation..."
        
        Task {
            do {
                let videoURL = try await uploadImageAndGenerateVideo(image: image)
                await MainActor.run {
                    generatedVideoURL = IdentifiableURL(url: videoURL)
                    isGenerating = false
                    showLoadView = false
                }
            } catch {
                await MainActor.run {
                    generationStatus = "Error: \(error.localizedDescription)"
                    isGenerating = false
                    // Keep LoadView visible to show error; user can dismiss manually
                }
            }
        }
    }
    
    private func uploadImageAndGenerateVideo(image: UIImage) async throws -> URL {
        var manager = Manager.shared
        let baseURL = "https://futuretechapps.shop"
        
        guard let url = URL(string: "\(baseURL)/generate") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(manager.token)", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"appId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(manager.appId)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(manager.userId)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"filter_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(effect.id)\r\n".data(using: .utf8)!)
        
        guard let compressedImageData = compressImage(image: image) else {
            throw URLError(.cannotCreateFile)
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(compressedImageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONDecoder().decode(GenerateResponse.self, from: data)
        guard let videoURLString = json.data.result else {
            throw URLError(.cannotParseResponse)
        }
        
        guard let videoURL = URL(string: videoURLString) else {
            throw URLError(.badURL)
        }
        
        return videoURL
    }
    
    private func compressImage(image: UIImage) -> Data? {
        let maxDimension: CGFloat = 1920
        let size = image.size
        let scale: CGFloat = {
            if size.width > size.height {
                return min(maxDimension / size.width, 1.0)
            } else {
                return min(maxDimension / size.height, 1.0)
            }
        }()
        
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage = resizedImage else { return nil }
        
        let initialQuality: CGFloat = 0.8
        let minQuality: CGFloat = 0.1
        let targetSize: Int = 500 * 1024
        
        var quality = initialQuality
        var imageData = finalImage.jpegData(compressionQuality: quality)
        
        while let data = imageData, data.count > targetSize && quality > minQuality {
            quality -= 0.1
            imageData = finalImage.jpegData(compressionQuality: quality)
        }
        
        return imageData
    }
}

struct GenerateData: Codable {
    let id: Int
    let status: Int
    let prompt: String?
    let photo: String
    let result: String?
}

// Обновленная структура GenerateResponse
struct GenerateResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: GenerateData
}

// EffectListView
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
                                        ForEach(section.effects) { effect in
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

struct EffectGridView: View {
    let section: EffectSection
    
    var body: some View {
        ZStack {
            Color(hex: "#161616").ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(section.effects) { effect in
                        NavigationLink(destination: EffectDetailView(effect: effect)) {
                            EffectCardd(effect: effect)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(section.title)
                        .font(.custom("NanumMyeongjo", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
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

struct EffectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EffectDetailView(effect: Effect(id: 3, name: "Dancing Baby", imageUrl: "", previewSmall: "https://cdn.hailuoai.video/open-hailuo-video-web/public_assets/compressed_Dancingbaby.mp4"))
                .preferredColorScheme(.dark)
        }
    }
}

