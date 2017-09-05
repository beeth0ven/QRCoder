//
//  CanManageQRCode.swift
//  QRCoder
//
//  Created by luojie on 2017/9/5.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit

protocol CanManageQRCode {}
extension CanManageQRCode where Self: UIViewController {
    
    func update(qrcode: CreatedQRCodeObject) {
        let vc: IsCreateQRCodeTableViewController & UITableViewController
        switch qrcode.kind {
        case .twitter:
            vc = TwitterQRCodeTableViewController.fromStoryboard()
        default:
            vc = AppURLQRCodeTableViewController.fromStoryboard()
        }
        vc.isCreate = false
        vc.qrcode = CreatedQRCode(codeObject: qrcode)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func createQRCode(kind: QRCodeKind) {
        let vc: IsCreateQRCodeTableViewController & UITableViewController
        switch kind {
        case .twitter:
            vc = TwitterQRCodeTableViewController.fromStoryboard()
        default:
            vc = AppURLQRCodeTableViewController.fromStoryboard()
        }
        vc.isCreate = true
        vc.qrcode = CreatedQRCode(kind: kind)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
}
