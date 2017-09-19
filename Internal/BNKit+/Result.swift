//
//  Result.swift
//  Internal
//
//  Created by luojie on 2017/9/1.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation

public enum Result<E> {
    case success(E)
    case failure(Swift.Error)
}


import RxSwift

extension ObservableType {
    
    public func mapToResult() -> Observable<Result<E>> {
        return self.map(Result.success)
            .catchError { error in .just(.failure(error)) }
    }
}
