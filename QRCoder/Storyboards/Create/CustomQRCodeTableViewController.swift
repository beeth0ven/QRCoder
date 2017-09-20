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


class TwitterQRCodeTableViewController: CustomQRCodeTableViewController {}
class PhoneCallQRCodeTableViewController: CustomQRCodeTableViewController {}
class EmailQRCodeTableViewController: CustomQRCodeTableViewController {}

class CustomQRCodeTableViewController: UITableViewController, IsCreateQRCodeTableViewController, IsInCreateStoryBoard, CanGetImage {
    
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

        let kind = qrcode.kind
        
        let bindUI: Feedback = UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcode.codeText }.distinctUntilChanged().map(kind.displayName).bind(to: me.textField.rx.text),
                state.map { $0.qrcode.codeText }.distinctUntilChanged().map { $0.isEmpty ? "empty" : $0 }.bind(to: me.urlLabel.rx.text),
                state.map { $0.qrcodeImage }.bind(to: me.imageView.rx.image(transitionType: "kCATransitionFade")),
                state.map { $0.shouldDissmis }.filterNil().bind(to: me.rx.dismiss),
                state.map { $0.imageSaved }.filterNil().map { _ in "QRCode saved!" }.subscribe(onNext: me.showAlert),
                state.map { $0.imageSaveError }.filterNil().map { "Faild to save QRCode: \($0.localizedDescription)!" }.subscribe(onNext: me.showAlert),
                ]
            let events = [
                me.textField.rx.text.orEmpty.debounce(0.3, scheduler: MainScheduler.asyncInstance).map(kind.codeText).map(Event.textChanged),
                Observable.just(kind.image).map(Event.imageSelected),
                me.saveBarButtonItem.rx.tap.map { _ in Event.saveQRCode },
                me.deleteBarButtonItem.rx.tap.map { _ in Event.deleteQRCode },
                me.cancelBarButtonItem.rx.tap.map { _ in Event.cancel },
                me.saveImageFeedbackTrigger(state)
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // RxFeedback
                
        Observable.system(
            initialState: State(qrcode: qrcode, isPro: StoreService.shared.isPro()),
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

private extension QRCodeKind {
    
    private static let twitterBaseURL = "https://twitter.com/"
    private static let phoneCallBaseURL = "tel:"
    
    func displayName(from codeText: String) -> String {
        switch self {
        case .twitter:
            return codeText.dropFirst(text: QRCodeKind.twitterBaseURL)
        case .phoneCall:
            return codeText.dropFirst(text: QRCodeKind.phoneCallBaseURL)
        default:
            return codeText
        }
    }
    
    func codeText(from displayName: String) -> String {
        switch self {
        case .twitter:
            return displayName.insertAtFirst(text: QRCodeKind.twitterBaseURL)
        case .phoneCall:
            return displayName.insertAtFirst(text: QRCodeKind.phoneCallBaseURL)
        default:
            return displayName
        }
    }
}

private extension String {
    
    func dropFirst(text: String) -> String {
        return self.hasPrefix(text)
                ? String(self.dropFirst(text.count))
                : ""
    }
    
    func insertAtFirst(text: String) -> String {
        return self.isEmpty
            ? ""
            : "\(text)\(self)"
    }
}


