//
//  CanMakeChoice.swift
//  Internal
//
//  Created by luojie on 2017/9/19.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import RxSwift

public protocol CanMakeChoice {}

extension CanMakeChoice where Self: UIViewController {
    
    public func makeChoice<Option: HasTitle>(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert, options: [Option]) -> Observable<Option> {
        
        return Observable.create { [weak self] (observer) in
            guard let me = self else { return Disposables.create() }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            options
                .map { option in
                    UIAlertAction(title: option.title, style: .default) { _ in
                        observer.onNext(option)
                        observer.onCompleted()
                    }
                }
                .forEach(alertController.addAction)
            me.present(alertController, animated: true, completion: nil)
            return Disposables.create { [weak alertController] in
                alertController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

public protocol HasTitle {
    var title: String { get }
}

extension String: HasTitle {
    public var title: String { return self }
}

extension HasTitle where Self: RawRepresentable, Self.RawValue: CustomStringConvertible  {
    var title: String { return rawValue.description }
}
