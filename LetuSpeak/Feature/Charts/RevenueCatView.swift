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
    @State private var customnerInfo: CustomerInfo?
    @State private var isPro: Bool = false
    @State private var package: Package? = nil
    @State private var isPurchasing = false
    
    var body: some View {
        Button("Buy Coins") {
            purchase(productID: "coins_pack.ndcSample")
        }
        Button("Subscribe Monthly") {
            purchase(productID: "pro_monthly.ndcSample")
        }
        Text(isPro ? "Pro user!" : "Free user")
            .foregroundStyle(isPro ? .green : .red)
        Button("Check Sub Status") {
            checkSubStatus()
        }
    }
//    var body: some View {
//        VStack {
//            if let package = package {
//                Button(action: {
//                    isPurchasing = true
//                    Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
//                        isPurchasing = false
//                        
//                        if let error = error {
//                            print("결제 오류: \(error.localizedDescription)")
//                        } else if userCancelled {
//                            print("사용자 결제 취소")
//                        } else if let isPro = customerInfo?.entitlements["Pro"]?.isActive, isPro {
//                            print("Pro 권한 활성화됨")
//                            // 여기에 Pro 사용자용 UI 처리 추가
//                        } else {
//                            print("결제는 되었지만 Entitlement 활성화 실패")
//                        }
//                    }
//                }) {
//                    Text(isPurchasing ? "결제 중..." : "Pro 구독 구매하기")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .disabled(isPurchasing)
//            } else {
//                Text("상품 정보를 불러오는 중...")
//            }
//        }
//        .onAppear {
//            Purchases.logLevel = .debug
//            Purchases.configure(withAPIKey: "appl_fLXCXVqTgYpjdpmYooUoUqXjaNL")
//            
//            Purchases.shared.getOfferings { offerings, error in
//                if let package = offerings?.current?.availablePackages.first {
//                    self.package = package
//                } else if let offerings = offerings {
//                    print("Offerings 로드 성공: \(offerings)")
//                    if let pkg = offerings.current?.availablePackages.first {
//                        self.package = pkg
//                    } else {
//                        print("Offering에 사용 가능한 패키지가 없음")
//                    }
//                }
//            }
//        }
//    }
    
    func purchase(productID: String) {
        Task {
            do {
                let products: [StoreProduct] = await Purchases.shared.products([productID])
                guard let product = products.first else {
                    print("Product not found \(productID)")
                    return
                }
                let result = try await Purchases.shared.purchase(product: product)
                customnerInfo = result.customerInfo
                isPro = customnerInfo?.entitlements.active.contains(where: {
                    $0.value.isActive
                }) ?? false
            } catch {
                print("Failed to purchase \(error)")
            }
        }
    }
    
    func checkSubStatus() {
        Task {
            do {
                let info = try await Purchases.shared.customerInfo()
                isPro = info.entitlements.active.contains(where: {
                    $0.value.isActive
                })
            } catch {
                print("Failed to fetch customer info \(error)")
            }
        }
    }
}
