//
//  SettingsView.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//

let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

import SwiftUI
import WebKit

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showPrivacyPolicy = false
    @State private var showTermsAndConditions = false
    @State private var showSupport = false
    @State private var showSubscription = false
    @State private var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        ZStack {
            Color(hex: "#161616").ignoresSafeArea()
            VStack {
                List {
                    Section {
                        Button(action: {
                                impactFeedback.impactOccurred()
                                showSubscription = true
                        }) {
                            HStack {
                                Image(systemName: "crown")
                                Text("Upgrade plan")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }.fullScreenCover(isPresented: $showSubscription) {
                            SubscriptionSheet(viewModel: SubscriptionViewModel())
                        }
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            viewModel.restorePurchase()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Restore Purchase")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            impactFeedback.impactOccurred()
                            viewModel.rateApp()
                        }) {
                            HStack {
                                Image(systemName: "star")
                                Text("Rate Us")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            viewModel.shareApp()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share the App")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        
                        HStack {
                            Image(systemName: "bell.badge")
                            Text("Notifications")
                            Spacer()
                            Toggle("", isOn: $viewModel.notificationsEnabled)
                                .tint(.white)
                        }
                        .foregroundColor(.white)
                    }
                    
                    Section {
                        Button(action: {
                            impactFeedback.impactOccurred()
                            showPrivacyPolicy = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.shield")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        .fullScreenCover(isPresented: $showPrivacyPolicy) {
                            PrivacyPolicyView()
                        }
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            showTermsAndConditions = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms & Conditions")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        .fullScreenCover(isPresented: $showTermsAndConditions) {
                            TermsAndConditionsView()
                        }
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            showSupport = true
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Support")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        .fullScreenCover(isPresented: $showSupport) {
                            ContactView()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#161616"))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://docs.google.com/document/d/1mOa5eM4uNk90QoexRb-6NjTBhEWBi6_GEFkrxR44t5A/edit?usp=sharing")!)
                .navigationTitle("Privacy Policy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.gray)
                    }
                }
        }
    }
}

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://docs.google.com/document/d/1_KQp4a87-GM38omlAIOXPJYSgslxoLc2_AX2PJZglqw/edit?usp=sharing")!)
                .navigationTitle("Terms & Conditions")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.gray)
                    }
                }
        }
    }
}

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://docs.google.com/forms/d/1_0ArhDdfbyCcwqsuGkPiqS3h77crDwtM7d93zLKS2k8/edit")!)
                .navigationTitle("Support")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.gray)
                    }
                }
        }
    }
}
