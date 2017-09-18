//
//  StoreService.swift
//  QRCoder
//
//  Created by luojie on 2017/9/15.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa
import Internal

final class StoreService {
    
    static let shared = StoreService()
    
    public static let upgradeToProProdectId = "1709151023"
    fileprivate let _service: Internal.StoreService  = .init(productIds: [upgradeToProProdectId])
}


extension StoreService: IsStoreService {
    
    private static let isProKey = "QRCoder.StoreService.isPro"
    
    func isPro() -> Bool {
        return UserDefaults.standard.bool(forKey: StoreService.isProKey)
    }
    
    func payUpgradeToProProduct() -> Observable<Void> {
        return _service.products()
            .map { products -> SKProduct in
                guard  let upgradeToProProduct = products.first(where: { $0.productIdentifier == StoreService.upgradeToProProdectId }) else {
                    throw StoreService.Error.prodectIdUnFound(StoreService.upgradeToProProdectId)
                }
                return upgradeToProProduct
            }.flatMapLatest { product -> Observable<Void> in
                return SKPaymentQueue.default().rx.payProduct(product)
            }.do(onNext: { _ in
                print("UserDefaults.standard.set(true, forKey: StoreService.isProKey)")
                UserDefaults.standard.set(true, forKey: StoreService.isProKey)
            })
            .take(1)
            .debug("payUpgradeToProProduct")
    }
    
    func restorePurchase() -> Observable<[SKPaymentTransaction]> {

        return SKPaymentQueue.default().rx.restorePurchases()
            .take(1)
            .do(onNext: { transactions in
                if transactions.contains(where: { $0.payment.productIdentifier == StoreService.upgradeToProProdectId }) {
                    print("UserDefaults.standard.set(true, forKey: StoreService.isProKey)")
                    UserDefaults.standard.set(true, forKey: StoreService.isProKey)
                }
            })
        
    }
}
