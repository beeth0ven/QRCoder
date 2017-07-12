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

protocol IsInReadStoryBoard: IsInStoryboard {}
extension IsInReadStoryBoard {
    static var storyboardName: String { return "Read" }
}

protocol IsInCreateStoryBoard: IsInStoryboard {}
extension IsInCreateStoryBoard {
    static var storyboardName: String { return "Create" }
}
