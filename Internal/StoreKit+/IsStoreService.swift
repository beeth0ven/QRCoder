//
//  IsStoreService.swift
//  Internal
//
//  Created by luojie on 2017/9/14.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

public protocol IsStoreService {
    
    func products() -> Observable<[SKProduct]>
}

public typealias ProductIdentifier = String

public class StoreService {
    
    private let _productIds: Set<ProductIdentifier>
    private var _request: SKProductsRequest
    
    public init(productIds: Set<ProductIdentifier>) {
        _productIds = productIds
        _request = SKProductsRequest(productIdentifiers: _productIds)
    }
    
    public func products() -> Observable<[SKProduct]> {
        _request.cancel()
        _request = SKProductsRequest(productIdentifiers: _productIds)
        
        let result = Observable.merge(
            _request.rx.response.map { $0.products }.map(Result.success),
            _request.rx.error.map(Result.failure)
        )
        
        let products: Observable<[SKProduct]> = result.map { result in
            switch result {
            case .success(let value):
                return value
            case .failure(let error):
                throw error
            }
        }
        
        _request.start()
        
        return products
    }
}

