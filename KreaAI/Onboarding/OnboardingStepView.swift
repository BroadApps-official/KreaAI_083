//
//  OnboardingStepView.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI
import StoreKit
import UserNotifications

struct OnboardingStepView: View {
    let step: OnboardingStep
    let index: Int
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var navigateToNextScreen = false
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image(step.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text(step.title)
                            .font(.custom("NanumMyeongjoBold", size: 28))
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(step.subtitle)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                            .transition(.opacity)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        if index == 4 {
                            requestNotificationPermission()
                            impactFeedback.impactOccurred()
                        } else {
                            viewModel.nextPage()
                            impactFeedback.impactOccurred()
                        }
                    }) {
                        Text(index == 4 ? "Turn on notifications" : "Next")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0080FF"))
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                    }
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 10))
                    
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true), isActive: $navigateToNextScreen) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if index == 3 {
                requestReview()
            }
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Allow")
                navigateToNextScreen = true
                impactFeedback.impactOccurred()
            } else {
                navigateToNextScreen = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
