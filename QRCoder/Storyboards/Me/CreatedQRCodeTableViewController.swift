//
//  CreatedQRCodeTableViewController.swift
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

class CreatedQRCodeTableViewController: BaseTableViewController, CanManageQRCode {
    
    @IBOutlet private var emptyView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = self.tableView!
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        let configureCell: (Int, CreatedQRCodeObject, QRCodeCell) -> Void = { (row, model, cell) in
            cell.updateUI(with: model)
        }
        
        let updateQRCode = UIBindingObserver(UIElement: self) { (me, code: CreatedQRCodeObject) in
            me.update(qrcode: code)
        }

        let deselectRow = UIBindingObserver(UIElement: self) { (me, indexPath: IndexPath) in
            me.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let emptyViewIsShowed = UIBindingObserver(UIElement: self) { (me, isShowed: Bool) in
            me.tableView.backgroundView = isShowed ? me.emptyView : nil
        }
        
        let bindUI: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcodeResults }.filterNil().bind(to: me.tableView.rx.items(), curriedArgument: configureCell),
                state.map { $0.selectedIndexPath }.filterNil().bind(to: deselectRow),
                state.map { $0.selectedQRCode }.filterNil().bind(to: updateQRCode),
                state.map { $0.qrcodeResults }.filterNil().map { $0.isEmpty }.bind(to: emptyViewIsShowed)
            ]
            let events = [
                me.tableView.rx.itemSelected.map(Event.indexPathSelected)
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // Bind Realm
        
        let realm = try! Realm()
        
        let bindRealm: (ObservableSchedulerContext<State>) -> Observable<Event>  = { _ in
            let objects = realm.objects(CreatedQRCodeObject.self)
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
        
        tableView.rx.modelDeleted(CreatedQRCodeObject.self)
            .subscribe(Realm.rx.delete())
            .disposed(by: disposeBag)
    }
    
    struct State {
        var qrcodeResults: Results<CreatedQRCodeObject>!
        var selectedIndexPath: IndexPath?
        var selectedQRCode: CreatedQRCodeObject?
        
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
        case qrcodeResults(Results<CreatedQRCodeObject>)
        case indexPathSelected(IndexPath)
    }
}
