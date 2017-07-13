//
//  QRCodeAction.swift
//  QRCoder
//
//  Created by luojie on 2017/7/13.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import Foundation

enum QRCodeAction {
    case openWebURL     // Open a web page
    case phoneCall      // Give a phone call
    case addContact     // Add a contact
    case gotoLocation   // Goto a place
    case encoded        // Protect by a password
}
