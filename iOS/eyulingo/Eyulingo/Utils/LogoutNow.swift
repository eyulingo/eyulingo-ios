//
//  LogoutNow.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/9.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Alamofire
import Foundation

class LogOutHelper {
    static func logOutNow(_ handler: @escaping () -> ()) {
        CartRefreshManager.setModifiedState()
        Alamofire.request(Eyulingo_UserUri.logOutPostUri, method: .post).response(completionHandler: { _ in
            handler()
        })
    }
}
