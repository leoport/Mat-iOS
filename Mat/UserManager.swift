//
//  UserManager.swift
//  Mat
//
//  Created by 君君 on 15/8/11.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class UserManager {
    private static let INSTANCE =  UserManager()
    static var currentUser : User? {
        get {
            return INSTANCE.mCurrentUser
        } set (newUser){
            INSTANCE.setCurrentUser(newUser)
        }
    }
    private var mCurrentUser : User?

    required init() {
        mCurrentUser = nil
        initLoginDB()
        print(Configure.LOGIN_DB_PATH)
    }

    private func initLoginDB() {
        let loginDB = FMDatabase(path: Configure.LOGIN_DB_PATH)
        
        if !loginDB.open() {
            print("UserManager:initLoginDB: Unable to open database")
            return
        }
        
        let query = "CREATE TABLE IF NOT EXISTS login("
                  + "username varchar(11) PRIMARY KEY,"
                  + "cookie_id varchar(64),"
                  + "last_login timestamp);"
        if !loginDB.executeUpdate(query, withArgumentsInArray: nil) {
            print("UserManager:initLoginDB: create table failed: \(loginDB.lastErrorMessage())")
        }

        if let rs = loginDB.executeQuery("SELECT username, cookie_id FROM login ORDER BY last_login DESC;", withArgumentsInArray: nil) {
            if rs.next() {
                let userId = Int(rs.intForColumn("username"))
                let cookieId = rs.stringForColumn("cookie_id")
                mCurrentUser = User(userId: userId)
                mCurrentUser?.cookieId = cookieId
            }
        }
        
        loginDB.close()
    }

    private func setCurrentUser(newUser: User?) {
        let loginDB = FMDatabase(path: Configure.LOGIN_DB_PATH)
        if !loginDB.open() {
            print("UserManager:setCurrentUser: Unable to open database")
            return
        }
        if newUser != nil {
            if !loginDB.executeUpdate("INSERT OR REPLACE INTO login VALUES(?, ?, CURRENT_TIMESTAMP);", withArgumentsInArray: [newUser!.userId, newUser!.cookieId]) {
                print("UserManager:setCurrentUser: set nonnull user failed: \(loginDB.lastErrorMessage())")
            }
        }
        loginDB.close()
        mCurrentUser = newUser
    }
    static func logoutCurrentUser() {
        if (INSTANCE.mCurrentUser == nil) { return }

        let loginDB = FMDatabase(path: Configure.LOGIN_DB_PATH)
        if !loginDB.open() {
            print("UserManager:setCurrentUser: Unable to open database")
            return
        }
        if !loginDB.executeUpdate("UPDATE login SET cookie_id = '' WHERE username = ?;", withArgumentsInArray: [INSTANCE.mCurrentUser!.userId]) {
            print("UserManager:setCurrentUser: failed to erase current cookie_id in database")
        }
        loginDB.close()
    }
}