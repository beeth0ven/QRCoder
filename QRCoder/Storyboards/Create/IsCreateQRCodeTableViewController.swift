//
//  IsCreateQRCodeTableViewController.swift
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

protocol IsCreateQRCodeTableViewController {
    var qrcode: CreatedQRCode! { get set }
    var isCreate: Bool { get set }
    var saveImageTrigger: Observable<Void> { get }
}

extension IsCreateQRCodeTableViewController where Self: UITableViewController {
    
    typealias State = CreateQRCodeState
    typealias Event = CreateQRCodeEvent
    
    var showAlert: (String) -> Void {
        return { text in
            TipView.show(state: .textOnly(text), delayDismiss: 2)
        }
    }
    
    var saveImageTrigger: (ObservableSchedulerContext<State>) -> Observable<Event> {
        return {  state in
            state.flatMapLatest { [weak self]  state -> Observable<Event> in
                if state.isSavingImage || self == nil {
                    return Observable.empty()
                }
                return self!.saveImageTrigger.map { _ in Event.saveImage }
            }
        }
    }
    
    var bindRealm: (ObservableSchedulerContext<State>) -> Observable<Event> {
        let realm = try! Realm()
        return UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcodeToBeSave }.filterNil().map { $0.object }.subscribe(realm.rx.add(update: true)),
                state.map { $0.qrcodeToBeDelete }.filterNil().map { realm.object(ofType: CreatedQRCodeObject.self, forPrimaryKey: $0.id) }.filterNil().subscribe(realm.rx.delete()),
                ]
            let events = [Observable<Event>.never()]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
    }
    
    var saveImage: (ObservableSchedulerContext<State>) -> Observable<Event> {
        return react(query: { $0.imageToBeSave }, effects: { imageToBeSave in
            PHPhotoLibrary.shared().rx.save(imageToBeSave)
                .mapToResult()
                .map(Event.saveImageResult)
        })
    }
}
