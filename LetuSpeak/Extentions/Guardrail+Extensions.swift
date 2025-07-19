//
//  Guardrail+Extensions.swift
//  devcodingstory
//
//  Created by 최완복 on 7/19/25.
//

import FoundationModels

extension LanguageModelSession {
    /// Start a new session in blank slate state with string-based instructions.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - guardrails: Controls the guardrails setting for prompt and response filtering. System guardrails is enabled if not specified.
    ///   - tools: Tools to make available to the model for this session.
    ///   - instructions: Instructions that control the model's behavior.
    public convenience init(model: SystemLanguageModel = .default, tools: [any Tool] = [], instructions: String? = nil) {
        self.init(model: model, guardrails: .developerProvided, tools: tools, instructions: instructions)
    }
    
    /// Start a new session in blank slate state with instructions builder.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - guardrails: Controls the guardrails setting for prompt and response filtering. System guardrails is enabled if not specified.
    ///   - tools: Tools to make available to the model for this session.
    ///   - instructions: Instructions that control the model's behavior.
    public convenience init(model: SystemLanguageModel = .default, tools: [any Tool] = [], @InstructionsBuilder instructions: () throws -> Instructions) rethrows {
        try self.init(model: model, guardrails: .developerProvided, tools: tools, instructions: instructions)
    }
    
    /// Start a new session in blank slate state with instructions.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - guardrails: Controls the guardrails setting for prompt and response filtering. System guardrails is enabled if not specified.
    ///   - tools: Tools to make available to the model for this session.
    ///   - instructions: Instructions that control the model's behavior.
    public convenience init(model: SystemLanguageModel = .default, tools: [any Tool] = [], instructions: Instructions? = nil) {
        self.init(model: model, guardrails: .developerProvided, tools: tools, instructions: instructions)
    }
    
    /// Start a session by rehydrating from a transcript.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - guardrails: Controls the guardrails setting for prompt and response filtering. System guardrails is enabled if not specified.
    ///   - transcript: A transcript to resume from.
    ///   - tools: Tools to make available to the model for this session.
    public convenience init(model: SystemLanguageModel = .default, tools: [any Tool] = [], transcript: Transcript) {
        self.init(model: model, guardrails: .developerProvided, tools: tools, transcript: transcript)
    }
}

extension LanguageModelSession.Guardrails {
    static var developerProvided: LanguageModelSession.Guardrails {
        var guardrails = LanguageModelSession.Guardrails.default

        withUnsafeMutablePointer(to: &guardrails) { ptr in
            let rawPtr = UnsafeMutableRawPointer(ptr)
            let boolPtr = rawPtr.assumingMemoryBound(to: Bool.self)
            boolPtr.pointee = false
        }

        return guardrails
    }
}
