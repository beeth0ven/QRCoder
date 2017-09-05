//
//  CreateQRCodeRootTableViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/9/5.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateQRCodeRootTableViewController: UITableViewController, IsInCreateStoryBoard, CanManageQRCode {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let createQRCode = UIBindingObserver(UIElement: self) { (me, kind: QRCodeKind) in
            me.createQRCode(kind: kind)
        }
        
        tableView.rx.itemSelected
            .map { $0.section }
            .map(QRCodeKind.init(rawValue: ))
            .filterNil()
            .bind(to: createQRCode)
            .disposed(by: disposeBag)
    }
}
