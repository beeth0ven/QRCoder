//
//  UIButton+Rx.swift
//  Internal
//
//  Created by luojie on 2017/9/1.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    
    public func image(for state: UIControlState = .normal) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver(UIElement: base, binding: { (button, image) in
            button.setImage(image, for: state)
        })
    }
}
