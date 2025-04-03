//
//  SceneView.swift
//  KreaAI
//
//  Created by Денис Николаев on 26.03.2025.
//
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            controller.dismiss(animated: true)
            guard let url = urls.first, let image = UIImage(contentsOfFile: url.path) else { return }
            DispatchQueue.main.async {
                self.parent.selectedImage = image
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
    }
}

// SceneModel: Simple data model for the scene description
struct SceneModel {
    var description: String
}

// Preview provider
struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
    }
}

class SceneViewModel: ObservableObject {
    @Published var scene: SceneModel
    @Published var isStyleSectionVisible: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var selectedVideoURL: URL? = nil
    @Published var showImagePickerOptions: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var showVideoPicker: Bool = false
    @Published var showDocumentPicker: Bool = false
    @Published var generationStatus: String = ""
    @Published var selectedStyle: Style? = nil
    @Published var showCameraPicker: Bool = false
    var manager = Manager.shared
    
    init() {
        self.scene = SceneModel(description: "")
    }
    
    func toggleStyleSection() {
        isStyleSectionVisible.toggle()
        if isStyleSectionVisible {
            selectedImage = nil
            selectedVideoURL = nil
        }
    }
    
    private func compressImage(_ image: UIImage, maxDimension: CGFloat = 1024.0, compressionQuality: CGFloat = 0.5) -> Data? {
        let size = image.size
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > maxDimension || size.height > maxDimension {
            if aspectRatio > 1 {
                newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
            } else {
                newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
            }
        } else {
            newSize = size
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage?.jpegData(compressionQuality: compressionQuality)
    }
    
    func generateVideo(completion: @escaping () -> Void) {
        guard selectedImage != nil || selectedVideoURL != nil else {
            generationStatus = "Please select an image or video."
            return
        }
        
        let url = URL(string: "https://futuretechapps.shop/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(manager.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"appId\"\r\n\r\n".data(using: .utf8)!)
        body.append("com.test.test\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(manager.userId)\r\n".data(using: .utf8)!)
        
        let basePrompt = scene.description.isEmpty ? "Generate a scene" : scene.description
        let fullPrompt = selectedStyle != nil ? "\(basePrompt) \(selectedStyle!.promt)" : basePrompt
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fullPrompt)\r\n".data(using: .utf8)!)
        
        if let image = selectedImage {
            guard let imageData = compressImage(image, maxDimension: 1024.0, compressionQuality: 0.5) else {
                generationStatus = "Failed to compress image."
                return
            }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        } else if let videoURL = selectedVideoURL {
            do {
                let videoData = try Data(contentsOf: videoURL)
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"video.mp4\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
                body.append(videoData)
                body.append("\r\n".data(using: .utf8)!)
            } catch {
                generationStatus = "Failed to load video data."
                return
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.generationStatus = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.generationStatus = "Invalid response from server."
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.generationStatus = "Video generation started successfully!"
                        print("Response: \(json)")
                    }
                case 401:
                    self.generationStatus = "Authentication failed."
                case 422:
                    self.generationStatus = "Invalid input data."
                default:
                    self.generationStatus = "Unexpected response: \(httpResponse.statusCode)"
                }
            }
        }
        task.resume()
        completion()
    }
}

struct SceneView: View {
    @StateObject private var viewModel = SceneViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager() // Add subscription manager
    @State private var showStyleView = false
    @State private var showLoadView = false
    @State private var showSubscriptionSheet = false // New state for subscription sheet
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("Describe a scene and click generate")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                HStack(spacing: 10) {
                    Button(action: {
                        viewModel.isStyleSectionVisible = false
                        impactFeedback.impactOccurred()
                    }) {
                        Text("Create Prompt")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#393939"))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.toggleStyleSection()
                        impactFeedback.impactOccurred()
                    }) {
                        Text("Change Style")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#393939"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // [Previous ZStack content remains unchanged]
                ZStack(alignment: .bottomLeading) {
                    TextField(
                        viewModel.isStyleSectionVisible ? "Select a style to convert" : "A serene landscape...",
                        text: $viewModel.scene.description
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .padding(.trailing, (viewModel.selectedImage != nil || viewModel.selectedVideoURL != nil || viewModel.selectedStyle != nil) && !viewModel.isStyleSectionVisible ? 80 : 0)
                    .frame(height: 80, alignment: .topLeading)
                    .background(Color(hex: "#393939"))
                    .cornerRadius(10)
                    .foregroundColor(Color(hex: "#929292"))
                    .accentColor(.white)
                    
                    if !viewModel.isStyleSectionVisible {
                        Button(action: {
                            impactFeedback.impactOccurred()
                            viewModel.showImagePickerOptions = true
                        }) {
                            Image(systemName: "paperclip")
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.leading, 8)
                        .padding(.bottom, 8)
                    }
                    
                    // [Previous media preview logic remains unchanged]
                    if !viewModel.isStyleSectionVisible {
                        if let image = viewModel.selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(8)
                                    .padding(.trailing, 8)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                Button(action: {
                                    viewModel.selectedImage = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 20, height: 20)
                                }
                                .padding(.trailing, 4)
                            }
                        } else if let videoURL = viewModel.selectedVideoURL {
                            ZStack(alignment: .topTrailing) {
                                if let thumbnail = generateThumbnail(from: videoURL) {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 64, height: 64)
                                        .cornerRadius(8)
                                        .padding(.trailing, 8)
                                        .padding(.bottom, 8)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                Button(action: {
                                    viewModel.selectedVideoURL = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 20, height: 20)
                                }
                                .padding(.trailing, 4)
                            }
                        }
                    }
                    
                    if viewModel.isStyleSectionVisible {
                        HStack(spacing: 4) {
                            if let videoURL = viewModel.selectedVideoURL {
                                ZStack(alignment: .topTrailing) {
                                    if let thumbnail = generateThumbnail(from: videoURL) {
                                        Image(uiImage: thumbnail)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    Button(action: {
                                        viewModel.selectedVideoURL = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(.trailing, 4)
                                }
                            } else {
                                Button(action: {
                                    impactFeedback.impactOccurred()
                                    viewModel.showVideoPicker = true
                                }) {
                                    VStack {
                                        Image(systemName: "plus.square")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(.gray)
                                        Text("Video")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 64, height: 64)
                                    .background(Color(hex: "#474747"))
                                    .cornerRadius(8)
                                }
                            }
                            
                            if let selectedStyle = viewModel.selectedStyle {
                                ZStack(alignment: .topTrailing) {
                                    Image(selectedStyle.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Button(action: {
                                        viewModel.selectedStyle = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(.trailing, 4)
                                }
                            } else {
                                Button(action: {
                                    impactFeedback.impactOccurred()
                                    showStyleView = true
                                }) {
                                    VStack {
                                        Image(systemName: "link.circle")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(.gray)
                                        Text("Style")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 64, height: 64)
                                    .background(Color(hex: "#474747"))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
                
                // Updated Generate Button with subscription check
                Button(action: {
                    if subscriptionManager.hasSubscription {
                        impactFeedback.impactOccurred()
                        viewModel.generateVideo {
                            showLoadView = true
                            appState.incrementVideoGeneration()
                        }
                    } else {
                        impactFeedback.impactOccurred()
                        showSubscriptionSheet = true
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                        Text("Generate")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                Text(viewModel.generationStatus)
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.horizontal)
            }
            .background(Color(hex: "#272727"))
            .cornerRadius(16)
        }
        .actionSheet(isPresented: $viewModel.showImagePickerOptions) {
            ActionSheet(
                title: Text("Select Media Source"),
                buttons: [
                    .default(Text("Photo Library")) {
                        viewModel.showPhotoPicker = true
                    },
                    .default(Text("Take a photo")) {
                        viewModel.showCameraPicker = true
                    },
                    .default(Text("Choose Files")) {
                        viewModel.showDocumentPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPicker(selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showVideoPicker) {
            VideoPicker(selectedVideoURL: $viewModel.selectedVideoURL)
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPicker(selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showCameraPicker) {
            CameraPicker(selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $showStyleView) {
            StylesView { style in
                viewModel.selectedStyle = style
            }
        }
        .fullScreenCover(isPresented: $showLoadView) {
            Loadview()
        }
        .fullScreenCover(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet(viewModel: SubscriptionViewModel())
        }
    }
    
    private func generateThumbnail(from url: URL) -> UIImage? {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            if let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) {
                return UIImage(cgImage: cgImage)
            }
            return nil
        }
}
struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideoURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    guard let url = url, error == nil else { return }
                    // Копируем файл во временную директорию, чтобы сохранить доступ
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                    try? FileManager.default.copyItem(at: url, to: tempURL)
                    DispatchQueue.main.async {
                        self.parent.selectedVideoURL = tempURL
                    }
                }
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera // Use the camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    self.parent.selectedImage = image
                }
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
