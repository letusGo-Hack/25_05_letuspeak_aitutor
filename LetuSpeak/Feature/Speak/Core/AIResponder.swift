//
//  AIResponder.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Foundation
import FoundationModels
import SwiftUI

@Observable
final class AIResponder: Sendable {
    private let textSpeaker: TextSpeaker
    
    var chatMessages: Binding<[ChatMessage]>
    var session: LanguageModelSession?
    var partner: ConversationPartner?
    var instructions: String?
    
    init(textSpeaker: TextSpeaker, chatMessages: Binding<[ChatMessage]>) {
        self.textSpeaker = textSpeaker
        self.chatMessages = chatMessages
    }
    
    func checkAvailable() async -> Bool {
        let model = SystemLanguageModel.default
        return model.isAvailable
    }
    
    func setUpConcept(_ partner: ConversationPartner? = nil) {
        if let partner {
            let instructions = """
                    당신은 지금부터 영어 학습을 도와주는 AI 회화 파트너입니다.
                    
                    [역할 설명]
                    이름: \(partner.name)
                    당신은 \(partner.personality.roleDescription) 역할을 맡고 있습니다.
                    
                    [말투]
                    모든 대화는 "\(partner.personality.tone)" 말투로 말해주세요.
                    
                    [상호작용 스타일]
                    유저에게는 "\(partner.personality.interactionStyle)" 방식으로 응답하세요.
                    
                    [대답 생성 규칙]
                    - 유저가 한 문장을 보고 적절한 영어 문장으로 짧게 대답하세요.
                    - 대답 후 ConversationResponse 구조에 맞춰 평가 점수도 포함하세요:
                      - pronunciation, grammar, vocabulary, fluency, overall (0~100)
                      - feedback (개선점 피드백)
                    - `translatedText` 항목에는 생성한 영어 응답 문장의 한국어 번역을 넣어주세요.
                    - 반드시 JSON 형태로 ConversationResponse 구조를 따르세요.
            
                    [주의사항]
                    - 짧고 명확하게 말해주세요.
                    - 유저가 말한 영어 문장이 어색하거나 틀렸다면 부드럽게 교정해주세요.
                    - 너무 많은 정보를 한 번에 주지 마세요.
                    - 친절하고 인내심 있는 태도를 유지하세요.
            """
            self.partner = partner
            self.instructions = instructions
        }
        self.session = LanguageModelSession(instructions: instructions)
    }
    
    func startResponding(to text: String) async -> ConversationResponse? {
        guard let session else { print("??");return nil }
        
        do {
            print("hello")
            let response = try await session.respond(generating: ConversationResponse.self) {
    """
    유저가 입력한 문장에 자연스럽게 영어로 응답하세요. 그리고 해당 응답 문장에 대한 평가를 아래 구조에 따라 반환하세요:
    
    [응답 형식: ConversationResponse]
    - `text`: AI가 생성한 자연스러운 영어 응답 문장 (한 문장)
    - `translatedText`: 그 응답 문장의 한국어 번역
    - `score`: 아래 항목들로 구성된 응답 평가 점수
        - `pronunciation` (0~100): 유저가 이 문장을 읽었을 때 발음이 얼마나 좋을지 추정
        - `grammar` (0~100): 문법의 정확성
        - `vocabulary` (0~100): 어휘의 다양성과 적절성
        - `fluency` (0~100): 문장의 자연스러움과 흐름
        - `overall` (0~100): 전반적인 평가 점수
        - `feedback`: 유저에게 줄 수 있는 피드백 (친절하게)
    
    ⚠️ 반드시 ConversationResponse 구조에 맞춰 JSON 형태로 반환하세요.
    
    유저 입력: "\(text)"
    """
            }
            print("2")
            let message = ChatMessage(
                sender: .partner(name: partner?.name ?? ""),
                text: response.content.text,
                translatedText: response.content.translatedText ?? "",
                timestamp: Date()
            )
            print("3")
            await MainActor.run {
                chatMessages.wrappedValue.append(message)
            }
            print("4")
            print(response.content)
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            print(error.localizedDescription)
            if case .exceededContextWindowSize = error {
                self.session = LanguageModelSession(instructions: instructions)
            }
            return await startResponding(to: text)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func stopResponding() {
        
    }
}

// 1. 먼저 AI에게 어떤 컨셉을 부여할 건지  prompt 행동(말투, 감정, )을 외부에서 받기
// 2.
