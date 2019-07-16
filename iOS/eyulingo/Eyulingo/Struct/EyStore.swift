//
//  EyStore.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/16.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

struct EyStore: Hashable, Comparable {
    
    static func < (lhs: EyStore, rhs: EyStore) -> Bool {
        if lhs.storeId == nil {
            return true
        }
        if rhs.storeId == nil {
            return false
        }
        return lhs.storeId! < rhs.storeId!
    }
    
    static func == (lhs: EyStore, rhs: EyStore) -> Bool {
        return lhs.storeId == rhs.storeId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(storeId ?? -42)
    }

    var storeId: Int?
    var coverId: String?
    var storeName: String?
    var storeGoods: [EyGoods]?
    var storeComments: [EyComments]?
}
