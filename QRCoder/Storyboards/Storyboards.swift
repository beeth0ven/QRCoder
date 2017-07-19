//
//  Storyboards.swift
//  QRCoder
//
//  Created by luojie on 2017/7/12.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import BNKit

protocol IsInMainStoryBoard: IsInStoryboard {}
extension IsInMainStoryBoard {
    static var storyboardName: String { return "Main" }
}

protocol IsInScanStoryBoard: IsInStoryboard {}
extension IsInScanStoryBoard {
    static var storyboardName: String { return "Scan" }
}

protocol IsInCreateStoryBoard: IsInStoryboard {}
extension IsInCreateStoryBoard {
    static var storyboardName: String { return "Create" }
}

protocol IsInMeStoryBoard: IsInStoryboard {}
extension IsInMeStoryBoard {
    static var storyboardName: String { return "Me" }
}
