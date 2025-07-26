//
//  PixelProgressBar.swift
//  LetuSpeak
//
//  Created by jaegu park on 7/19/25.
//

import SwiftUI

struct PixelProgressBar: View {
    var totalBlocks: Int = 10
    var score: Int
    var maxScore: Int
    
    var body: some View {
        let filledBlocks = Int(Float(score) / Float(maxScore) * Float(totalBlocks))
        
        HStack(spacing: 4) {
            Text("[")
            ForEach(0..<totalBlocks, id: \.self) { i in
                Rectangle()
                    .frame(width: 24, height: 16)
                    .foregroundColor(i < filledBlocks ? .black : .clear)
                    .overlay(
                        Rectangle().stroke(Color.black, lineWidth: 1)
                    )
            }
            Text("]")
        }
    }
}
