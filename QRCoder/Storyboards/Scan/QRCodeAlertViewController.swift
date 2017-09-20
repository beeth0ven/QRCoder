//
//  QRCodeAlertViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/9/19.
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

class QRCodeAlertViewController: BaseViewController, IsInScanStoryBoard {
    
    var codeText: String?
    
    @IBOutlet private weak var codeDescriptionLabel: UILabel!
    @IBOutlet private weak var codeTextLabel: UILabel!
    @IBOutlet private weak var codeIconButton: UIButton!
    @IBOutlet private weak var codeActionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<State.Event>
        typealias Event = State.Event
        
        // Bind UI
        let bindUI: Feedback = UI.bind(self) { (me, state) in
            let subscriptions = [
                state.map { $0.qrcode }.filterNil().bind(to: me.qrcodeBinder),
                state.map { $0.takeAction }.filterNil().bind(to: me.takeActionBinder),
            ]
            let events = [
                me.codeActionButton.rx.tap.map { _ in Event.takeAction }
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // Bind Realm
        let realm = try! Realm()

        let bindRealm: Feedback = { state in
            Observable<Int>.timer(0.1, scheduler: MainScheduler.instance)
                .map { [weak self] _ -> Event in
                    let maybeQrcode = self?.codeText.flatMap { realm.object(ofType: ScanedQRCodeObject.self, forPrimaryKey: $0) }
                    return Event.maybeQrcode(maybeQrcode)
            }
        }
        
        // RxFeedback
        
        Observable.system(
            initialState: State(),
            reduce: State.reduce,
            scheduler: MainScheduler.asyncInstance,
            scheduledFeedback:
                bindUI,
                bindRealm
            )
            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private var qrcodeBinder: UIBindingObserver<QRCodeAlertViewController, ScanedQRCodeObject> {
        return UIBindingObserver(UIElement: self) { (me, qrcode) in
            me.codeDescriptionLabel.text = "Make a phone call to 898646"
            me.codeActionButton.setTitle("Mak a phone call 1", for: .normal)
            switch qrcode.kind {
            case .text:
                break
            case .appURL:
                break
            case .websiteURL:
                break
            case .twitter:
                break
            case .phoneCall:
                break
            case .email:
                break
            case .map:
                break
            case .facetime:
                break
            case .message:
                break
            case .youtube:
                break
            }
            me.codeTextLabel.text = qrcode.codeText
            me.codeIconButton.setBackgroundImage(qrcode.kind.image, for: .normal)
        }
    }
    
    private var takeActionBinder: UIBindingObserver<QRCodeAlertViewController, ScanedQRCodeObject> {
        return UIBindingObserver(UIElement: self) { (me, qrcode) in
            print("UIBindingObserver takeAction:", qrcode.kind)
            switch qrcode.kind {
            case .text:
                UIPasteboard.general.string = qrcode.codeText
                TipView.show(state: .textOnly("Copied!"), delayDismiss: 2)
            case .appURL, .websiteURL, .twitter, .phoneCall, .email, .map, .facetime, .message, .youtube:
                let application = UIApplication.shared
                guard let url = URL(string: qrcode.codeText), application.canOpenURL(url) else {
                    TipView.show(state: .textOnly("Can't take action with the url!"), delayDismiss: 2)
                    return
                }
                application.open(url)
            }
        }
    }
}

private struct State: IsRxFeedbackState {
    var qrcode: ScanedQRCodeObject?
    var takeAction: ScanedQRCodeObject?
    
    enum Event {
        case maybeQrcode(ScanedQRCodeObject?)
        case takeAction
    }
    
    static func reduce(state: State, event: Event) -> State {
        print("\nEvent:", event)
        var newState = state
        switch event {
        case .maybeQrcode(let qrcode):
            newState.qrcode = qrcode
            newState.takeAction = nil
        case .takeAction:
            newState.takeAction = newState.qrcode
        }
        return newState
    }
}
