//
//  CartRefreshManager.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/19.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation


class CartRefreshManager {
    
    private static let maxDirtyReadLimit: Int = 10
    private static var secretCounter: Int = 0
    private static var isModified: Bool = true
    
    static func shouldCartRefresh() -> Bool {
        if isModified || secretCounter >= maxDirtyReadLimit {
            isModified = false
            secretCounter = 0
            return true
        } else {
            secretCounter += 1
            return false
        }
    }
    
    static func setModifiedState() {
        isModified = true
        secretCounter = 0
    }
}
