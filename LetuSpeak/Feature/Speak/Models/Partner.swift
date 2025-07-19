//
//  Partner.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Foundation

struct ConversationPartner: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String // 이미지 이름 또는 URL
    let personality: ConversationPersona // 말투, 태도 설정용 프롬프트
    let utterance: CustomUtterance
}

/// AI 회화 파트너의 말투, 태도, 역할 등을 설정하는 구조체
struct ConversationPersona {
    /// AI의 역할 또는 성격을 설명하는 문장 (예: 친절한 선생님, 엄격한 면접관 등)
    let roleDescription: String

    /// AI가 대화 시 사용하는 말투 스타일 (예: 부드럽고 따뜻한 말투, 격식 있는 말투 등)
    let tone: String

    /// 유저에게 응답할 때의 상호작용 방식 (예: 질문을 자주 던지는, 유저 말을 경청하는 등)
    let interactionStyle: String
}
