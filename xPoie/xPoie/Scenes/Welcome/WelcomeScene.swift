import SwiftUI
import AuthenticationServices

// ui 参考 https://humansintheloop.tech/

struct WelcomeScene: View {
    let onSignIn: (ASAuthorization) -> Void

    var body: some View {
        ZStack {
            DotGridBackground(spacing: 36, dotSize: 3, dotColor: .gray.opacity(0.2))
            
            HStack {
                VStack {
                    Brand()
                    
                    Spacer().frame(height: 100)
                    
                    Taglines()
                    
                    Spacer()
                    
                    SignInWithApple(onSuccess: onSignIn, onFailure: { _ in })
                }
                    .padding(42)
                    .frame(width: 480, alignment: .topLeading)
                
                FeaturesTeller()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .toolbar(removing: .title)
        .frame(minWidth: 500, idealWidth: 1200, minHeight: 600, idealHeight: 800)
    }
}

fileprivate struct Brand: View {
    @Environment(\.theme) private var theme
    var body: some View {
        HStack {
            Image("logo")
                .resizable()
                .frame(width: 24, height: 24)
            
            Text("xPoie")
                .foregroundStyle(theme.semantic.brand.gradient)
                .font(size: .h4, weight: .regular, design: .rounded)

            Spacer()
        }
    }
}

fileprivate struct Taglines: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your All-in-One space to")
//                .font(size: .huge, weight: .medium)
                .font(.system(size: 28, weight: .medium))

            TypewriterCarousel(
                texts: [
                    "Priority tasks",
                    "Capture ideas",
                    "Unfold creativity",
                    "Supercharge with AI"
                ],
                deleteBeforeNext: true
            )

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

