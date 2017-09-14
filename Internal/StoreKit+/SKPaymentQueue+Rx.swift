//
//  SKPaymentQueue+Rx.swift
//  Internal
//
//  Created by luojie on 2017/9/14.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

extension Reactive where Base: SKPaymentQueue {
    
    public var updatedTransactions: Observable<[SKPaymentTransaction]> {
        
        return Observable.create { observer in
            
            let paymentTransactionObserver = PaymentTransactionObserverClosures(onUpdatedTransactions: { transactions in
                observer.onNext(transactions)
            })
            self.base.add(paymentTransactionObserver)
            
            return Disposables.create {
                self.base.remove(paymentTransactionObserver)
            }
        }
    }
    
    public var removedTransactions: Observable<[SKPaymentTransaction]> {
        
        return Observable.create { observer in
            
            let paymentTransactionObserver = PaymentTransactionObserverClosures(onRemovedTransactions: { transactions in
                observer.onNext(transactions)
            })
            self.base.add(paymentTransactionObserver)
            
            return Disposables.create {
                self.base.remove(paymentTransactionObserver)
            }
        }
    }
    
}


private final class PaymentTransactionObserverClosures: NSObject, SKPaymentTransactionObserver {
    
    private let _onUpdatedTransactions: (([SKPaymentTransaction]) -> Void)?
    private let _onRemovedTransactions: (([SKPaymentTransaction]) -> Void)?
    
    init(onUpdatedTransactions: (([SKPaymentTransaction]) -> Void)? = nil, onRemovedTransactions: (([SKPaymentTransaction]) -> Void)? = nil) {
        _onUpdatedTransactions = onUpdatedTransactions
        _onRemovedTransactions = onRemovedTransactions
        super.init()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        _onUpdatedTransactions?(transactions)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        _onRemovedTransactions?(transactions)
    }
}
