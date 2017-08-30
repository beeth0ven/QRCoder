//
//  CreateQRCodeTableViewController.swift
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

class CreateQRCodeTableViewController: UITableViewController, IsInCreateStoryBoard, CanGetImage {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectImageCell: UITableViewCell!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var imageViewContainerView: UIView!
    
    private var qrcode: CreatedQRCode!
    private var isCreate = true
    
    private lazy var cancelBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    private lazy var saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    private lazy var deleteBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
    
    lazy var selectImage: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 1 && $0.row == 0 }
        .mapToVoid()
    
    lazy var saveImage: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 3 && $0.row == 0 }
        .mapToVoid()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = isCreate ? cancelBarButtonItem : deleteBarButtonItem
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        // Bind UI
        
        let showAlert: (String) -> Void = { text in
            TipView.show(state: .textOnly(text), delayDismiss: 2)
        }
        
        let saveImageTrigger: (ObservableSchedulerContext<State>) -> Observable<Event> = {  state in
            state.flatMapLatest { [weak self]  state -> Observable<Event> in
                if state.isSavingImage || self == nil {
                    return Observable.empty()
                }
                return self!.saveImage.map { _ in Event.saveImage }
            }
        }
        
        let bindUI: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind(self) { me, state in
            let centerImage = state.map { $0.qrcode.centerImageData }.map { $0.flatMap { UIImage.init(data: $0) } }.shareReplay(1)
            let subscriptions = [
                state.map { $0.qrcodeImage }.bind(to: me.imageView.rx.image(transitionType: "kCATransitionFade")),
                centerImage.bind(to: me.selectedImageView.rx.image),
                state.map { $0.shouldDissmis }.filterNil().bind(to: me.rx.dismiss),
                state.map { $0.imageSaved }.filterNil().map { _ in "QRCode saved!" }.subscribe(onNext: showAlert),
                state.map { $0.imageSaveError }.filterNil().map { "Faild to save QRCode: \($0.localizedDescription)!" }.subscribe(onNext: showAlert),
            ]
            let events = [
                me.textField.rx.text.orEmpty.debounce(0.3, scheduler: MainScheduler.asyncInstance).map(Event.textChanged),
                me.selectImage.flatMapLatest { [unowned me] _ in me.getImage() }.observeOnMainScheduler().map(Event.imageSelected),
                me.saveBarButtonItem.rx.tap.map { _ in Event.saveQRCode },
                me.deleteBarButtonItem.rx.tap.map { _ in Event.deleteQRCode },
                me.cancelBarButtonItem.rx.tap.map { _ in Event.cancel },
                saveImageTrigger(state)
            ]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // Bind Realm
        
        let realm = try! Realm()
        
        let bindRealm: (ObservableSchedulerContext<State>) -> Observable<Event> = UI.bind(self) { me, state in
            let subscriptions = [
                state.map { $0.qrcodeToBeSave }.filterNil().subscribe(realm.rx.add(update: true)),
                state.map { $0.qrcodeToBeDelete }.filterNil().subscribe(realm.rx.delete()),
            ]
            let events = [Observable<Event>.never()]
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
        
        // React
        
        let saveImage: (ObservableSchedulerContext<State>) -> Observable<Event> = react(query: { $0.imageToBeSave }, effects: { imageToBeSave in
            PHPhotoLibrary.shared().rx.save(imageToBeSave)
                .map(Result.success)
                .catchError { error in .just(.failure(error)) }
                .map(Event.saveImageResult)
        })
        
        Observable.system(
            initialState: State(qrcode: CreatedQRCode()),
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback:
                bindUI,
                bindRealm,
                saveImage
            )
            .debug("State")
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    struct State {
        let qrcode: CreatedQRCode
        var qrcodeImage: UIImage?
        var shouldDissmis: Void?
        var qrcodeToBeSave: CreatedQRCode?
        var qrcodeToBeDelete: CreatedQRCode?
        
        var isSavingImage = false
        var imageToBeSave: UIImage?
        var imageSaved: Void?
        var imageSaveError: Error?
        
        init(qrcode: CreatedQRCode) {
            self.qrcode = qrcode
            self.qrcodeImage = qrcode.image
        }
        
        private mutating func reset() {
            shouldDissmis = nil
            qrcodeToBeSave = nil
            qrcodeToBeDelete = nil
            imageToBeSave = nil
            imageSaved = nil
            imageSaveError = nil
        }
        
        static func reduce(state: State, event: Event) -> State {
            var newState = state
            newState.reset()
            switch event {
            case .textChanged(let text):
                newState.qrcode.codeText = text
                newState.qrcodeImage = newState.qrcode.image
            case .imageSelected(let image):
                newState.qrcode.centerImageData = image.flatMap { UIImageJPEGRepresentation($0, 0.7) }
                newState.qrcodeImage = newState.qrcode.image
            case .saveQRCode:
                newState.shouldDissmis = ()
                newState.qrcodeToBeSave = newState.qrcode
            case .deleteQRCode:
                newState.shouldDissmis = ()
                newState.qrcodeToBeDelete = newState.qrcode
            case .cancel:
                newState.shouldDissmis = ()
            case .saveImage:
                if !newState.qrcode.codeText.isEmpty {
                    newState.isSavingImage = true
                    newState.imageToBeSave = newState.qrcodeImage
                }
            case .saveImageResult(.success):
                newState.isSavingImage = false
                newState.imageSaved = ()
            case .saveImageResult(.failure(let error)):
                newState.isSavingImage = false
                newState.imageSaveError = error
            }
            return newState
        }
    }
    
    enum Event {
        case textChanged(String)
        case imageSelected(UIImage?)
        case saveQRCode
        case deleteQRCode
        case cancel
        case saveImage
        case saveImageResult(Result<Void>)
    }
}


enum Result<E> {
    case success(E)
    case failure(Swift.Error)
}






extension CreatedQRCode {
    var image: UIImage? {
        guard !codeText.isEmpty else {
            return nil
        }
        let centerImage = centerImageData.flatMap { UIImage.init(data: $0) }
        return UIImage.qrcode(from: codeText, centerImage: centerImage)
    }
}

extension UIImage {
    
    public static func qrcode(from text: String, length: CGFloat = 400, centerImage: UIImage? = nil, tintColor: UIColor? = nil) -> UIImage {
        let data = text.data(using: .utf8)!
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        let ciImage: CIImage
        if let tintColor = tintColor {
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(color: tintColor), forKey: "inputColor0")
            colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
            ciImage = colorFilter.outputImage!
        } else {
            ciImage = qrFilter.outputImage!
        }
        
        let scaleX = length / ciImage.extent.size.width
        let scaleY = length / ciImage.extent.size.height
        let transformedImage = ciImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        let codeImage = UIImage(ciImage: transformedImage)
        let rect = CGRect(origin: .zero, size: codeImage.size)
        UIGraphicsBeginImageContext(codeImage.size)
        codeImage.draw(in: rect)
        if let centerImage = centerImage {
            let centerImageBackgroundRect = CGRect(center: rect.center, size: rect.size /  3.5)
            let centerImageRect = CGRect(center: rect.center, size: rect.size / 4)
            let cornerRadius = centerImageBackgroundRect.width / 10
            let path = UIBezierPath(roundedRect: centerImageBackgroundRect, cornerRadius: cornerRadius)
            UIColor.white.setFill()
            path.fill()
            centerImage.draw(in: centerImageRect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

func /(size: CGSize, unit: CGFloat) -> CGSize {
    return CGSize(width: size.width / unit, height: size.height / unit)
}


extension Reactive where Base: PHPhotoLibrary {
    
    func save(_ image: UIImage) -> Observable<Void> {
        
        return Observable.create { (observer) in
            
            self.base.performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { (_, error) in
                switch error {
                case nil:
                    observer.onNext(())
                    observer.onCompleted()
                case let error?:
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
}

extension Reactive where Base: UIButton {
    
    func image(for state: UIControlState = .normal) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver(UIElement: base, binding: { (button, image) in
            button.setImage(image, for: state)
        })
    }
}

class CreatePhoneCallQRCodeTableViewController: UITableViewController, IsInCreateStoryBoard {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.rx.text.orEmpty
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .map { UIImage.qrCode(from: $0) }
            .bind(to: imageView.rx.image(transitionType: "kCATransitionFade"))
            .disposed(by: disposeBag)
    }
}

//extension UIImage {
//    convenience init(view: UIView) {
//        UIGraphicsBeginImageContext(view.frame.size)
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        self.init(cgImage: image.cgImage!)
//    }
//}

