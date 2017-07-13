//
//  ScanQRCodeViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/7/12.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import BNKit
import RxSwift
import RxCocoa
import GoogleMobileVision
import GoogleMVDataOutput

class ScanQRCodeViewController: UIViewController, IsInScanStoryBoard {
    
    @IBOutlet weak var getQRCodeView: GetQRCodeView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getQRCodeView.value
            .distinctUntilChanged()
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
//        let url = URL(string: "App-Prefs:root=WIFI")!
//        
//        if UIApplication.shared.canOpenURL(url){
//            UIApplication.shared.open(url)
//        }
    }
}


