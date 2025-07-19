//
//  SpeakView.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import SwiftUI
internal import AVFAudio

struct SpeakView: View {
    let partners: [ConversationPartner] = [
        .init(
            name: "어스고",
            avatar: "남자",
            personality: .init(
                roleDescription: "정말 따뜻하게 모든 대답에 공감해주는 사람",
                tone: "엄청 따뜻한 톤",
                interactionStyle: "질문을 자주 던지는 스타일"
            ),
            utterance: .init(
                rate: 0.5,
                pitchMultiplier: 1.0,
                postUtteranceDelay: 1.0,
                volume: 1.0,
                voice: AVSpeechSynthesisVoice.init(language: "en-KR")!
            )
        )
    ]
    
    var body: some View {
        NavigationStack {
            List(partners) { partner in
                NavigationLink(destination: SpeakDetailView(partner: partner)) {
                    HStack {
                        Text(partner.name)
                        Spacer()
                        Text(partner.personality.tone)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("상황 선택")
        }
    }
}


