//
//  EyulingoUri.mm
//  Eyulingo
//
//  Created by 法好 on 2019/7/8.
//  Copyright © 2019 yuetsin. All rights reserved.
//


class Eyulingo_UserUri {
    
    static const string baseUri = "http://47.103.15.32:8080";
    
    // parameters:
    // username - username
    // password - password (废话)
    static const string loginPostUri = baseUri + "/login";
    
    // parameters: <none>
    static const string logOutPostUri = baseUri + "/logout";
    
    // parameters:
    // email - 电子邮箱
    static const string captchaGetPostUri = baseUri + "/getcode";
    
    // parameters:
    // email - 电子邮箱
    // username - 用户名
    // password - 密码
    // confirm_password - 确认密码
    // confirm_code - 验证码
    static const string registerPostUri = baseUri + "/register";
    
    // parameters: <none>
    static const string profileGetUri = baseUri + "/myprofile";
    
    // parameters:
    // avatar_id: <MongoDB 图片 ID>
    static const string avatarPostUri = baseUri + "/setavatar";
    
    // parameters:
    // origin_password - 旧密码
    // new_password - 新密码
    // confirm_new_password - 确认新密码

    static const string passwordChangePostUri = baseUri + "/changepassword";
    
    // parameters:
    // new_email - 新邮箱
    // confirm_code - 确认代码
    static const string emailChangePostUri = baseUri + "/changeemail";
    
    // parameters: <none>
    static const string addressGetUri = baseUri + "/myaddress";
    
    // parameters:
    // receive_name - 收货人
    // receive_phone - 收货电话
    // receive_address - 收货地址
    static const string addAddressPostUri = baseUri + "/addaddress";
    
    // parameters:
    // receive_name - 收货人
    // receive_phone - 收货电话
    // receive_address - 收货地址
    static const string removeAddressPostUri = baseUri + "/removeaddress";
    
    // parameters:
    // old_receive_name - 原收货人
    // old_receive_phone - 原收货电话
    // old_receive_address - 原收货地址
    // new_receive_name - 新收货人
    // new_receive_phone - 新收货电话
    // new_receive_address - 新收货地址
    static const string changeAddressPostUri = baseUri + "/changeaddress";
    
    // parameters:
    // q - 关键字
    static const string searchGoodsGetUri = baseUri + "/searchgood";
    
    // parameters:
    // q - 关键字
    static const string searchStoresGetUri = baseUri + "/searchstore";
    
    // parameters:
    // q - 关键字
    // long - 经度
    // lat - 纬度
    static const string searchStoresByDistanceGetUri = baseUri + "/searchstorebydistance";
    
    // parameters:
    // q - 关键字
    static const string searchStoresByRateGetUri = baseUri + "/searchstorebystar";
    
    // parameters:
    // q - 关键字
    static const string searchStoresByHeatGetUri = baseUri + "/searchstorebysold";
    
    // parameters:
    // q - 关键字
    static const string suggestionGetUri = baseUri + "/suggests";
    
    // parameters:
    // q - 关键字
    static const string storeSuggestionGetUri = baseUri + "/suggeststore";
    
    // parameters:
    // id - 商品 ID
    static const string goodDetailGetUri = baseUri + "/gooddetail";
    
    // parameters:
    // id - 店铺 ID
    static const string storeDetailGetUri = baseUri + "/storedetail";
    
    // parameters:
    // id - 商品 ID
    // amount - 购买数量
    static const string addToCartPostUri = baseUri + "/addtocart";
    
    // parameters:
    // id - 商品 ID
    static const string removeFromCartPostUri = baseUri + "/deletecart";
    
    // parameters:
    // id - 商品 ID
    // amount - 购买数量
    static const string modifyAmountFromCartPostUri = baseUri + "/editcart";
    
    // parameters: <none>
    static const string myCartGetUri = baseUri + "/mycart";
    
    // parameters:
    // id - 商品 ID
    // amount - 商品数量
    // 附注：同时购买多个商品时，ID 和 amount 出现多次。
    // receive_no - 收货人
    // receive_phone - 收货电话
    // receive_address - 收货地址
    static const string purchasePostUri = baseUri + "/purchase";
    
    // parameters:
    // order_id - 要付款的订单 ID 数组（多个）
    static const string payPostUri = baseUri + "/pay";
    
    // parameters:
    // order_id - 要删除的订单 ID （单个）
    static const string removeOrderPostUri = baseUri + "/deleteorder";
    
    // parameters:
    // id - 商品 ID
    // star_count - 星级 (1, 2, 3, 4, 5)
    // comment_content - 评价内容
    static const string commentGoodsPostUri = baseUri + "/commentgood";
    
    // parameters:
    // id - 商店 ID
    // star_count - 星级 (1, 2, 3, 4, 5)
    // comment_content - 评价内容
    static const string commentStorePostUri = baseUri + "/commentstore";
    
    // parameters:
    // order_id - 订单 ID
    // star_count - 星级 (1, 2, 3, 4, 5)
    // comment_content - 评价内容
    static const string rateOrderPostUri = baseUri + "/rateorder";
    
    // parameters: <none>
    static const string purchasedGetUri = baseUri + "/orderlist";
    
    // parameters:
    // fileId - 图像 ID
    static const string imageGetUri = baseUri + "/img/download";
    
    // parameters:
    // <Image Object>
    static const string imagePostUri = baseUri + "/img/upload";
    
    // parameters:
    // username - 用户名
    static const string findCheckCodePostUri = baseUri + "/findcheckcode";
    
    // parameters:
    // username - 用户名
    // new_password - 新密码
    // confirm_password - 确认密码
    // check_code - 验证码
    static const string resetPasswordPostUri = baseUri + "/findpassword";
}
