//
//  QRCodeAction+URL.swift
//  QRCoder
//
//  Created by luojie on 2017/7/13.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation

extension QRCodeAction {
    
    func toURL() -> String {
        return ""
    }
    
    init(url: String) throws {
        self = .openWebURL
    }
    
    func decode(usePassword: String) throws ->  QRCodeAction {
        return .openWebURL
    }
}

