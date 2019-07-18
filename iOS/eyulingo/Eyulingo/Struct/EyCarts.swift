//
//  EyCarts.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/18.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire

struct EyCarts: Hashable, Comparable {
    static func < (lhs: EyCarts, rhs: EyCarts) -> Bool {
        if lhs.goodsId == nil {
            return true
        }
        if rhs.goodsId == nil {
            return false
        }
        return lhs.goodsId! < rhs.goodsId!
    }
    
    static func == (lhs: EyCarts, rhs: EyCarts) -> Bool {
        return lhs.goodsId == rhs.goodsId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(goodsId ?? -42)
        hasher.combine(storeId ?? -42)
    }
    
    var goodsId: Int?
    var goodsName: String?
    var coverId: String?
    var storeId: Int?
    var amount: Int?
    var storeName: String?
    var storage: Int?
    var price: Decimal?
    
    var imageCache: UIImage?
    
    func getCoverAsync(handler: @escaping (UIImage) -> ()) {
        if coverId == nil {
            return
        }
        let params: Parameters = [
            "fileId": coverId!
        ]
        Alamofire.request(Eyulingo_UserUri.imageGetUri, method: .get, parameters: params)
            .responseData(completionHandler: { responseData in
                if responseData.data == nil {
                    return
                }
                let image = UIImage(data: responseData.data!)
                if image != nil {
                    handler(image!)
                }
            })
    }
}
