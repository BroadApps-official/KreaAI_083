//
//  GenView.swift
//  KreaAI
//
//  Created by Денис Николаев on 26.03.2025.
//

import SwiftUI

struct GenView: View {
    @State var showSubscriptionSheet = false
    var body: some View {
        ZStack{
            Color(hex: "#161616").ignoresSafeArea()
        ScrollView{
                SceneView()
                Image("banner")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .padding(.top, 16)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .onTapGesture {
                        print("Tapped on Color Analysis banner")
                    }
            }
            .padding(.horizontal,16)
            Spacer()
        }
        .fullScreenCover(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet(viewModel: SubscriptionViewModel())
        }
    }
}

#Preview {
    GenView()
}
