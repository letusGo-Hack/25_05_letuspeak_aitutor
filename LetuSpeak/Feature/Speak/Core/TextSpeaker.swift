//
//  TextSpeaker.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Foundation
import AVFAudio
import SwiftUI

@MainActor
final class TextSpeaker: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(
        _ text: String?,
        utteranceSetting: CustomUtterance
    ) throws {
        guard let text else { throw TTSError.TextEmpty }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = .init(identifier: utteranceSetting.voice.rawValue)
        utterance.pitchMultiplier = utteranceSetting.pitchMultiplier
        utterance.rate = utteranceSetting.rate
        utterance.volume = utteranceSetting.volume
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension TextSpeaker: AVSpeechSynthesizerDelegate {
    
}
