//
//  CreateQRCodeTableViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/7/12.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import BNKit
import RxSwift
import RxCocoa

class CreateQRCodeTableViewController: UITableViewController, IsInCreateStoryBoard {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.rx.text.orEmpty
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .map { UIImage.qrCode(from: $0) }
            .bind(to: imageView.rx.image(transitionType: "kCATransitionFade"))
            .disposed(by: disposeBag)
    }
}

class CreatePhoneCallQRCodeTableViewController: UITableViewController, IsInCreateStoryBoard {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.rx.text.orEmpty
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .map { UIImage.qrCode(from: $0) }
            .bind(to: imageView.rx.image(transitionType: "kCATransitionFade"))
            .disposed(by: disposeBag)
    }
}
