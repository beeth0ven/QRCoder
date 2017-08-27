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
        
        let tableView = self.tableView!
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        // Bind UI
        
        let configureCell: (Int, ScanedQRCode, ScanedQRCodeCell) -> Void = { (row, model, cell) in
            cell.update(with: model)
        }
        
        let showQRCodeDetail = UIBindingObserver(UIElement: self) { (me, code: QRCode) in
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
            let objects = realm.objects(ScanedQRCode.self)
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
        
        tableView.rx.modelDeleted(QRCode.self)
            .subscribe(Realm.rx.delete())
            .disposed(by: disposeBag)
    }
    
    struct State {
        var qrcodeResults: Results<ScanedQRCode>!
        var selectedIndexPath: IndexPath?
        var selectedQRCode: QRCode?
        
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
                newState.selectedQRCode = newState.qrcodeResults![indexPath.row]
            }
            return newState
        }
    }
    
    enum Event {
        case qrcodeResults(Results<ScanedQRCode>)
        case indexPathSelected(IndexPath)
    }
}

class ScanedQRCodeCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconButton: UIButton!
    
    func update(with model: ScanedQRCode) {
        label.text = model.codeText
    }
}
