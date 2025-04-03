//
//  FeedbackView.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    let appStoreId = "6743793678"
    @EnvironmentObject var appState: AppStateManager
    var body: some View {
        ZStack {
            // Background Image
            Image("customRateUs") // Replace "backgroundPhoto" with your image name
                .resizable()
                .scaledToFill() // Ensures the image fills the screen
                .ignoresSafeArea() // Extends the image to the edges
                
            
            
            
            VStack(spacing: 20) {
                Spacer()
                Spacer()
                
                Text("Do you like our app?")
                    .font(.custom("NanumMyeongjoBold", size: 32))
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Your opinion matters! Let us know what you think")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#CBCBCB"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 45)
                    .padding(.bottom, 40)
                
                HStack(spacing: 15) {
                    Button(action: {
                        openAppStoreReview()
                        appState.markAsRated()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Rate")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0080FF"))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 60)
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .bold()
                            .foregroundColor(.white)
                           
                    }
                    Spacer()
                }
                .padding(.top, 68)
                Spacer()
            }
            .padding(.leading, 16)
        }
    }
    
    private func openAppStoreReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review") else { return }
        UIApplication.shared.open(url, options: [:]) { _ in }
    }
}

#Preview {
    FeedbackView()
}
