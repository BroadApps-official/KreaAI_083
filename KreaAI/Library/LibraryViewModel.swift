//
//  LibraryViewModel.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.

import Foundation
import Combine

class LibraryViewModel: ObservableObject {
    @Published var videos: [Video] = []
    private var cancellables = Set<AnyCancellable>()
    private var manager = Manager.shared
    private let serverURL = URL(string: "https://futuretechapps.shop/generations")!

    
    func fetchVideos() {
        var components = URLComponents(url: serverURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "appId", value: manager.appId),
            URLQueryItem(name: "userId", value: manager.userId)
        ]
        
        guard let url = components.url else {
            print("Неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(manager.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("Сырой JSON-ответ: \(jsonString)")
                }
                return output.data
            }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Ошибка загрузки видео: \(error)")
                case .finished:
                    print("Успешно загружены видео")
                }
            }, receiveValue: { [weak self] response in
                // Removed the filter for status == 3
                let mappedVideos = response.data.map { video in
                    Video(
                        id: UUID(),
                        title: video.prompt ?? "Untitled",
                        date: "N/A",
                        thumbnailURL: video.result ?? "",
                        photoResult: video.photo
                    )
                }
                print("Список видео после маппинга: \(mappedVideos)")
                self?.videos = mappedVideos
                print("videos обновлены: \(self?.videos ?? [])")
            })
            .store(in: &cancellables)
    }
}
