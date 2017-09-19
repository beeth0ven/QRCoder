//
//  ScanQRCodeViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/7/12.
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

class ScanQRCodeViewController: UIViewController, IsInScanStoryBoard {
    
    @IBOutlet weak var getQRCodeView: GetQRCodeView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let showQRCodeDetail = UIBindingObserver(UIElement: self) { (me, vc: QRCodeAlertViewController) in
            me.present(vc, animated: true)
        }
        
        let shouldCaptureQRCode = UIBindingObserver(UIElement: getQRCodeView) { (view, isOnscreen: Bool) in
            isOnscreen ? view.startCapture() : view.stopCapture()
        }
        
        let bindUI: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcodeAlertViewController }.filterNil().distinctUntilChanged().bind(to: showQRCodeDetail),
                state.map { $0.isOnscreen }.bind(to: shouldCaptureQRCode)
            ]
            let events = [
                me.getQRCodeView.value.map(Event.scanedQRCode),
                me.rx.viewWillAppear.map { _ in Event.viewWillAppear },
                me.rx.viewWillDisappear.map { _ in Event.viewWillDisappear }
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        let bindRealm: (ObservableSchedulerContext<State>) -> Observable<Event>  = UI.bind { state in
            let subscriptions = [state.map { $0.qrcode }.filterNil().distinctUntilChanged().map { ScanedQRCodeObject(codeText: $0) }.subscribe(Realm.rx.add(update: true))]
            let events = [Observable<Event>.never()]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        Observable.system(
            initialState: State(),
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback:
                bindUI,
                react(query: { $0.qrcodeAlertViewController }, effects: {
                    $0.rx.viewWillDisappear.map { _ in Event.viewWillAppear }
                }),
                bindRealm
            )
//            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    struct State {
        var qrcode: String?
        var qrcodeAlertViewController: QRCodeAlertViewController?
        var isOnscreen: Bool = true
        
        static func reduce(state: State, event: Event) -> State {
//            print("Event:", event)
            var newState = state
            switch event {
            case .scanedQRCode(let code):
                if (state.isOnscreen) {
                    newState.qrcode = code
                    newState.qrcodeAlertViewController = QRCodeAlertViewController.fromStoryboard()
                    newState.isOnscreen = false
                }
            case .viewWillAppear:
                newState.qrcode = nil
                newState.qrcodeAlertViewController = nil
                newState.isOnscreen = true
            case .viewWillDisappear:
                newState.isOnscreen = false
            }
            return newState
        }
    }
    
    enum Event {
        case scanedQRCode(String)
        case viewWillAppear
        case viewWillDisappear
    }
}

class QRCodeAlertViewController: BaseViewController, IsInScanStoryBoard {
    
}
