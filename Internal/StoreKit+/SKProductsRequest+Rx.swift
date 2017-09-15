//
//  SKProductsRequest+Rx.swift
//  Internal
//
//  Created by luojie on 2017/9/14.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

private final class SKProductsRequestDelegateProxy: DelegateProxy, SKProductsRequestDelegate {
    
    let responseSubject = PublishSubject<SKProductsResponse>()
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        responseSubject.onNext(response)
    }
}

extension SKProductsRequestDelegateProxy: DelegateProxyType {
    
    typealias HasDelegate = SKProductsRequest
    typealias Delegate = SKProductsRequestDelegate
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        guard let hasDelegate = object as? HasDelegate else {
            fatalError("Type of object is mismatch.")
        }
        return hasDelegate.delegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let hasDelegate = object as? HasDelegate else {
            fatalError("Type of object is mismatch.")
        }
        hasDelegate.delegate = delegate as? Delegate
    }
    
}

extension Reactive where Base: SKProductsRequest {
    
    private var delegate: SKProductsRequestDelegateProxy {
        return SKProductsRequestDelegateProxy.proxyForObject(base)
    }
    
    public var response: Observable<SKProductsResponse> {
        return delegate.responseSubject.asObservable()
    }
    
    public var completed: Observable<Void> {
        return delegate.methodInvoked(#selector(SKProductsRequestDelegate.requestDidFinish(_:)))
            .mapToVoid()
    }
    
    public var error: Observable<Error> {
        return delegate.methodInvoked(#selector(SKProductsRequestDelegate.request(_:didFailWithError:)))
            .map { $0[1] as! Error }
    }
}
