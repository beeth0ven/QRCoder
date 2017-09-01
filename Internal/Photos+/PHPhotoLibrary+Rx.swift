//
//  PHPhotoLibrary+Rx.swift
//  Internal
//
//  Created by luojie on 2017/9/1.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import RxSwift
import Photos

extension Reactive where Base: PHPhotoLibrary {
    
    public func save(_ image: UIImage) -> Observable<Void> {
        
        return Observable.create { (observer) in
            
            self.base.performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { (_, error) in
                switch error {
                case nil:
                    observer.onNext(())
                    observer.onCompleted()
                case let error?:
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
}
