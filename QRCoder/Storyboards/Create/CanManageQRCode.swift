//
//  CanManageQRCode.swift
//  QRCoder
//
//  Created by luojie on 2017/9/5.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit

private enum ManageOption {
    case create(QRCodeKind)
    case update(CreatedQRCodeObject)
}

protocol CanManageQRCode {}
extension CanManageQRCode where Self: UIViewController {
    
    func createQRCode(kind: QRCodeKind) {
        manageQRCode(option: .create(kind))
    }
    
    func update(qrcode: CreatedQRCodeObject) {
        manageQRCode(option: .update(qrcode))
    }
    
    private func manageQRCode(option: ManageOption) {
        let vc: IsCreateQRCodeTableViewController & UITableViewController
        switch option.kind {
        case .appURL:
            vc = AppURLQRCodeTableViewController.fromStoryboard()
        case .websiteURL:
            vc = WebsiteURLQRCodeTableViewController.fromStoryboard()
        case .twitter:
            vc = TwitterQRCodeTableViewController.fromStoryboard()
        case .phoneCall:
            vc = PhoneCallQRCodeTableViewController.fromStoryboard()
        case .email:
            vc = EmailQRCodeTableViewController.fromStoryboard()
        case .text:
            vc = TextQRCodeTableViewController.fromStoryboard()
        default:
            fatalError("Unhandle QRCode Kind to init a viewController!")
        }
        vc.isCreate = option.isCreate
        vc.qrcode = option.qrcode
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
}

extension ManageOption {
    
    var kind: QRCodeKind {
        switch self {
        case .create(let kind):
            return kind
        case .update(let object):
            return object.kind
        }
    }
    
    var isCreate: Bool {
        if case .create = self {
            return true
        }
        return false
    }
    
    var qrcode: CreatedQRCode {
        switch self {
        case .create(let kind):
            return CreatedQRCode(kind: kind)
        case .update(let object):
            return CreatedQRCode(codeObject: object)
        }
    }
}
