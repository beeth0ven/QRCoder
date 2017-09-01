//
//  UIImage+qrcode.swift
//  Internal
//
//  Created by luojie on 2017/9/1.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

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
