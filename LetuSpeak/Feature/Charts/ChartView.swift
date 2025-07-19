//
//  ChartView.swift
//  LetuSpeak
//
//  Created by jaegu park on 7/19/25.
//

import SwiftUI

struct ChartView: View {
    let characters = (1...8).map { "Character_\($0)" }
    
    @State private var percent: Int = 60
    @State private var score: Int = 6000
    @State private var selectedCharacter: String = "Character_5"
    
    let maxScore = 10_000
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Increase") {
                if score < maxScore {
                    score += 100
                    percent = Int((Float(score) / Float(maxScore)) * 100)
                }
            }
            
            Text("\(score) / \(maxScore)")
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
                    ForEach(characters, id: \.self) { name in
                        Image(name)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(name == selectedCharacter ? Color.blue : Color.gray.opacity(0.3), lineWidth: name == selectedCharacter ? 3 : 1)
                            )
                            .onTapGesture {
                                selectedCharacter = name
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
    }
}
