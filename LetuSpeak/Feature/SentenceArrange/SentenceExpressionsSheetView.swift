//
//  SentenceExpressionsSheetView.swift
//  LetuSpeak
//
//  Created by 심성곤 on 7/19/25.
//

import SwiftUI
import AVFoundation
import FoundationModels

// MARK: - 다른 표현 시트 뷰
struct SentenceExpressionsSheetView: View {
    let sentenceQuestion: SentenceQuestion
    @Environment(\.dismiss) private var dismiss
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var aiItem: SentenceExpressions?

    var body: some View {
        NavigationStack {
            VStack {
                if let aiItem {
                    ScrollView {
                        content(item: aiItem)
                    }
                } else {
                    AiAnimationView()
                }
            }
            .navigationTitle("다른 표현")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .task {
            if aiItem == nil {
                do {
                    let session = LanguageModelSession(guardrails: .developerProvided)
                    let prompt =
"""
한국어 \(sentenceQuestion.korean)
영어 \(sentenceQuestion.english)
에 대한 다른 표현 예문을 추천해줘.
"""
                    let respond = try await session.respond(
                        to: prompt,
                        generating: SentenceExpressions.self)
                    
                    var content = respond.content
                    content.otherExpressions = Array(Set(content.otherExpressions))
                    content.grammarTips = Array(Set(content.grammarTips))
                    aiItem = content
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @ViewBuilder
    func content(item: SentenceExpressions) -> some View {
        VStack(spacing: 25) {
            // 현재 문장 섹션
            VStack(spacing: 15) {
                Text("현재 문장")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    // 영어 문장
                    Text(sentenceQuestion.english)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    
                    // 한글 번역
                    Text(sentenceQuestion.korean)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                }
            }
            
            Divider()
            
            // 다른 표현들 섹션
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "text.bubble")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("다른 표현들")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(Array(item.otherExpressions.enumerated()), id: \.offset) { index, expression in
                        HStack {
                            // 번호
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.green)
                                .clipShape(Circle())
                            
                            // 표현
                            VStack(alignment: .leading, spacing: 4) {
                                Text(expression.english)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(expression.korean)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // 발음 듣기 버튼
                            Button(action: {
                                speakText(expression.english)
                            }) {
                                Image(systemName: "speaker.wave.2")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
            }
            
            Divider()
            
            // 문법 팁 섹션
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    Text("문법 팁")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                LazyVStack(spacing: 10) {
                    ForEach(Array(item.grammarTips.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text(tip)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
            
            // 발음 가이드 섹션
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("발음 가이드")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    // 발음 기호
                    HStack {
                        Text("발음:")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Text(item.pronunciationGuide)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                        
                        Spacer()
                        
                        Button(action: {
                            speakText(sentenceQuestion.english)
                        }) {
                            Image(systemName: "speaker.wave.2.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.05))
                    .cornerRadius(12)
                }
            }
            
            Spacer(minLength: 50)
        }
        .padding()
    }
    
    // MARK: - 발음 듣기 기능
    private func speakText(_ text: String) {
        // 현재 재생 중인 음성이 있다면 중지
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 영어 설정
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8 // 조금 느리게
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
}

// MARK: - 프리뷰
#Preview {
    SentenceExpressionsSheetView(
        sentenceQuestion: SentenceQuestion(
            english: "I love you",
            korean: "나는 너를 사랑해"
        )
    )
}

