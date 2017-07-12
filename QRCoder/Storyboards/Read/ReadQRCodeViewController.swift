//
//  ReadQRCodeViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/7/12.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import BNKit

class ReadQRCodeViewController: UIViewController, IsInReadStoryBoard {
    
    @IBOutlet weak var getQRCodeView: GetQRCodeView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getQRCodeView.value
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}
