//
//  StoreService+Error.swift
//  QRCoder
//
//  Created by luojie on 2017/9/18.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation

extension StoreService {
    
    enum Error: Swift.Error {
        case prodectIdUnFound(String)
    }
}
