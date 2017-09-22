//
//  IsAlertService.swift
//  QRCoder
//
//  Created by luojie on 2017/9/22.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Internal

protocol IsAlertService {
    func confirmUpgradeToProVersion(in viewController: UIViewController) -> Observable<Void>
    func confirmDeleteQRCode(in viewController: UIViewController) -> Observable<Void>
}
