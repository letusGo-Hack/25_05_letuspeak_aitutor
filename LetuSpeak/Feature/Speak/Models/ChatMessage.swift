//
//  ChatMessage.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Translation
import FoundationModels
import Foundation

struct ChatMessage: Identifiable {
    enum Sender {
        case user
        case partner(name: String)
    }

    let id = UUID()
    let sender: Sender
    let text: String
    var translatedText: String?
    let timestamp: Date
    
    init(
        sender: Sender,
        text: String,
        timestamp: Date
    ) async {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.translatedText = await translateToKorean(text)
    }
    
    func translateToKorean(_ english: String) async -> String {
        let session = LanguageModelSession()
        let prompt = """
        다음 영어 문장을 한국어로 번역, 번역한 문장만 출력
        \(english)
        """
        guard let response = try? await session.respond(to: prompt)
        else {return ""}
        return response.content
        /*
        let availability = LanguageAvailability()
        await print(availability.supportedLanguages)
        let status = await availability.status(from: .english, to: .korean)
        
        switch status {
        case .installed, .supported:
            print("available translateToKorean")
            break
        default:
            return "번역을 지원하지 않는 기기 입니다."
        }
        let session = TranslationSession(
            installedSource: .english,
            target: .korean
        )
        do {
            let translated = try await session.translate(english)
            return "\(translated)"
        } catch {
            print(error.localizedDescription)
            return "번역 중, 오류가 발생했습니다."
        }
         */
    }
}

extension ChatMessage.Sender: Equatable {
    static func == (lhs: ChatMessage.Sender, rhs: ChatMessage.Sender) -> Bool {
        switch (lhs, rhs) {
        case (.user, .user):
            return true
        case let (.partner(name1), .partner(name2)):
            return name1 == name2
        default:
            return false
        }
    }
}
