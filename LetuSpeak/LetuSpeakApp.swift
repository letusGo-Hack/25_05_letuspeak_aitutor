//
//  LetuSpeakApp.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import SwiftUI
import RevenueCat

@main
struct LetuSpeakApp: App {
    init() {
        Purchases.configure(withAPIKey: "appl_fLXCXVqTgYpjdpmYooUoUqXjaNL")
    }
    var body: some Scene {
        WindowGroup {
            RevenueCatView()
        }
    }
}
