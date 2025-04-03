//
//  VideoResultView.swift
//  KreaAI
//
//  Created by Денис Николаев on 26.03.2025.
//

import SwiftUI
import AVKit
import PhotosUI
import AVFoundation
import StoreKit

class VideoViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var video: Videos? = nil
    @Published var player: AVPlayer? = nil
    @Published var error: Error? = nil
    @Published var isSharing: Bool = false
    
    func fetchVideo(from urlString: String) {
        guard let url = URL(string: urlString) else {
            self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        isLoading = true
        self.video = Videos(url: url)
        self.player = AVPlayer(url: url)
        self.player?.play()
        self.isLoading = false
    }
    
    func downloadVideoAndShare(from url: URL) {
        isSharing = true
        URLSession.shared.downloadTask(with: url) { [weak self] (tempURL, response, error) in
            guard let self = self, let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async {
                    self?.isSharing = false
                    self?.error = error
                }
                return
            }
            
            let mp4URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            do {
                try FileManager.default.moveItem(at: tempURL, to: mp4URL)
                
                let activityController = UIActivityViewController(activityItems: [mp4URL], applicationActivities: nil)
                DispatchQueue.main.async {
                    self.isSharing = false
                    UIApplication.shared.windows.first?.rootViewController?.present(activityController, animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSharing = false
                    self.error = error
                }
            }
        }.resume()
    }
    
    func saveToGallery(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Photo Library access denied"])))
                return
            }
            
            URLSession.shared.downloadTask(with: url) { (tempURL, _, error) in
                guard let tempURL = tempURL, error == nil else {
                    completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download failed"])))
                    return
                }
                
                let mp4URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                do {
                    try FileManager.default.moveItem(at: tempURL, to: mp4URL)
                    
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        let request = PHAssetCreationRequest.forAsset()
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        request.addResource(with: .video, fileURL: mp4URL, options: options)
                    }
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func saveToFiles(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        URLSession.shared.downloadTask(with: url) { (tempURL, _, error) in
            guard let tempURL = tempURL, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download failed"])))
                return
            }
            
            let mp4URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            do {
                try FileManager.default.moveItem(at: tempURL, to: mp4URL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteVideo(url: URL) {
        self.video = nil
        self.player = nil
    }
}


// MARK: - VideoResultView
struct VideoResultView: View {
    @StateObject private var viewModel = VideoViewModel()
    let videoURLString: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showRatingPrompt = false
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("")
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(.white)
                } else if let _ = viewModel.video {
                    VideoPlayer(player: viewModel.player)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(20)
                        .padding()
                        .disabled(true)
                } else if let error = viewModel.error {
                    Spacer()
                    ProgressView("The generation is not over yet...")
                }
                
                Spacer()
                
                Button(action: {
                    if let video = viewModel.video {
                        viewModel.downloadVideoAndShare(from: video.url)
                        impactFeedback.impactOccurred()
                    }
                }) {
                    Text("\(Image(systemName: "square.and.arrow.up")) Save")
                        .font(.system(size: 14))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0080FF"))
                        .cornerRadius(32)
                        .padding(.horizontal, 16)
                }
                .disabled(viewModel.isSharing)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Result")
                        .font(.custom("NanumMyeongjo", size: 20))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.isLoading && viewModel.video != nil {
                        Menu {
                            Button(role: .cancel, action: {
                                if let video = viewModel.video {
                                    viewModel.saveToGallery(url: video.url) { result in
                                        handleResult(result, successMessage: "Video saved to gallery")
                                    }
                                }
                            }) {
                                Label("Save to Gallery", systemImage: "arrow.down.to.line")
                            }
                            
                            Button(role: .cancel, action: {
                                if let video = viewModel.video {
                                    viewModel.saveToFiles(url: video.url) { result in
                                        handleResult(result, successMessage: "Video saved to files")
                                    }
                                }
                            }) {
                                Label("Save to Files", systemImage: "folder")
                            }
                            
                            Button(role: .destructive, action: {
                                if let video = viewModel.video {
                                    viewModel.deleteVideo(url: video.url)
                                    alertMessage = "Video deleted"
                                    showingAlert = true
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchVideo(from: videoURLString)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onChange(of: showRatingPrompt) { newValue in
                if newValue {
                    requestReview()
                    showRatingPrompt = false
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    private func handleResult(_ result: Result<Void, Error>, successMessage: String) {
        switch result {
        case .success:
            alertMessage = successMessage
            showingAlert = true
        case .failure(let error):
            alertMessage = "Error: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    VideoResultView(videoURLString: "")
}
