//
//  MeViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/8/21.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import BNKit
import RxSwift
import RxCocoa
import Internal
import RxFeedback
import RxRealm
import RealmSwift

class ScanedQRCodeTableViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        let realm = try! Realm()
        Observable.collection(from: realm.objects(QRCode.self))
            .observeOnMainScheduler()
            .bind(to: tableView.rx.items(cellType: ScanedQRCodeCell.self)) { row, model, cell in
                cell.update(with: model)
            }
            .disposed(by: disposeBag)
        
    }
}

class ScanedQRCodeCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconButton: UIButton!
    
    func update(with model: QRCode) {
        label.text = model.codeText
    }
}
