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
    let personality: String // 말투, 태도 설정용 프롬프트
}
