//
//  CharacterView.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import SwiftUI

/// 학습 진척도 그래프 화면
struct CharacterView: View {
    @State private var isSettingsActive = false
    
    let characters = (1...8).map { "Character_\($0)" }
    
    @State private var score: Int = 6000
    @State private var selectedCharacter: String = "Character_1"
    @State private var unlockedCount: Int = 1
    
    let maxScore = 10_000
    
    var percent: Int {
        Int((Float(score) / Float(maxScore)) * 100)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 20) {
                    Button("LEVEL UP") {
                        if score >= maxScore {
                            score = 0
                        } else if score == 9000 {
                            if unlockedCount < characters.count {
                                unlockedCount += 1 // 점수 초기화 전 해금 수 증가
                            }
                            score += 1000
                        } else {
                            score += 1000
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    
                    Text("Level: \(unlockedCount)  \(score) / \(maxScore)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    PixelProgressBar(totalBlocks: 10, score: score, maxScore: maxScore)
                        .padding(.bottom, 20)
                    
                    Image(selectedCharacter)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .padding(.bottom, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(characters.indices, id: \.self) { index in
                                let name = characters[index]
                                let isUnlocked = index < unlockedCount
                                
                                ZStack {
                                    Image(name)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .grayscale(isUnlocked ? 0 : 1) // 잠긴 캐릭터는 회색처리
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(name == selectedCharacter ? Color.blue : Color.gray.opacity(0.3), lineWidth: name == selectedCharacter ? 3 : 1)
                                        )
                                        .onTapGesture {
                                            if isUnlocked {
                                                selectedCharacter = name
                                            }
                                        }
                                    
                                    if !isUnlocked {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .fill(Color.black.opacity(0.6))
                                                    .frame(width: 24, height: 24)
                                            )
                                            .offset(x: 30, y: -30)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding()
                
                NavigationLink(destination: ChartView(), isActive: $isSettingsActive) {
                    EmptyView()
                }
                
                Button(action: {
                    isSettingsActive = true
                }) {
                    Image("Chart_Button")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(10)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding([.top, .trailing], 24)
            }
        }
    }
}
