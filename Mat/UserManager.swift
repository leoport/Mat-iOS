//
//  UserManager.swift
//  Mat
//
//  Created by 君君 on 15/8/11.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class UserManager {
    static let Instance =  UserManager()
    var currentUser : User?

    required init() {
        currentUser = nil
    }
}