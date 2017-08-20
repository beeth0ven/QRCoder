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

class CreateQRCodeTableViewController: UITableViewController, IsInCreateStoryBoard, CanGetImage {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var qrcodeCenterImageView: UIImageView!
    @IBOutlet weak var selectImageCell: UITableViewCell!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var imageViewContainerView: UIView!
    
    lazy var selectImage: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 1 && $0.row == 0 }
        .mapToVoid()
    
    lazy var saveImage: Observable<Void> = self.tableView.rx.itemSelected
        .filter { $0.section == 3 && $0.row == 0 }
        .mapToVoid()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qrcodeImage = textField.rx.text.orEmpty
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .map { UIImage.qrCode(from: $0) }
            .shareReplay(1)
            
        qrcodeImage
            .bind(to: imageView.rx.image(transitionType: "kCATransitionFade"))
            .disposed(by: disposeBag)
        
        saveImage
            .map { [unowned self] _ in UIImage(view: self.imageViewContainerView) }
            .flatMapLatest { (image) in
                PHPhotoLibrary.shared().rx.save(image)
                    .materialize()
            }
            .observeOnMainScheduler()
            .subscribe(onNext: { (event) in
                switch event {
                case .next:
                    TipView.show(state: TipView.State.textOnly("QRCode saved!"), delayDismiss: 2)
                case .error(let error):
                    TipView.show(state: TipView.State.textOnly("Faild to save QRCode: \(error.localizedDescription)!"), delayDismiss: 2)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        let image = selectImage
            .flatMapLatest { [unowned self] _ in self.getImage() }
            .shareReplay(1)
        
        image
            .bind(to: qrcodeCenterImageView.rx.image)
            .disposed(by: disposeBag)
        
        image
            .bind(to: selectedImageView.rx.image)
            .disposed(by: disposeBag)
        
    }
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

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}
