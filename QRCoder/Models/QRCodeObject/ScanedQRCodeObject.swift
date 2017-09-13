//
//  ScanedQRCodeObject.swift
//  QRCoder
//
//  Created by luojie on 2017/9/8.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class ScanedQRCodeObject: QRCodeObject {
    
    public convenience init(codeText: String) {
        self.init()
        self.codeText = codeText
        self.kind = QRCodeKind(codeText: codeText)
    }
    
    override class func primaryKey() -> String? { return "codeText" }
}


