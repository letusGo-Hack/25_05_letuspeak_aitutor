//
//  ChartView.swift
//  LetuSpeak
//
//  Created by jaegu park on 7/19/25.
//

import SwiftUI
import Charts

struct TrianglePath: Shape {
    let center: CGPoint
    let radius: CGFloat
    let scores: [CGFloat] // 0~100 기반

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let angle1 = -CGFloat.pi / 2          // 위쪽 (발음)
        let angle2 = angle1 + 2 * .pi / 3     // 오른쪽 아래 (어휘)
        let angle3 = angle1 + 4 * .pi / 3     // 왼쪽 아래 (문법)
        let angles = [angle1, angle2, angle3]
        
        let points = angles.enumerated().map { index, angle -> CGPoint in
            let ratio = scores[index] / 100
            let r = ratio * radius
            return CGPoint(x: center.x + r * cos(angle),
                           y: center.y + r * sin(angle))
        }
        
        path.move(to: points[0])
        path.addLines([points[1], points[2], points[0]])
        return path
    }
}

struct ChartView: View {
    // 예시 점수 (0~100)
    let pronunciationScore: CGFloat = 80
    let vocabularyScore: CGFloat = 65
    let grammarScore: CGFloat = 72
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) * 0.6
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2 + 40)
            let radius = size / 2
            
            let angle1 = -CGFloat.pi / 2
            let angle2 = angle1 + 2 * .pi / 3
            let angle3 = angle1 + 4 * .pi / 3
            
            let basePoints = [
                CGPoint(x: center.x + radius * cos(angle1), y: center.y + radius * sin(angle1)),
                CGPoint(x: center.x + radius * cos(angle2), y: center.y + radius * sin(angle2)),
                CGPoint(x: center.x + radius * cos(angle3), y: center.y + radius * sin(angle3))
            ]
            
            let userPoints = [
                CGPoint(x: center.x + radius * (pronunciationScore / 100) * cos(angle1),
                        y: center.y + radius * (pronunciationScore / 100) * sin(angle1)),
                CGPoint(x: center.x + radius * (vocabularyScore / 100) * cos(angle2),
                        y: center.y + radius * (vocabularyScore / 100) * sin(angle2)),
                CGPoint(x: center.x + radius * (grammarScore / 100) * cos(angle3),
                        y: center.y + radius * (grammarScore / 100) * sin(angle3))
            ]
            
            ZStack {
                // 외곽 삼각형
                Path { path in
                    path.move(to: basePoints[0])
                    path.addLines(basePoints)
                    path.closeSubpath()
                }
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                
                // 사용자 점수 삼각형
                Path { path in
                    path.move(to: userPoints[0])
                    path.addLines(userPoints)
                    path.closeSubpath()
                }
                .fill(Color.blue.opacity(0.3))
                
                // 기준선 (안쪽)
                Path { path in
                    path.move(to: center)
                    for point in basePoints {
                        path.addLine(to: point)
                        path.move(to: center)
                    }
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                
                // 꼭짓점 라벨
                Text("발음")
                    .font(.caption)
                    .position(x: center.x, y: center.y - radius - 20)
                
                Text("어휘")
                    .font(.caption)
                    .position(x: center.x + radius * cos(angle2) + 28,
                              y: center.y + radius * sin(angle2) + 10)
                
                Text("문법")
                    .font(.caption)
                    .position(x: center.x + radius * cos(angle3) - 28,
                              y: center.y + radius * sin(angle3) + 10)
                
                // 그래프 위 타이틀
                Text("📈 나의 영어 스킬 그래프")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.1)
            }
        }
        .navigationTitle("나의 차트")
        .navigationBarTitleDisplayMode(.inline)
    }
}
