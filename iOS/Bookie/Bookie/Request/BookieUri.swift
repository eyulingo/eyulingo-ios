//
//  BookieUri.swift
//  Bookie
//
//  Created by 法好 on 2019/7/1.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

class BookieUri {
    // parameters:
    // username - username
    // password - password (废话)
    static let loginPostUri = "http://47.103.15.32:8080/login"
    
    // parameters:
    // username - username
    // password - password
    // confirmPassword - password confirmation
    static let registerPostUri = "http://47.103.15.32:8080/reg"
    
    // parameters:
    // fileId - cover image file id
    static let imageCoverGetUri = "http://47.103.15.32:8080/img/download"
}
