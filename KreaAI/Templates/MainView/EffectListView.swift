//
//  EffectListView.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

//import SwiftUI
//
//struct EffectListView: View {
//    @StateObject private var viewModel: EffectViewModel
//
//    init(useMock: Bool = false) {
//        if useMock {
//            _viewModel = StateObject(wrappedValue: EffectViewModel(service: MockEffectService()))
//        } else {
//            _viewModel = StateObject(wrappedValue: EffectViewModel(service: EffectService()))
//        }
//    }
//
//    var body: some View {
//        ZStack{
//            Color(hex: "#161616").ignoresSafeArea()
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    if viewModel.isLoading {
//                        ProgressView("Loading...")
//                    } else if let errorMessage = viewModel.errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                    } else {
//                        ForEach(viewModel.sections) { section in
//                            VStack(alignment: .leading) {
//                                // Заголовок секции и кнопка "See All"
//                                HStack {
//                                    Text(section.title)
//                                        .font(.title2)
//                                        .fontWeight(.bold)
//                                        .padding(.leading, 16)
//                                    Spacer()
//                                    Button(action: {
//                                        // Действие для "See All"
//                                    }) {
//                                        Text("See All")
//                                            .foregroundColor(.blue)
//                                            .padding(.trailing, 16)
//                                    }
//                                }
//                                
//                                // Горизонтальный ScrollView для карточек
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    LazyHStack(spacing: 16) {
//                                        ForEach(section.effects) { effect in
//                                            EffectCard(effect: effect)
//                                                .frame(width: 120, height: 160)
//                                        }
//                                    }
//                                    .padding(.horizontal, 16)
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding(.vertical)
//            }
//            .task {
//                await viewModel.fetchEffectSections()
//            }
//        }
//    }
//}
//
//// Карточка эффекта
//struct EffectCard: View {
//    let effect: Effect
//
//    var body: some View {
//        VStack {
//            AsyncImage(url: URL(string: effect.imageUrl)) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(width: 120, height: 120)
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 120, height: 120)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                case .failure:
//                    Image(systemName: "photo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 120, height: 120)
//                        .foregroundColor(.gray)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            Text(effect.name)
//                .font(.caption)
//                .fontWeight(.medium)
//                .lineLimit(1)
//                .foregroundColor(.white)
//        }
//    }
//}
//
//struct EffectListView_Previews: PreviewProvider {
//    static var previews: some View {
//        EffectListView(useMock: true)
//            .preferredColorScheme(.dark) // Темная тема, как на скриншоте
//    }
//}
