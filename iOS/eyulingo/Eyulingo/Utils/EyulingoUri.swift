//
//  EyulingoUrl.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/8.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

class EyulingoUri {
    static let baseUri = "http://47.103.15.32:8080"
    // parameters:
    // username - username
    // password - password (废话)
    
    static let loginPostUri = baseUri + "/login"
    
    // parameters:
    // phone_nu - 手机号
    static let captchaGetPostUri = baseUri +  "/getcode"
    
    // parameters:
    // “phone_nu” - 手机号码
    // “username” - 用户名
    // “password” - 密码
    // “confirm_password” - 确认密码
    // “confirm_code” - 验证码
    static let registerPostUri = "/register"
    
    static let profileGetUri = "/"
}
