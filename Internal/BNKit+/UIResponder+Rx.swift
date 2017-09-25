//
//  UIResponder+Rx.swift
//  Internal
//
//  Created by luojie on 2017/9/25.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIResponder {
    
    public var becomeFirstResponder: UIBindingObserver<Base, Void> {
        return UIBindingObserver(UIElement: base) { responder, _ in
            if !responder.isFirstResponder {
                responder.becomeFirstResponder()
            }
        }
    }
}
