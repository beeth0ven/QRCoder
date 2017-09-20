//
//  AppURLQRCodeTableViewController.swift
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
import Photos
import RxRealm
import RealmSwift
import RxFeedback

final class AppURLQRCodeTableViewController: QRCodeDetailTableViewController {}
final class WebsiteURLQRCodeTableViewController: QRCodeDetailTableViewController {}
final class TextQRCodeTableViewController: QRCodeDetailTableViewController {}

class QRCodeDetailTableViewController:
    UITableViewController,
    IsCreateQRCodeTableViewController,
    IsInCreateStoryBoard,
    CanGetImage,
    CanMakeChoice {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectImageCell: UITableViewCell!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var imageViewContainerView: UIView!
    @IBOutlet weak var proLabel: UILabel!
    
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
    
    lazy var selectImageOrUpgradeToProTrigger: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 1 && $0.row == 0 }
        .mapToVoid()
    
    lazy var saveImageTrigger: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 3 && $0.row == 0 }
        .mapToVoid()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = isCreate ? cancelBarButtonItem : deleteBarButtonItem
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        // Bind UI

        let selectImageOrUpgradeToProFeedbackTrigger: Feedback = { state in
            state.flatMapLatest { [weak self] state -> Observable<Event> in
                guard let me = self else { return .empty() }
                if state.isPro {
                    return me.selectImageOrUpgradeToProTrigger
                        .flatMapLatest { [unowned me] _ in me.getImage() }
                        .map(Event.imageSelected)
                }
                return me.selectImageOrUpgradeToProTrigger
                    .flatMapLatest { [unowned me] _ -> Observable<String> in
                        me.makeChoice(message: "Upgrade to Pro version to unlock functionalities.", options: ["Cancel", "Upgrade"])
                    }
                    .filter { $0 == "Upgrade" }
                    .map { _ in Event.upgradeToProTrigger }
            }
        }
        
        let bindUI: Feedback = UI.bind(self) { me, state in
            let centerImage = state.map { $0.qrcode.centerImageData }.map { $0.flatMap { UIImage.init(data: $0) } }.shareReplay(1)
            let subscriptions = [
                state.map { $0.qrcode.codeText }.distinctUntilChanged().bind(to: me.textField.rx.text),
                state.map { $0.qrcodeImage }.bind(to: me.imageView.rx.image(transitionType: "kCATransitionFade")),
                centerImage.bind(to: me.selectedImageView.rx.image),
                state.map { $0.shouldDissmis }.filterNil().bind(to: me.rx.dismiss),
                state.map { $0.imageSaved }.filterNil().map { _ in "QRCode saved!" }.subscribe(onNext: me.showAlert),
                state.map { $0.imageSaveError }.filterNil().map { "Faild to save QRCode: \($0.localizedDescription)!" }.subscribe(onNext: me.showAlert),
                state.map { $0.isPro }.distinctUntilChanged().bind(to: me.proLabel.rx.isHidden)
            ]
            let events = [
                me.textField.rx.text.orEmpty.debounce(0.3, scheduler: MainScheduler.asyncInstance).map(Event.textChanged),
                me.saveBarButtonItem.rx.tap.map { _ in Event.saveQRCode },
                me.deleteBarButtonItem.rx.tap.map { _ in Event.deleteQRCode },
                me.cancelBarButtonItem.rx.tap.map { _ in Event.cancel },
                me.saveImageFeedbackTrigger(state),
                selectImageOrUpgradeToProFeedbackTrigger(state)
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
                saveImage,
                upgradeToPro
            )
            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
    }
}
