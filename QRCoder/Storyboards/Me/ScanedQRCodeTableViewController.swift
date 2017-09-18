//
//  ScanedQRCodeTableViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/8/28.
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
        
//        StoreService.shared.payUpgradeToProProduct()
////            .debug("payUpgradeToProProduct")
//            .subscribe()
//            .disposed(by: disposeBag)
        
        StoreService.shared.restorePurchase()
            .debug("restorePurchase")
            .subscribe()
            .disposed(by: disposeBag)
        
        let tableView = self.tableView!
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        // Bind UI
        
        let configureCell: (Int, ScanedQRCodeObject, ScanedQRCodeCell) -> Void = { (row, model, cell) in
            cell.update(with: model)
        }
        
        let showQRCodeDetail = UIBindingObserver(UIElement: self) { (me, code: ScanedQRCodeObject) in
            me.present(QRCodeAlertViewController.self)
        }
        
        let deselectRow = UIBindingObserver(UIElement: self) { (me, indexPath: IndexPath) in
            me.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let bindUI: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcodeResults }.filterNil().bind(to: me.tableView.rx.items(cellType: ScanedQRCodeCell.self), curriedArgument: configureCell),
                state.map { $0.selectedIndexPath }.filterNil().bind(to: deselectRow),
                state.map { $0.selectedQRCode }.filterNil().bind(to: showQRCodeDetail)
            ]
            let events = [
                me.tableView.rx.itemSelected.map(Event.indexPathSelected)
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // Bind Realm
        
        let bindRealm: (ObservableSchedulerContext<State>) -> Observable<Event>  = { _ in
            let realm = try! Realm()
            let objects = realm.objects(ScanedQRCodeObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
            return Observable.collection(from: objects).map(Event.qrcodeResults)
        }
        
        // System
        
        Observable.system(
            initialState: State(),
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback:
                bindUI,
                bindRealm
            )
            //            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
        
        tableView.rx.modelDeleted(ScanedQRCodeObject.self)
            .subscribe(Realm.rx.delete())
            .disposed(by: disposeBag)
    }
    
    struct State {
        var qrcodeResults: Results<ScanedQRCodeObject>!
        var selectedIndexPath: IndexPath?
        var selectedQRCode: ScanedQRCodeObject?
        
        static func reduce(state: State, event: Event) -> State {
            print("Event:", event)
            var newState = state
            switch event {
            case .qrcodeResults(let results):
                newState.qrcodeResults = results
                newState.selectedIndexPath = nil
                newState.selectedQRCode = nil
            case .indexPathSelected(let indexPath):
                newState.selectedIndexPath = indexPath
                newState.selectedQRCode = newState.qrcodeResults?[indexPath.row]
            }
            return newState
        }
    }
    
    enum Event {
        case qrcodeResults(Results<ScanedQRCodeObject>)
        case indexPathSelected(IndexPath)
    }
}

class ScanedQRCodeCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconButton: UIButton!
    
    func update(with model: ScanedQRCodeObject) {
        label.text = model.codeText
    }
}

