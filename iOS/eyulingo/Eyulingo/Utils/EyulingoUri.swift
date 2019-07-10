//
//  EyulingoUrl.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/8.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

class Eyulingo_UserUri {
    fileprivate static let baseUri = "http://47.103.15.32:8080"
    // parameters:
    // username - username
    // password - password (废话)
    static let loginPostUri = baseUri + "/login"
    
    // parameters: <none>
    static let logOutPostUri = baseUri + "/login?logout"
    
    // parameters:
    // email - 电子邮箱
    static let captchaGetPostUri = baseUri + "/getcode"
    
    // parameters:
    // email - 电子邮箱
    // username - 用户名
    // password - 密码
    // confirm_password - 确认密码
    // confirm_code - 验证码
    static let registerPostUri = baseUri + "/register"
    
    // parameters: <none>
    static let profileGetUri = baseUri + "/myprofile"
    
    // parameters:
    // avatar_id: <MongoDB 图片 ID>
    static let avatarPostUri = baseUri + "/setavatar"
    
    // parameters:
    // origin_password - 旧密码
    // new_password - 新密码
    // confirm_new_password - 确认新密码

    static let passwordChangePostUri = baseUri + "/changepassword"
    
    // parameters:
    // new_email - 新邮箱
    // confirm_code - 确认代码
    static let emailChangePostUri = baseUri + "/changeemail"
    
    // parameters: <none>
    static let addressGetUri = baseUri + "/myaddress"
    
    // parameters:
    // receive_no - 收货人
    // receive_phone - 收货电话
    // receive_address - 收货地址
    static let addAddressPostUri = baseUri + "/addaddress"
    
    // parameters:
    // receive_no - 收货人
    // receive_phone - 收货电话
    // receive_address - 收货地址
    static let removeAddressPostUri = baseUri + "/removeaddress"
    
    // parameters:
    // q - 关键字
    static let searchGoodsGetUri = baseUri + "/searchgood"
    
    // parameters:
    // q - 关键字
    static let searchStoresGetUri = baseUri + "/searchstore"
    
    // parameters:
    // id - 商品 ID
    static let goodDetailGetUri = baseUri + "/gooddetail"
    
    // parameters:
    // id - 店铺 ID
    static let storeDetailGetUri = baseUri + "/storedetail"
    
    // parameters:
    // id - 商品 ID
    // amount - 购买数量
    static let addToCartPostUri = baseUri + "/addtocart"
    
    // parameters: <none>
    static let myCartGetUri = baseUri + "/mycart"
    
    // parameters:
    // id - 商品 ID
    // amount - 商品数量
    // 附注：同时购买多个商品时，ID 和 amount 出现多次。
    // receive_no - 收货人
    // receive_phone - 收货电话
    // receive_address - 收货地址
    static let purchasePostUri = baseUri + "/purchase"
    
    // parameters:
    // id - 商品 ID
    // star_count - 星级 (1, 2, 3, 4, 5)
    // comment_content - 评价内容
    static let commentGoodsPostUri = baseUri + "/commentgood"
    
    // parameters:
    // id - 商店 ID
    // star_count - 星级 (1, 2, 3, 4, 5)
    // comment_content - 评价内容
    static let commentStorePostUri = baseUri + "/commentstore"
    
    // parameters: <none>
    static let purchasedGetUri = baseUri + "/orderlist"
    
    // parameters:
    // fileId - 图像 ID
    static let imageGetUri = baseUri + "/img/download"
    
    // parameters:
    // <Image Object>
    static let imagePostUri = baseUri + "/img/upload"
    
    // parameters:
    // username - 用户名
    static let findCheckCodePostUri = baseUri + "/findcheckcode"
    
    // parameters:
    // username - 用户名
    // new_password - 新密码
    // confirm_password - 确认密码
    // check_code - 验证码
    static let resetPasswordPostUri = baseUri + "/findpassword"
}
