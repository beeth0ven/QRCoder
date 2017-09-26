//
//  AlertService.swift
//  QRCoder
//
//  Created by luojie on 2017/9/22.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Internal


final class AlertService {
    
    static let shared = AlertService()
}

extension AlertService: IsAlertService {
    
    func confirmUpgradeToProVersion(in viewController: UIViewController) -> Observable<Void> {
        return UIAlertController.Builder(message: "Upgrade to Pro version to unlock functionalities.")
            .addOption(title: "Cancel", style: .cancel)
            .addOption(title: "Upgrade", style: .default)
            .showAlert(in: viewController)
            .filter { $0 == "Upgrade" }
            .mapToVoid()
    }
    
    func confirmDeleteQRCode(in viewController: UIViewController) -> Observable<Void> {
        return UIAlertController.Builder(message: "Are you sure you want to delete this QRCode?")
            .addOption(title: "Cancel", style: .cancel)
            .addOption(title: "Delete", style: .destructive)
            .showAlert(in: viewController)
            .filter { $0 == "Delete" }
            .mapToVoid()
    }
    
    func gotoAppStoreAndShowCurrentApp() -> UIBindingObserver<UIApplication, Void> {
        return UIBindingObserver(UIElement: UIApplication.shared) { (application, _) in
            if let url = URL(string: "https://itunes.apple.com/us/app/qrcode-scan-create/id1258476173?ls=1&mt=8")
                , application.canOpenURL(url) {
                application.open(url)
            }
        }
    }
}
