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
        
        //        let qrcode = getQRCodeView.value
        //            .take(1)
        //            .distinctUntilChanged()
        //            .delay(0.3, scheduler: MainScheduler.instance)
        //            .shareReplay(1)
        //
        //        qrcode
        //            .bind(to: label.rx.text)
        //            .disposed(by: reusableDisboseBag)
        //
        //        qrcode
        //            .bind(to: UIBindingObserver(UIElement: self) { (me, code) in
        //                me.present(QRCodeAlertViewController.self)
        //            })
        //            .disposed(by: reusableDisboseBag)
        
        Observable<Any>.system(
            initialState: State(),
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            feedback:
                UI.bind { (state) in
                    ([state.map { $0.qrcodeAlertViewController }.filterNil().subscribe(onNext: { [weak self] in self?.present($0, animated: true) })],
                     [getQRCodeView.value.distinctUntilChanged().map(Event.scanedQRCode) ])
                },
                react(query: { $0.qrcodeAlertViewController }, effects: { $0.rx.viewWillDisappear.map { _ in Event.viewWillAppear } })
            )
            .debug()
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
                } else {
                    newState.qrcode = nil
                    newState.qrcodeAlertViewController = nil
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
