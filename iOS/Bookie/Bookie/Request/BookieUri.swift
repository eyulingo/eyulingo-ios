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
    
    // parameters:
    // q - query keyword
    static let bookSearchGetUri = "http://47.103.15.32:8080/search"
    
    // parameters: <none>
    static let myCartGetUri = "http://47.103.15.32:8080/market"
    
    // parameters: <none>
    static let myOrdersGetUri = "http://47.103.15.32:8080/bill"
    
    // parameters:
    // isbn - To remove book's ISBN
    static let removeFromCartPostUri = "http://47.103.15.32:8080/del"
    
    // parameters:
    // isbn
    // count
    // later = true
    static let addToCartPostUri = "http://47.103.15.32:8080/buy"
    
    // parameters:
    // isbn
    // count
    // later = false
    // receiver
    // phoneNo
    // address
    static let purchasePostUri = "http://47.103.15.32:8080/buy"
    
    // == Admin Features ==
    // parameters: <none>
    static let adminGetAllBooks = "http://47.103.15.32:8080/admin/allbook"

    // parameters: <none>
    static let adminGetAllUsers = "http://47.103.15.32:8080/admin/alluser"
}
