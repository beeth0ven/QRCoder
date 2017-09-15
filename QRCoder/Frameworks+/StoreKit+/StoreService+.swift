//
//  StoreService+.swift
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

protocol IsStoreService {
    
    func isPro() -> Bool
    func payUpgradeToProProduct() -> Observable<Void>
    func restorePurchases() -> Observable<Void>
}

extension StoreService {
    enum Error: Swift.Error {
        case prodectIdUnFound(String)
    }
}

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
                UserDefaults.standard.set(true, forKey: StoreService.isProKey)
            })
            .take(1)
            .debug("payUpgradeToProProduct")
    }
    
    func restorePurchases() -> Observable<Void> {
        fatalError()
    }
}
