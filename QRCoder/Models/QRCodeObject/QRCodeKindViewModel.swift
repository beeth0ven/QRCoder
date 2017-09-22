//
//  QRCodeKindViewModel.swift
//  QRCoder
//
//  Created by luojie on 2017/9/22.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import UIKit

struct QRCodeKindViewModel {
    
    let codeKind: QRCodeKind
    
    var image: UIImage {
        let imageName: String
        switch codeKind {
        case .appURL:
            imageName = "AppStore"
        case .websiteURL:
            imageName = "Safari"
        case .twitter:
            imageName = "Twitter"
        case .phoneCall:
            imageName = "Phone"
        case .email:
            imageName = "Email"
        case .text:
            imageName = "Text"
        case .map:
            imageName = "Map"
        case .facetime:
            imageName = "Facetime"
        case .message:
            imageName = "Message"
        case .youtube:
            imageName = "YouTube"
        }
        guard let image = UIImage(named: imageName) else {
            fatalError("Can't get image from name: \(imageName)")
        }
        return image
    }
    
    var displayTitle: String {
        switch codeKind {
        case .text:
            return "This is plain text"
        case .appURL:
            return "This is a app download URL"
        case .websiteURL:
            return "This is a website URL"
        case .twitter:
            return "This is a twitter home page URL"
        case .phoneCall:
            return "This a phone number"
        case .email:
            return "This is an email address"
        case .map:
            return "This is an address"
        case .facetime:
            return "This is a facetime address"
        case .message:
            return "This is a message address"
        case .youtube:
            return "This is a youtube URL"
        }
    }
    
    var actionTitle: String {
        switch codeKind {
        case .text:
            return "Copy It"
        case .appURL:
            return "Download The App"
        case .websiteURL:
            return "Goto The Website"
        case .twitter:
            return "Visit The Home Page"
        case .phoneCall:
            return "Mak A Phone Call"
        case .email:
            return "Send Mail To Him Or Her"
        case .map:
            return "Go To The Place"
        case .facetime:
            return "Mak A Facetime Call"
        case .message:
            return "Send Message To Him Or Her"
        case .youtube:
            return "Watch The Video"
        }
    }
}
