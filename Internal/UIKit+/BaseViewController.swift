//
//  BaseViewController.swift
//  Internal
//
//  Created by luojie on 2017/8/13.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {
    
    @IBAction public func dissmiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction public func pop() {
        
        if navigationController?.topViewController === self {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}


open class BaseTableViewController: UITableViewController {
    
    @IBAction public func dissmiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction public func pop() {
        
        if navigationController?.topViewController === self {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}


open class BaseCollectionViewController: UICollectionViewController {
    
    @IBAction public func dissmiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction public func pop() {
        
        if navigationController?.topViewController === self {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}

