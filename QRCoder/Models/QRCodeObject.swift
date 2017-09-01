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
    
    public convenience init(codeText: String) {
        self.init()
        
        self.codeText = codeText
    }
}


class ScanedQRCodeObject: QRCodeObject {
    override class func primaryKey() -> String? { return "codeText" }
}

class CreatedQRCodeObject: QRCodeObject {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var centerImageData: Data?
    override class func primaryKey() -> String? { return "id" }
}


struct CreatedQRCode {
    
    let id: String
    var codeText: String = ""
    var createdAt: Date = Date()
    var centerImageData: Data?
    
    init() {
        self.id = UUID().uuidString
    }
    
    init(codeObject: CreatedQRCodeObject) {
        self.id = codeObject.id
        self.codeText = codeObject.codeText
        self.createdAt = codeObject.createdAt
        self.centerImageData = codeObject.centerImageData
    }
    
    var object: CreatedQRCodeObject {
        
        return CreatedQRCodeObject(codeText: self.codeText).then {
            $0.id = self.id
            $0.createdAt = self.createdAt
            $0.centerImageData = self.centerImageData
        }
    }
}


extension CreatedQRCode {
    var image: UIImage? {
        guard !codeText.isEmpty else {
            return nil
        }
        let centerImage = centerImageData.flatMap { UIImage.init(data: $0) }
        return UIImage.qrcode(from: codeText, centerImage: centerImage)
    }
}



