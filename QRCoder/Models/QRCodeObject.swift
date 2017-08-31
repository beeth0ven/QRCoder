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




extension UIImage {
    
    public static func qrcode(from text: String, length: CGFloat = 400, centerImage: UIImage? = nil, tintColor: UIColor? = nil) -> UIImage {
        let data = text.data(using: .utf8)!
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        let ciImage: CIImage
        if let tintColor = tintColor {
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(color: tintColor), forKey: "inputColor0")
            colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
            ciImage = colorFilter.outputImage!
        } else {
            ciImage = qrFilter.outputImage!
        }
        
        let scaleX = length / ciImage.extent.size.width
        let scaleY = length / ciImage.extent.size.height
        let transformedImage = ciImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        let codeImage = UIImage(ciImage: transformedImage)
        let rect = CGRect(origin: .zero, size: codeImage.size)
        UIGraphicsBeginImageContext(codeImage.size)
        codeImage.draw(in: rect)
        if let centerImage = centerImage {
            let centerImageBackgroundRect = CGRect(center: rect.center, size: rect.size /  3.5)
            let centerImageRect = CGRect(center: rect.center, size: rect.size / 4)
            let cornerRadius = centerImageBackgroundRect.width / 15
            let path = UIBezierPath(roundedRect: centerImageBackgroundRect, cornerRadius: cornerRadius)
            UIColor.white.setFill()
            path.fill()
            centerImage.draw(in: centerImageRect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

func /(size: CGSize, unit: CGFloat) -> CGSize {
    return CGSize(width: size.width / unit, height: size.height / unit)
}
