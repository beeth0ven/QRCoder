//
//  IsRxFeedbackState.swift
//  Internal
//
//  Created by luojie on 2017/9/20.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

public protocol IsRxFeedbackState {
    associatedtype Event
    static func reduce(state: Self, event: Event) -> Self
}
