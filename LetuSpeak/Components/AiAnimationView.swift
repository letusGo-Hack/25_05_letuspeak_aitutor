//
//  AiAnimationView.swift
//  LetuSpeak
//
//  Created by 심성곤 on 7/19/25.
//

import SwiftUI

/// AI 애니메이션 뷰
struct AiAnimationView: View {
    
    @State private var rotation: Double = 0

    var body: some View {
        Image(systemName: "apple.intelligence")
            .font(.title)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    AiAnimationView()
}
