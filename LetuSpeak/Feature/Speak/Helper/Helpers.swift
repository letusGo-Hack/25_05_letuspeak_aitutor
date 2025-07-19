//
//  Helpers.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import Foundation
import AVFoundation

public enum SpeechState: Equatable {
    case stopped
    case recording
    case paused
}

extension Recorder {
    func isAuthorized() async -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            return true
        }
        
        return await AVCaptureDevice.requestAccess(for: .audio)
    }
}
