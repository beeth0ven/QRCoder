//
//  TwitterQRCodeTableViewController.swift
//  QRCoder
//
//  Created by luojie on 2017/9/4.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import BNKit
import RxSwift
import RxCocoa
import Internal
import Photos
import RxRealm
import RealmSwift
import RxFeedback

class TwitterQRCodeTableViewController: UITableViewController, IsCreateQRCodeTableViewController, IsInCreateStoryBoard, CanGetImage {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var imageViewContainerView: UIView!
    
    typealias State = CreateQRCodeState
    typealias Event = CreateQRCodeEvent
    
    var qrcode: CreatedQRCode!
    var isCreate = true
    
    private lazy var cancelBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    private lazy var saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    private lazy var deleteBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Delete", style: .plain, target: nil, action: nil)
        item.tintColor = UIColor.red
        return item
    }()
    
    lazy var saveImageTrigger: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 3 && $0.row == 0 }
        .mapToVoid()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = isCreate ? cancelBarButtonItem : deleteBarButtonItem
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        // Bind UI
        
        let bindUI: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcode.codeText }.distinctUntilChanged().map(TwitterURLConvertor.username).bind(to: me.textField.rx.text),
                state.map { $0.qrcode.codeText }.distinctUntilChanged().map { $0.isEmpty ? "empty" : $0 }.bind(to: me.urlLabel.rx.text),
                state.map { $0.qrcodeImage }.bind(to: me.imageView.rx.image(transitionType: "kCATransitionFade")),
                state.map { $0.shouldDissmis }.filterNil().bind(to: me.rx.dismiss),
                state.map { $0.imageSaved }.filterNil().map { _ in "QRCode saved!" }.subscribe(onNext: me.showAlert),
                state.map { $0.imageSaveError }.filterNil().map { "Faild to save QRCode: \($0.localizedDescription)!" }.subscribe(onNext: me.showAlert),
                ]
            let events = [
                me.textField.rx.text.orEmpty.debounce(0.3, scheduler: MainScheduler.asyncInstance).map(TwitterURLConvertor.url).map(Event.textChanged),
                Observable.just(UIImage(named: "Twitter")!).map(Event.imageSelected),
                me.saveBarButtonItem.rx.tap.map { _ in Event.saveQRCode },
                me.deleteBarButtonItem.rx.tap.map { _ in Event.deleteQRCode },
                me.cancelBarButtonItem.rx.tap.map { _ in Event.cancel },
                me.saveImageTrigger(state)
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // RxFeedback
        
        let qrcode: CreatedQRCode = isCreate ? CreatedQRCode(kind: .twitter) : self.qrcode!
        
        Observable.system(
            initialState: State(qrcode: qrcode),
            reduce: State.reduce,
            scheduler: MainScheduler.asyncInstance,
            scheduledFeedback:
                bindUI,
                bindRealm,
                saveImage
            )
            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
    }
}

fileprivate struct TwitterURLConvertor {
    
    private static let twitterBaseURL = "https://twitter.com/"
    
    fileprivate static func username(from url: String) -> String {
        return url.hasPrefix(twitterBaseURL)
            ? String(url.dropFirst(twitterBaseURL.count))
            : ""
    }
    
    fileprivate static func url(from username: String) -> String {
        return username.isEmpty
            ? ""
            : "\(twitterBaseURL)\(username)"
    }
}

