//
//  SpeakDetailView.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import SwiftUI
import Charts

/// 발음 교정 화면
struct SpeakDetailView: View {
    @State private var chatMessages: [ChatMessage] = []
    @State private var isTranscribing = false
    @State private var speaker: TextSpeaker
    @State private var responder: AIResponder
    
    @State private var speechTranscriber: SpokenWordTranscriber
    @State private var recorder: Recorder
    @State private var partner: ConversationPartner
    
    init(partner: ConversationPartner) {
        self.partner = partner
        let messages = Binding<[ChatMessage]>(
            get: { [] },
            set: { _ in }
        )
        let transcriber = SpokenWordTranscriber(chatMessages: messages)
        _speechTranscriber = State(initialValue: transcriber)
        _recorder = State(initialValue: Recorder(transcriber: transcriber, chatMessages: messages))
        _chatMessages = State(initialValue: [])
        let textSpeaker = TextSpeaker()
        _speaker = State(initialValue: textSpeaker)
        _responder = State(initialValue: AIResponder(
            textSpeaker: textSpeaker,
            chatMessages: messages)
        )
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(chatMessages) { message in
                            chatRow(message)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatMessages.count) {
                    if let last = chatMessages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                        if case .partner(_) = last.sender {
                            print("partner")
                            try? speaker.speak(last.text, utteranceSetting: self.partner.utterance)
                        } else {
                            print("user")
                            Task {
                                let _ = await responder.startResponding(
                                    to: last.text
                                )
                            }
                        }
                    }
                }
            }
            
            Button(action: {
                Task {
                    await handleTranscriptionToggle()
                }
            }) {
                Text(isTranscribing ? "Stop Speaking" : "Start Speaking")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isTranscribing ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            try? recorder.setUpAudioSession()
            // 실제 chatMessages 바인딩 연결
            let messages = Binding<[ChatMessage]>(
                get: { self.chatMessages },
                set: { self.chatMessages = $0 }
            )
            speechTranscriber.chatMessages = messages
            recorder.chatMessages = messages
            responder.chatMessages = messages
        }
        .task {
            let _ = await responder.checkAvailable()
            responder.setUpConcept(self.partner)
        }
        .navigationTitle(partner.name)
    }
    
    @ViewBuilder
    private func chatRow(_ message: ChatMessage) -> some View {
        VStack(alignment: (message.sender == .user) ? HorizontalAlignment.trailing : HorizontalAlignment.leading, spacing: 4) {
            Text(message.text)
                .font(.body)
                .padding(10)
                .background(message.sender == .user ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: (message.sender == .user) ? .trailing : .leading)
            
            if let translated = message.translatedText {
                Text(translated)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: (message.sender == .user) ? .trailing : .leading)
            }
        }
        .id(message.id)
    }
    
    private func handleTranscriptionToggle() async {
        isTranscribing.toggle()
        do {
            if isTranscribing {
                try await recorder.startLiveTranscription()
            } else {
                try await recorder.stopTranscription()
            }
        } catch {
            print("⚠️ Transcription error: \(error)")
            isTranscribing = false
        }
    }
}

#Preview {
    SpeakView()
}
