//
//  Loadview.swift
//  KreaAI
//
//  Created by Денис Николаев on 01.04.2025.
//

import SwiftUI

struct Loadview: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 8){
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .font(.title)
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
            
            Spacer()
            Text("Generating Your Video...")
                .font(.custom("NanumMyeongjoBold", size: 24))
                .bold()
            Text("Once ready, the video will appear in the library.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    Loadview()
}
