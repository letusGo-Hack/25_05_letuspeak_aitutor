//
//  Score.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import FoundationModels

/// 유저의 대화와 그에 대한 AI 평가 정보를 담는 구조체
@Generable
struct ConversationResponse {
    /// 대답 문장
    @Guide(description: "AI가 생성한 영어 응답 문장")
    let text: String

    @Guide(description: "해당 응답 문장의 한국어 번역 결과")
    var translatedText: String?

    /// 해당 문장에 대한 AI의 평가 점수
    @Guide(description: "해당 응답에 대한 발음/문법/어휘/유창성 등의 평가")
    let score: ConversationScore
}

/// 대화 평가 점수 정보
@Generable
struct ConversationScore {
    /// 발음 점수 (0~100)
    @Guide(description: "유저 발음의 정확도를 0~100 사이 점수로 평가합니다.")
    let pronunciation: Int

    /// 문법 점수 (0~100)
    @Guide(description: "문장의 문법적 정확성을 평가한 점수입니다.")
    let grammar: Int

    /// 어휘 사용 점수 (0~100)
    @Guide(description: "적절하고 다양한 어휘를 사용했는지에 대한 평가입니다.")
    let vocabulary: Int

    /// 유창성 점수 (0~100)
    @Guide(description: "문장의 자연스러움과 말의 흐름을 평가한 점수입니다.")
    let fluency: Int

    /// 종합 점수 (0~100)
    @Guide(description: "전체적인 영어 사용 능력을 바탕으로 한 종합 점수입니다.")
    let overall: Int

    /// AI 피드백 메시지
    @Guide(description: "사용자의 문장에 대한 전반적인 피드백을 제공합니다.")
    let feedback: String
}
