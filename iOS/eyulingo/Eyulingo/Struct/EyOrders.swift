//
//  EyOrders.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/22.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

struct EyOrders {
    var orderId: Int?
    var receiver: String?
    var receiverPhone: String?
    var receiverAddress: String?
    var storeId: Int?
    var storeName: String?
    var transportingMethod: String?
    var status: OrderState?
    var items: [EyOrderItems]?
    var createTime: String?
    var rated: Bool?
    var rateLevel: Int?
    var commentContent: String?
    
    func calculatePrice() -> Decimal {
        var sumUp: Decimal = Decimal.zero
        for itemObject in items ?? [] {
            sumUp = sumUp.advanced(by: (itemObject.currentPrice ?? Decimal.zero) * Decimal(integerLiteral: itemObject.amount ?? 0))
        }
        return sumUp
    }
}

struct EyOrderItems {
    var goodsId: Int?
    var goodsName: String?
    var storeId: Int?
    var storeName: String?
    var currentPrice: Decimal?
    var amount: Int?
    var description: String?
    var imageId: String?
}

enum OrderState: Int {
    case unpurchased = 0
    case pending = 1
    case transporting = 2
    case received = 3
    case invalid = 4
}
