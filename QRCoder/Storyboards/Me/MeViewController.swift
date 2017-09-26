//
//  MeViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/8/21.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Internal
import BNKit
import StoreKit

class MeViewController: UITableViewController {
    
    private typealias RestorePurchaseState = ActionState<Void, [SKPaymentTransaction]>
    
    private lazy var restorePurchasesTrigger: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 2 && $0.row == 0 }
        .mapToVoid()
    
    private lazy var feedbackTrigger: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 3 && $0.row == 0 }
        .mapToVoid()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storeService = StoreService.shared
        
        RestorePurchaseState.system(
            inputs: restorePurchasesTrigger,
            workFactory: { _ in storeService.restorePurchase() }
            )
            .bind(to: restorePurchaseBinder)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: tableView.rx.deselectRow())
            .disposed(by: disposeBag)
        
        feedbackTrigger
            .bind(to: AlertService.shared.gotoAppStoreAndShowCurrentApp())
            .disposed(by: disposeBag)
    }
    
    // Binder
    
    private var restorePurchaseBinder: UIBindingObserver<MeViewController, RestorePurchaseState> {
        
        return UIBindingObserver(UIElement: self) { (me, state) in
            switch state {
            case .empty:
                break
            case .triggered:
                TipView.show(state: .spinnerWithText("Restoring..."))
            case .success:
                TipView.update(state: .textOnly("Success to Restore."))
            case .error(let error):
                TipView.update(state: .textOnly("Fail to Restore \(error.localizedDescription)"))
            }
        }
    }
}
