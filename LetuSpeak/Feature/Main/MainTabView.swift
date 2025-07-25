//
//  MainTabView.swift
//  LetuSpeak
//
//  Created by 심성곤 on 7/19/25.
//

import SwiftUI

/// 메인 탭뷰
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 메인 탭
            CharacterView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("메인")
                }
                .tag(0)
            
            // 단어 퀴즈 탭
            WordQuizView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("단어 퀴즈")
                }
                .tag(1)
            
            // 문장 배열 탭
            SentenceArrangeView()
                .tabItem {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                    Text("문장 배열")
                }
                .tag(2)
            
            // 발음 교정 탭
            SpeakView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("발음 교정")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
