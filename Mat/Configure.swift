//
//  Configure.swift
//  Mat
//
//  Created by 君君 on 15/8/10.
//  Copyright © 2015年 梁晶. All rights reserved.
//

class Configure {
    static let LOGIN_URL       = "http://leopub.org/auth/login_check.php"
    static let MSG_FETCH_URL   = "http://leopub.org/msg/client.php?since=%@"
    static let MSG_CONFIRM_URL = "http://leopub.org/msg/confirm_done.php?src=%d&msg=%d&status=%d&since=%@";
    static let DOCUMENTS_FOLDER = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    static let LOGIN_DB_PATH = DOCUMENTS_FOLDER.stringByAppendingPathComponent("login.sqlite")

    enum TabView : Int {
        case Inbox = 0
        case Sent
        case Me
    }
    static let majorName = ["cs": "计算机"]
    static let titleName = ["b":"班长", "t": "团支书"]
}