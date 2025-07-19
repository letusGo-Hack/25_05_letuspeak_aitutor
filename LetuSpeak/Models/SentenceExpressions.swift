//
//  SentenceExpressions.swift
//  LetuSpeak
//
//  Created by 심성곤 on 7/19/25.
//

import Foundation
import FoundationModels

// MARK: - 문장 답변 모델
@Generable
struct SentenceExpressions {
    @Guide(description: "관련 예문", .maximumCount(3))
    var otherExpressions: [SentenceQuestion]
    
    @Guide(description: "주어 + 동사 + 목적어 등의 문장 구조 분해 설명", .maximumCount(2))
    var grammarTips: [String]
    
    @Guide(description: "발음 가이드 ex) /aɪ lʌv juː/")
    let pronunciationGuide: String
}


// MARK: - 문장 질문 모델
@Generable
struct SentenceQuestion: Identifiable {
    let id = UUID()
    @Guide(description: "영어 문장")
    let english: String
    @Guide(description: "한글 문장")
    let korean: String
}

extension SentenceQuestion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(english)
    }
    
    static func == (lhs: SentenceQuestion, rhs: SentenceQuestion) -> Bool {
        return lhs.english == rhs.english
    }
}
