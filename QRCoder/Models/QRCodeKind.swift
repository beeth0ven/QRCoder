//
//  QRCodeKind.swift
//  QRCoder
//
//  Created by luojie on 2017/9/4.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation

enum QRCodeKind: Int {
    case appURL
    case websiteURL
    case twiter
    case phoneCall
    case email
    case text
    case gotoLocation   // Goto a place
}
