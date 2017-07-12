//
//  CreateQRCodeViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/7/12.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import BNKit

class CreateQRCodeViewController: UIViewController, IsInCreateStoryBoard {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet { imageView.image = UIImage.qrCode(from: "Hello Luo Jie!") }
    }
}
