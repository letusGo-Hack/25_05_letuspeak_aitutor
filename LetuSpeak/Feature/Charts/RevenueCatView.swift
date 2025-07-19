//
//  RevenueCatView.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//

import SwiftUI
import Charts
import RevenueCat
import RevenueCatUI

struct RevenueCatView: View {
    @State private var package: Package?
    
    var body: some View {
        VStack {
            if let package = package {
                Button("Pro 구독 구매하기") {
                    Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                        if let isActive = customerInfo?.entitlements["Pro"]?.isActive, isActive {
                            // Pro 권한 활성화
                            print("Pro 권한 활성화됨")
                        } else {
                            print("구매 실패 또는 취소")
                        }
                    }
                }
            } else {
                Text("상품 정보를 불러오는 중...")
            }
        }
        .onAppear {
            Purchases.logLevel = .debug
            Purchases.configure(withAPIKey: "appl_...")
            
            Purchases.shared.getOfferings { offerings, error in
                if let package = offerings?.current?.availablePackages.first {
                    self.package = package
                }
            }
        }
    }
}
