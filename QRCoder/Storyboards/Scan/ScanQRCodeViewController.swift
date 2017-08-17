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

class ScanQRCodeViewController: UIViewController, IsInScanStoryBoard {
    
    @IBOutlet weak var getQRCodeView: GetQRCodeView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getQRCodeView = self.getQRCodeView!
        
        let showQRCodeDetail = UIBindingObserver(UIElement: self) { (me, vc: QRCodeAlertViewController) in
            me.present(vc, animated: true)
        }
        
        let bindUI: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind { state in
            let subscriptions = [state.map { $0.qrcodeAlertViewController }.filterNil().distinctUntilChanged().bind(to: showQRCodeDetail)]
            let events = [getQRCodeView.value.map(Event.scanedQRCode)]
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
                })
            )
            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    
    struct State {
        var qrcode: String?
        var qrcodeAlertViewController: QRCodeAlertViewController?
        var isOnscreen: Bool = true
        
        static func reduce(state: State, event: Event) -> State {
            print("Event:", event)
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
            }
            return newState
        }
    }
    
    enum Event {
        case scanedQRCode(String)
        case viewWillAppear
    }
}

class QRCodeAlertViewController: BaseViewController, IsInScanStoryBoard {
    
}
