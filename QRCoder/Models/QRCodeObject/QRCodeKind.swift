//
//  QRCodeKind.swift
//  QRCoder
//
//  Created by luojie on 2017/9/4.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation
import BNKit

enum QRCodeKind: Int {
    case appURL
    case websiteURL
    case twitter
    case phoneCall
    case email
    case text
    case map
    case facetime
    case message
    case youtube
}

extension QRCodeKind {
    
    init(codeText: String) {
        switch codeText {
        case let text where URLVerifier.isPhoneCall(text):
            self = .phoneCall
        case let text where URLVerifier.isFacetime(text):
            self = .facetime
        case let text where URLVerifier.isMessage(text):
            self = .message
        case let text where URLVerifier.isYoutube(text):
            self = .youtube
        case let text where URLVerifier.isMap(text):
            self = .map
        case let text where URLVerifier.isTwitter(text):
            self = .twitter
        case let text where URLVerifier.isEmail(text):
            self = .email
        case let text where URLVerifier.isApppURL(text):
            self = .appURL
        case let text where URLVerifier.isWebsiteURL(text):
            self = .websiteURL
        default:
            self = .text
        }
    }
}

private struct URLVerifier {
    
    public static func isPhoneCall(_ text: String) -> Bool {
        return text.hasPrefix("tel:")
    }
    
    public static func isFacetime(_ text: String) -> Bool {
        return ["facetime:", "facetime-audio:"].contains { text.hasPrefix($0) }
    }
    
    public static func isMessage(_ text: String) -> Bool {
        return text.hasPrefix("sms:")
    }
    
    public static func isYoutube(_ text: String) -> Bool {
        return ["http://www.youtube.com", "https://www.youtube.com"].contains { text.hasPrefix($0) }
    }
    
    public static func isMap(_ text: String) -> Bool {
        return ["http://maps.apple.com", "https://maps.apple.com"].contains { text.hasPrefix($0) }
    }
    
    public static func isTwitter(_ text: String) -> Bool {
        return text.hasPrefix("https://twitter.com")
    }
    
    public static func isEmail(_ text: String) -> Bool {
        guard let emailRegularText = RegularPattern.all["email"]?.valid else {
            fatalError("RegularPattern email is nil")
        }
        return text.hasPrefix("mailto:") || (text =~ emailRegularText)
    }
    
    public static func isApppURL(_ text: String) -> Bool {
        return ["https://itunes.apple.com:"].contains { text.hasPrefix($0) }
    }
    
    public static func isWebsiteURL(_ text: String) -> Bool {
        return ["http://", "https://"].contains { text.hasPrefix($0) }
    }
}

