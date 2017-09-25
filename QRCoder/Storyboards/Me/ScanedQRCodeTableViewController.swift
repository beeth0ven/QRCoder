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

final class ScanedQRCodeTableViewController: BaseTableViewController {
    
    @IBOutlet private var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = self.tableView!
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        Observable.system(
            initialState: State(),
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback:
                uiFeedback,
                realmFeedback
            )
            //            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
        
        tableView.rx.modelDeleted(ScanedQRCodeObject.self)
            .subscribe(Realm.rx.delete())
            .disposed(by: disposeBag)
    }
    
    private var uiFeedback: State.Feedback {
        
        let configureCell: (Int, ScanedQRCodeObject, QRCodeCell) -> Void = { (row, model, cell) in
            cell.updateUI(with: model)
        }
        
        let showQRCodeDetail = UIBindingObserver(UIElement: self) { (me, code: ScanedQRCodeObject) in
            me.present(QRCodeAlertViewController.self) { $0.codeText = code.codeText }
        }
        
        let deselectRow = UIBindingObserver(UIElement: self) { (me, indexPath: IndexPath) in
            me.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let emptyViewIsShowed = UIBindingObserver(UIElement: self) { (me, isShowed: Bool) in
            me.tableView.backgroundView = isShowed ? me.emptyView : nil
        }
        
        return UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcodeResults }.filterNil().bind(to: me.tableView.rx.items(), curriedArgument: configureCell),
                state.map { $0.selectedIndexPath }.filterNil().bind(to: deselectRow),
                state.map { $0.selectedQRCode }.filterNil().bind(to: showQRCodeDetail),
                state.map { $0.qrcodeResults }.filterNil().map { $0.isEmpty }.bind(to: emptyViewIsShowed)
            ]
            let events = [
                me.tableView.rx.itemSelected.map(Event.indexPathSelected)
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
    }
    
    private var realmFeedback: State.Feedback {
        return { _ in
            let realm = try! Realm()
            let objects = realm.objects(ScanedQRCodeObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
            return Observable.collection(from: objects).map(Event.qrcodeResults)
        }
    }
    
    struct State {
        typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<Event>
        
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

class QRCodeCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var codeTextLabel: UILabel!
    @IBOutlet private weak var iconButton: UIButton!
    
    func updateUI(with model: QRCodeObject) {
        let viewModel = QRCodeKindViewModel(codeKind: model.kind)
        label.text = viewModel.displayTitle
        codeTextLabel.text = model.codeText
        iconButton.setBackgroundImage(viewModel.image, for: .normal)
    }
}

