//
//  ContentView 2.swift
//  KreaAI
//
//  Created by Денис Николаев on 27.03.2025.
//

import UIKit

struct PhotoModel {
    var image: UIImage?
}

import SwiftUI

class PhotoViewModel: ObservableObject {
    @Published var photo: PhotoModel = PhotoModel(image: nil)
    @Published var isShowingGalleryPicker: Bool = false
    @Published var isScreenVisible: Bool = true
    
    // Заглушка для изображения (можно заменить на реальное фото)
    init() {
        // Для примера установим дефолтное изображение
        photo.image = UIImage(named: "placeholder") // Замени на своё изображение в ассетах
    }
    
    func selectPhoto(_ image: UIImage) {
        photo.image = image
        isShowingGalleryPicker = false
    }
    
    func closeScreen() {
        isScreenVisible = false
    }
    
    func toggleGalleryPicker() {
        isShowingGalleryPicker.toggle()
    }
    
    func toggleCamera() {
        // Здесь можно добавить логику переключения камеры (фронтальная/задняя)
        print("Переключение камеры")
    }
    
    func takePhoto() {
        // Здесь будет логика для съёмки фото
        print("Съёмка фото")
    }
}

import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = PhotoViewModel()
    
    var body: some View {
        if viewModel.isScreenVisible {
            ZStack {
                // Фото на весь экран
                if let image = viewModel.photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.black // Заглушка, если фото нет
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Элементы интерфейса
                VStack {
                    // Верхняя панель: кнопка слева и крестик справа
                    HStack {
                        
                        Button(action: {
                            viewModel.closeScreen()
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white)
                                .bold()
                                .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleCamera()
                        }) {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                .resizable()
                                .frame(width: 24, height: 20)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    // Нижняя панель: выбор из галереи слева, кнопка съёмки справа
                    HStack {
                        Button(action: {
                            viewModel.toggleGalleryPicker()
                        }) {
                            // Превью фото из галереи (заглушка)
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.takePhoto()
                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
//            .sheet(isPresented: $viewModel.isShowingGalleryPicker) {
//                ImagePicker(selectedImage: Binding(
//                    get: { viewModel.photo.image },
//                    set: { if let newImage = $0 { viewModel.selectPhoto(newImage) } }
//                ))
//            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
