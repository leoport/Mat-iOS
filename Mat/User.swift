//
//  User.swift
//  Mat
//
//  Created by 君君 on 15/8/11.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class User {
    var userId: Int
    var sessionId: String
    var cookieId: String

    required init(userId: Int) {
        self.userId = userId
        sessionId = ""
        cookieId = ""
    }
}