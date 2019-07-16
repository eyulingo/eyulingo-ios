//
//  EyGoods.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/16.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Foundation

struct EyGoods {
    var goodsId: Int?
    var goodsName: String?
    var coverId: String?
    var description: String?
    var storeId: Int?
    var storeName: Int?
    var storage: Int?
    var price: Decimal?
    var couponPrice: Decimal?
    var tags: [String] = []
    var comments: [EyComments] = []
    
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
