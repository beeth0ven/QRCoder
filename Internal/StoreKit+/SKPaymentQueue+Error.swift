//
//  SKPaymentQueue+Error.swift
//  Internal
//
//  Created by luojie on 2017/9/18.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import StoreKit

extension SKPaymentQueue {
    
    public enum Error: Swift.Error {
        case paymentPermissionDeny
    }
}

extension SKPaymentQueue.Error: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .paymentPermissionDeny:
            return "Payment Not available."
        }
    }
}
