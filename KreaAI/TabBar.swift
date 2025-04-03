//
//  TabBar.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

import SwiftUI

struct TabBar: View {
    @State private var selectedTab: Int = 0
    @State var showSubscriptionSheet = false
    @StateObject private var subscriptionManager = SubscriptionManager() // Add subscription manager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                GenView()
                    .toolbar {
                        // Only show PRO button if no subscription
                        if !subscriptionManager.hasSubscription {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showSubscriptionSheet = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown")
                                        Text("PRO")
                                            .font(.system(size: 12))
                                            .bold()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "#0080FF"))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                }
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showSubscriptionSheet) {
                        SubscriptionSheet(viewModel: SubscriptionViewModel())
                    }
            }
            .tabItem {
                Label("Create", systemImage: "sparkles")
            }
            .tag(0)
            
            NavigationView {
                EffectListView()
                    .toolbar {
                        // Only show PRO button if no subscription
                        if !subscriptionManager.hasSubscription {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showSubscriptionSheet = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown")
                                        Text("PRO")
                                            .font(.system(size: 12))
                                            .bold()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "#0080FF"))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                }
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showSubscriptionSheet) {
                        SubscriptionSheet(viewModel: SubscriptionViewModel())
                    }
            }
            .tabItem {
                Label("Templates", systemImage: "bolt")
            }
            .tag(1)
            
            NavigationView {
                LibraryView()
                    .navigationTitle("Library")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Library")
                                .font(.custom("NanumMyeongjo", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
            }
            .tabItem {
                Label("Library", systemImage: "folder")
            }
            .tag(2)
            
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Settings")
                                .font(.custom("NanumMyeongjo", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(3)
        }
        .accentColor(.white)
    }
}

#Preview {
    TabBar()
}
