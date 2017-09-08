//
//  QRCode.swift
//  QRCoder
//
//  Created by luojie on 2017/8/20.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class QRCodeObject: Object {
    
    @objc dynamic var codeText: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var _kind: Int = 0
}

extension QRCodeObject {
    var kind: QRCodeKind {
        get { return QRCodeKind(rawValue: _kind) ?? .text }
        set { _kind = newValue.rawValue }
    }
}




