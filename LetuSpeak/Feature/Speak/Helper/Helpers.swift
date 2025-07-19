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


public enum TranscriptionError: Error {
    case couldNotDownloadModel
    case failedToSetupRecognitionStream
    case invalidAudioDataType
    case localeNotSupported
    case noInternetForModelDownload
    case audioFilePathNotFound
    
    var descriptionString: String {
        switch self {

        case .couldNotDownloadModel:
            return "Could not download the model."
        case .failedToSetupRecognitionStream:
            return "Could not set up the speech recognition stream."
        case .invalidAudioDataType:
            return "Unsupported audio format."
        case .localeNotSupported:
            return "This locale is not yet supported by SpeechAnalyzer."
        case .noInternetForModelDownload:
            return "The model could not be downloaded because the user is not connected to internet."
        case .audioFilePathNotFound:
            return "Couldn't write audio to file."
        }
    }
}

enum TTSError: Error {
    case TTSUnavailable
    case TextEmpty
    
    var message: String {
        switch self {
        case .TTSUnavailable: return "TTS is unvailable"
        case .TextEmpty: return "Text is not existed"
        }
    }
}

public extension Locale.Language {
    static let english = Locale.Language(identifier: "en")
    static let korean = Locale.Language(identifier: "ko")
}
