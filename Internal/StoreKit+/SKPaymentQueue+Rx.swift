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
import BNKit

extension Reactive where Base: SKPaymentQueue {
    
    public func payProduct(_ product: SKProduct) -> Observable<Void> {
        guard Base.canMakePayments() else {
            return .error(SKPaymentQueue.Error.paymentPermissionDeny)
        }
        let payment = SKPayment(product: product)
        defer { base.add(payment) }
        return updatedTransactions
            .map { $0.first(where: { $0.payment.productIdentifier == product.productIdentifier }) }
            .filterNil()
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { transaction -> Observable<Void> in
                print("transactionState:", transaction.transactionState.rawValue)
                switch (transaction.transactionState, transaction.error) {
                case (.purchased, _):
                    self.base.finishTransaction(transaction)
                    return .just(())
                case (.failed, let error?):
                    print("error:", error.localizedDescription)
                    self.base.finishTransaction(transaction)
                    return .error(error)
                default:
                    return .empty()
                }
        }
    }
    
    public func restorePurchases() -> Observable<[SKPaymentTransaction]> {
        guard Base.canMakePayments() else {
            return .error(SKPaymentQueue.Error.paymentPermissionDeny)
        }
        defer { base.restoreCompletedTransactions() }
        return updatedTransactions
            .observeOn(MainScheduler.asyncInstance)
            .map { transactions -> [SKPaymentTransaction] in
                let restored = transactions.filter { $0.transactionState == .restored }
                restored.forEach { self.base.finishTransaction($0) }
                return restored
        }
        
    }
        
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
    
//    public var removedTransactions: Observable<[SKPaymentTransaction]> {
//
//        return Observable.create { observer in
//
//            let paymentTransactionObserver = PaymentTransactionObserverClosures(onRemovedTransactions: { transactions in
//                observer.onNext(transactions)
//            })
//            self.base.add(paymentTransactionObserver)
//
//            return Disposables.create {
//                self.base.remove(paymentTransactionObserver)
//            }
//        }
//    }
    
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
