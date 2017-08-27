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

class QRCode: Object {
    
    @objc dynamic var codeText: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    override class func primaryKey() -> String? { return "codeText" }
    
    public convenience init(codeText: String) {
        self.init()
        self.codeText = codeText
    }
}


class ScanedQRCode: QRCode {
    
}

class CreatedQRCode: QRCode {
    
}
