//
//  OnboardingViewModel.swift
//  KreaAI
//
//  Created by Денис Николаев on 25.03.2025.
//


import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var steps: [OnboardingStep] = [
        OnboardingStep(imageName: "step1", title: "", subtitle: ""),
      //  OnboardingStep(imageName: "step1", title: "Create Videos from Text", subtitle: "Describe your idea - get a unique clip"),
        OnboardingStep(imageName: "step2", title: "Use Ready Templates", subtitle: "Quickly make videos with pro designs"),
        OnboardingStep(imageName: "step3", title: "Create Videos in Any Style", subtitle: "Pick a style – get stunning results!"),
        OnboardingStep(imageName: "step4", title: "Share Your Opinion", subtitle: "Your feedback means a lot to us!"),
        OnboardingStep(imageName: "step5", title: "Enable Notifications", subtitle: "Be the first to get updates & new effects")
    ]
    
    @Published var currentPage = 0
    
    func nextPage() {
        if currentPage < steps.count - 1 {
            currentPage += 1
        } else {
            print("Onboarding Finished!")
        }
    }
}
