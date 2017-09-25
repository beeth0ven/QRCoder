//
//  UIAlertController+Builder.swift
//  Internal
//
//  Created by luojie on 2017/9/19.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import RxSwift

extension UIAlertController {
    
    public class Builder {
        public typealias Option = (title: String, style: UIAlertActionStyle)
        private let title: String?
        private let message: String?
        private let preferredStyle: UIAlertControllerStyle
        private var options = [Option]()
        
        public init(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert) {
            self.title = title
            self.message = message
            self.preferredStyle = preferredStyle
        }
        
        public func addOption(title: String, style: UIAlertActionStyle = .default) -> UIAlertController.Builder {
            self.options.append((title, style))
            return self
        }
        
        public func addOptions(_ titles: [String]) -> UIAlertController.Builder {
            let options: [Option] = titles.map { ($0, .default) }
            self.options.append(contentsOf: options)
            return self
        }
        
        public func addOptions(_ options: [Option]) -> UIAlertController.Builder {
            self.options.append(contentsOf: options)
            return self
        }
        
        public func showAlert(in viewController: UIViewController) -> Observable<String> {
            let (title, message, preferredStyle, options) = (self.title, self.message, self.preferredStyle, self.options)
            
            return Observable.create { [weak viewController] (observer) in
                guard let viewController = viewController else { return Disposables.create() }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                options
                    .map { option in
                        UIAlertAction(title: option.title, style: option.style) { _ in
                            observer.onNext(option.title)
                            observer.onCompleted()
                        }
                    }
                    .forEach(alertController.addAction)
                viewController.present(alertController, animated: true, completion: nil)
                return Disposables.create { [weak alertController] in
                    alertController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
