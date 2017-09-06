//
//  CreateQRCodeState.swift
//  QRCoder
//
//  Created by luojie on 2017/9/1.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import UIKit
import Internal

struct CreateQRCodeState {
    var qrcode: CreatedQRCode
    var qrcodeImage: UIImage?
    var shouldDissmis: Void?
    var qrcodeToBeSave: CreatedQRCode?
    var qrcodeToBeDelete: CreatedQRCode?
    
    var imageToBeSave: UIImage?
    var isSavingImage = false
    var imageSaved: Void?
    var imageSaveError: Error?
    
    init(qrcode: CreatedQRCode) {
        self.qrcode = qrcode
        self.qrcodeImage = qrcode.image
    }
    
    private mutating func reset() {
        shouldDissmis = nil
        qrcodeToBeSave = nil
        qrcodeToBeDelete = nil
        imageToBeSave = nil
        imageSaved = nil
        imageSaveError = nil
    }
    
    static func reduce(state: CreateQRCodeState, event: CreateQRCodeEvent) -> CreateQRCodeState {
        print("Event:", event)
        var newState = state
        newState.reset()
        switch event {
        case .textChanged(let text):
            newState.qrcode.codeText = text
            newState.qrcodeImage = newState.qrcode.image
        case .imageSelected(let image):
            newState.qrcode.centerImageData = image.flatMap { UIImageJPEGRepresentation($0, 0.7) }
            newState.qrcodeImage = newState.qrcode.image
        case .saveQRCode:
            newState.shouldDissmis = ()
            newState.qrcodeToBeSave = newState.qrcode
        case .deleteQRCode:
            newState.shouldDissmis = ()
            newState.qrcodeToBeDelete = newState.qrcode
        case .cancel:
            newState.shouldDissmis = ()
        case .saveImage:
            if !newState.qrcode.codeText.isEmpty {
                newState.isSavingImage = true
                newState.imageToBeSave = newState.qrcodeImage
            }
        case .saveImageResult(.success):
            newState.isSavingImage = false
            newState.imageSaved = ()
        case .saveImageResult(.failure(let error)):
            newState.isSavingImage = false
            newState.imageSaveError = error
        }
        return newState
    }
}

enum CreateQRCodeEvent {
    case textChanged(String)
    case imageSelected(UIImage?)
    case saveQRCode
    case deleteQRCode
    case cancel
    case saveImage
    case saveImageResult(Result<Void>)
}

extension CreateQRCodeState: CustomStringConvertible {
    
    var description: String {
        return
        """
        CreateQRCodeState(
            qrcode: \(qrcode)
            qrcodeImage: \(String(describing: qrcodeImage))
            shouldDissmis: \(String(describing: shouldDissmis))
            qrcodeToBeDelete: \(String(describing: qrcodeToBeDelete))
            imageToBeSave: \(String(describing: imageToBeSave))
            isSavingImage: \(isSavingImage)
            imageSaved: \(String(describing: imageSaved))
            imageSaveError: \(String(describing: imageSaveError))
        )
        """
    }
}

//extension CreatedQRCode: CustomStringConvertible {
//
//    var description: String {
//        return
//        """
//        CreatedQRCode(
//            id: \(id)
//            codeText: \(String(describing: codeText))
//            createdAt: \(String(describing: createdAt))
//            centerImageData: \(String(describing: centerImageData))
//            kind: \(String(describing: kind))
//        )
//        """
//    }
//}

