import SwiftUI
import AuthenticationServices

struct WelcomeScene: View {
    let onSignIn: (ASAuthorization) -> Void

    var body: some View {
        ZStack {
            DotGridBackground(spacing: 36, dotSize: 3, dotColor: .gray.opacity(0.2))
            
            HStack {
                VStack {
                    Brand()
                    
                    Spacer()
                    
                    Taglines()
                    
                    SignInWithApple(onSuccess: onSignIn, onFailure: { _ in })
                    
                    Spacer()
                }
                    .padding(48)
                    .frame(width: 460, alignment: .topLeading)
                
                FeaturesTeller()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .toolbar(removing: .title)
        .frame(minWidth: 500, idealWidth: 1200, minHeight: 600, idealHeight: 800)
    }
}

fileprivate struct Brand: View {
    var body: some View {
        HStack {
            Image("logo")
                .resizable()
                .frame(width: 24, height: 24)
            
            Text("xPoie")
                .typography(.h4)
            
            Spacer()
        }
    }
}

fileprivate struct Taglines: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Capture, Organize, Create — Unfold boldly")
                .typography(.h1, size: .huge, weight: .regular)
            
            Text("All-in-one workspace where ideas flow freely")
                .typography(.h5)
            
            Text("Tasks, infinite canvas, AI companion, and instant access — built for your daily work, life, and creative moments.")
        }
    }
}

fileprivate struct FeaturesTeller: View {
    var body: some View {
        VStack {
            
        }
    }
}

