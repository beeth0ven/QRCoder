//
//  IsStoreService.swift
//  QRCoder
//
//  Created by luojie on 2017/9/18.
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
    func restorePurchase() -> Observable<[SKPaymentTransaction]>
}