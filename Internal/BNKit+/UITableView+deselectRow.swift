//
//  UITableView+deselectRow.swift
//  Internal
//
//  Created by luojie on 2017/9/19.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    
    public func deselectRow(animated: Bool = true) -> UIBindingObserver<Base, IndexPath> {
        return UIBindingObserver(UIElement: base) { (base, indexPath) in
            base.deselectRow(at: indexPath, animated: animated)
        }
    }
}
