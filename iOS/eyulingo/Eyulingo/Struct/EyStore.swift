//
//  EyStore.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/16.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit
import Alamofire

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
    var storePhone: String?
    var storeAddress: String?
    var storeGoods: [EyGoods]?
    var storeComments: [EyComments]?
    
    var distAvatarId: String?
    var distName: String?
//    var distPhone: String?
//    var distAddress: String?
    
    var imageCache: UIImage?
    
    var currentDistance: Double?
    
    var commentStar: Double?
    var commentPeopleCount: Int?
    
    var heatCount: Int?
    
    var longitude: Double?
    
    var latitude: Double?
    
    func getStoreCoverAsync(handler: @escaping (UIImage) -> ()) {
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
    
    func getDistAvatarAsync(handler: @escaping (UIImage) -> ()) {
        if distAvatarId == nil {
            return
        }
        let params: Parameters = [
            "fileId": distAvatarId!
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
