//
//  CreatedQRCodeObject.swift
//  QRCoder
//
//  Created by luojie on 2017/9/8.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

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
    var kind: QRCodeKind = .text
    
    init(kind: QRCodeKind) {
        self.id = UUID().uuidString
        self.kind = kind
    }
    
    init(codeObject: CreatedQRCodeObject) {
        self.id = codeObject.id
        self.codeText = codeObject.codeText
        self.createdAt = codeObject.createdAt
        self.centerImageData = codeObject.centerImageData
        self.kind = codeObject.kind
    }
    
    var object: CreatedQRCodeObject {
        
        return CreatedQRCodeObject().then {
            $0.id = self.id
            $0.codeText = self.codeText
            $0.createdAt = self.createdAt
            $0.centerImageData = self.centerImageData
            $0.kind = self.kind
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
