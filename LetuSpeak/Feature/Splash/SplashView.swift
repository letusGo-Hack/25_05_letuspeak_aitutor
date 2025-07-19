//
//  SplashView.swift
//  LetuSpeak
//
//  Created by 심성곤 on 7/19/25.
//

import SwiftUI

/// 시작 화면
struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0.0
    @State private var subtitleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0.0
    @State private var backgroundGradientOpacity: Double = 0.0
    @State private var navigateToMain = false
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.teal.opacity(0.6),
                    Color.cyan.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(backgroundGradientOpacity)
            
            VStack(spacing: 30) {
                Spacer()
                
                // 로고 아이콘
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "book.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .overlay(
                            Image(systemName: "globe")
                                .font(.system(size: 25, weight: .medium))
                                .foregroundColor(.yellow)
                                .offset(x: 25, y: -20)
                        )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // 앱 제목
                Text("LetuSpeak")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                
                // 부제목
                Text("영어 학습의 새로운 시작")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .offset(y: subtitleOffset)
                    .opacity(subtitleOpacity)
                
                Spacer()
            }
            .onAppear {
                startAnimationSequence()
            }
        }
        .fullScreenCover(isPresented: $navigateToMain) {
            MainTabView() // 메인 화면으로 이동
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func startAnimationSequence() {
        // 배경 그라데이션 페이드인
        withAnimation(.easeInOut(duration: 0.8)) {
            backgroundGradientOpacity = 1.0
        }
        
        // 로고 애니메이션 (0.5초 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        
        // 제목 애니메이션 (1.2초 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
        
        // 부제목 애니메이션 (1.8초 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                subtitleOffset = 0
                subtitleOpacity = 1.0
            }
        }
        
        // 메인 화면으로 이동 (4초 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            navigateToMain = true
        }
    }
}

#Preview {
    SplashView()
}
