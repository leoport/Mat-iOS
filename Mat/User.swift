//
//  User.swift
//  Mat
//
//  Created by 君君 on 15/8/11.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class User : Equatable {
    var userId: Int
    var sessionId: String
    var cookieId: String
    var database: FMDatabase
    var dataTimestamp : DateTime
    var httpTask : HttpTask
    var inboxItems : [InboxItem] {
        get {
            if inboxItemsCache == nil {
                inboxItemsCache = getInboxItemsPrime("ORDER BY status ASC, inbox.timestamp DESC;")
            }
            return inboxItemsCache!
        }
    }
    var undoneInboxItems : [InboxItem] {
        get {
            if undoneInboxItemsCache == nil {
                undoneInboxItemsCache = getInboxItemsPrime("WHERE status < 2 ORDER BY status, type, end_time, timestamp DESC;")
            }
            return undoneInboxItemsCache!
        }
    }
    var sentItems : [SentItem] {
        get {
            if sentItemsCache == nil {
                sentItemsCache = getSentItemsPrime("ORDER BY timestamp DESC")
            }
            return sentItemsCache!
        }
    }
    var undoneSentItems : [SentItem] {
        get {
            if undoneSentItemsCache == nil {
                undoneSentItemsCache = getSentItemsPrime("WHERE status = 0 ORDER BY timestamp DESC;")
            }
            return undoneSentItemsCache!
        }
    }
    private var inboxItemsCache : [InboxItem]?
    private var undoneInboxItemsCache : [InboxItem]?
    private var sentItemsCache : [SentItem]?
    private var undoneSentItemsCache : [SentItem]?


    required init(userId: Int) {
        self.userId = userId
        sessionId = ""
        cookieId = ""
        let databasePath = Configure.DOCUMENTS_FOLDER.stringByAppendingPathComponent(String(userId) + ".sqlite")
        database = FMDatabase(path: databasePath)
        if !database.open() {
            print("User:init failed to open database")
        }
        dataTimestamp = DateTime(timeIntervalSince1970: 0)
        httpTask = HttpTask()
        initDatabase()
        initTimestamp()
    }
    deinit {
        if !database.close() {
            print("failed to close database")
        }
    }

    func initDatabase() {
        // create table contact
        let query = "CREATE TABLE IF NOT EXISTS contact (`id` integer PRIMARY KEY, name varchar(255), name_char varchar(10), type char, unit varchar(10), title varchar(10), `f` integer, `b` integer, `t` integer, timestamp timestamp);"
        database.executeUpdate(query)
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_contact_timestamp ON contact (timestamp);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_contact_unit ON contact (unit);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_contact_name_char ON contact (name_char);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_contact_f ON contact (f);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_contact_b ON contact (b);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_contact_t ON contact (t);")
        // create table inbox
        database.executeUpdate("CREATE TABLE IF NOT EXISTS `inbox` (`msg_id` integer PRIMARY KEY, `src_id` integer, `src_title` varchar(40), param integer, `type` integer, `start_time` datetime, `end_time` datetime, place varchar(160), `text` varchar(2048), `status` integer, `timestamp` timestamp);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_inbox_timestamp ON inbox (`timestamp`);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_inbox_status ON inbox(`status`);")
        // create table sent
        database.executeUpdate("CREATE TABLE IF NOT EXISTS sent (`msg_id` integer PRIMARY KEY, `dst_str` varchar(300), `dst_title` varchar(300), parsm integer, `type` integer, `start_time` datetime, `end_time` datetime, place varchar(160), `text` varchar(2048), `status` integer, `timestamp` timestamp);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_sent_timestamp ON sent (`timestamp`);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_sent_status ON sent (`status`);")
        // create table confirm
        database.executeUpdate("CREATE TABLE IF NOT EXISTS `confirm` (confirm_id integer PRIMARY KEY, `msg_id` integer, dst_id integer, dst_title varchar(40), `status` integer, timestamp timestamp);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_confirm_timestamp ON confirm(`timestamp`);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_confirm_msg ON confirm(`msg_id`);")
        // create table update_record
        database.executeUpdate("CREATE TABLE IF NOT EXISTS `sync_record`(`id` integer PRIMARY KEY, timestamp timestamp, length integer, updated integer)")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_sync_record_timestamp ON sync_record(`timestamp`);")
        database.executeUpdate("CREATE INDEX IF NOT EXISTS idx_sync_record_updated ON sync_record(`updated`);")
    }
    func isLogedIn() -> Bool {
        return !cookieId.isEmpty
    }
    func sync(data : String) throws {
        var isDataUpdated = false
        do {
            let jsonObj = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            let contactsJSON = jsonObj["contact"] as! Array<Dictionary<String, String>>
            if !contactsJSON.isEmpty {
                isDataUpdated = true
                syncContacts(contactsJSON)
            }

            let inboxJSON = jsonObj["inbox"] as! Array<Dictionary<String, String>>
            if !inboxJSON.isEmpty {
                isDataUpdated = true
                syncIndox(inboxJSON)
                inboxItemsCache = nil
                undoneInboxItemsCache = nil
            }

            let sentJSON = jsonObj["sent"] as! Array<Dictionary<String, String>>
            if !sentJSON.isEmpty {
                isDataUpdated = true
                syncSent(sentJSON)
                sentItemsCache = nil
                undoneSentItemsCache = nil
            }
            
            let confirmJSON = jsonObj["confirm"] as! Array<Dictionary<String, String>>
            if !confirmJSON.isEmpty {
                isDataUpdated = true
                syncConfirm(confirmJSON)
            }
            let timestamp = jsonObj["timestamp"] as! String
            dataTimestamp = DateTime(datetimeString : timestamp)
            addUpdateRecord(timestamp, length: data.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), isDataUpdated: isDataUpdated)
            print("Current Timestamp: \(dataTimestamp.completeString) Updated: \(isDataUpdated)")
        } catch {
            throw MatError.NetworkDataError
        }
    }
    private func syncContacts(json : Array<Dictionary<String, String>>) {
        for item in json {
            let sql = String(format: "INSERT OR REPLACE INTO contact VALUES('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');",
                item["id"]!,
                item["name"]!,
                item["name_char"]!,
                item["type"]!,
                item["unit"]!,
                item["title"]!,
                item["f"]!,
                item["b"]!,
                item["t"]!,
                item["timestamp"]!);
            print(sql)
            if !database.executeUpdate(sql) {
                print("failed to update contact")
            }
        }
    }
    private func syncIndox(json: Array<Dictionary<String, String>>) {
        for item in json {
            let query = String(format : "INSERT OR REPLACE INTO `inbox` VALUES('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');",
                item["msg_id"]!,
                item["src_id"]!,
                getContactTitle(Int(item["src_id"]!)!),
                item["param"]!,
                item["type"]!,
                item["start_time"]!, //DatabaseUtils.sqlEscapeString(item["start_time"]),
                item["end_time"]!, //DatabaseUtils.sqlEscapeString(item["end_time"]),
                item["place"]!, //DatabaseUtils.sqlEscapeString(item["place"]),
                item["text"]!, //DatabaseUtils.sqlEscapeString(item["text"]),
                item["status"]!,
                item["timestamp"]!);
            database.executeUpdate(query)
        }
    }
    private func syncSent(json: Array<Dictionary<String, String>>) {
        for item in json {
            let query = String(format: "INSERT OR REPLACE INTO sent VALUES('%@', '%@', '%@', '%@', %@, '%@', '%@', '%@', '%@', '%@', '%@');",
                item["msg_id"]!,
                item["dst_str"]!,
                getGroupsTitle(item["dst_str"]!),
                item["param"]!,
                item["type"]!,
                item["start_time"]!,
                item["end_time"]!,
                item["place"]!,
                item["text"]!,
                item["status"]!,
                item["timestamp"]!
            )
            print(query)
            if !database.executeUpdate(query) {
                print("failed to update sent")
            }
        }
    }
    private func syncConfirm(json: Array<Dictionary<String, String>>) {
        for item in json {
            let query = String(format: "INSERT OR REPLACE INTO `confirm` VALUES('%@', '%@', '%@', '%@', '%@', '%@');",
                item["confirm_id"]!,
                item["msg_id"]!,
                item["dst_id"]!,
                getContactTitle(Int(item["dst_id"]!)!),
                item["status"]!,
                item["timestamp"]!);
            print(query)
            if !database.executeUpdate(query) {
                print("failed to update confirm")
            }
        }
    }

    func getContactTitle(id : Int) -> String {
        let sql = "SELECT name, type FROM contact WHERE id=" + String(id) + ";"
        var title = ""
        if let res = database.executeQuery(sql, withArgumentsInArray: nil) {
            if res.next() {
                let name = res.stringForColumn("name")
                let type = res.stringForColumn("type")
                if (type == "T") {
                    title = name + "老师"
                } else {
                    title = name + "同学"
                }
            }
        }
        return title
    }
    func initTimestamp() {
        let sql = "SELECT timestamp FROM sync_record WHERE updated=1 ORDER BY timestamp DESC LIMIT 1;";
        if let res = database.executeQuery(sql) {
            if res.next() {
                dataTimestamp = DateTime(datetimeString: res.stringForColumnIndex(0))
                print("User:initTimestamp: load last update timestamp" + dataTimestamp.completeString)
            }
        }
    }
    func addUpdateRecord(timestamp : String, length : Int, isDataUpdated : Bool) {
        let sql = String(format : "INSERT INTO sync_record VALUES(NULL, '%@', '%d', '%d');", timestamp, length, isDataUpdated ? 1 : 0);
        database.executeUpdate(sql)
    }
    private func getInboxItemsPrime(suffix : String) -> [InboxItem] {
        var items = [InboxItem]()
        let sql = "SELECT msg_id, src_id, src_title, type, start_time, end_time, place, text, status, timestamp FROM inbox " + suffix;
        if let res = database.executeQuery(sql) {
            while res.next() {
                let item = InboxItem();
                item.msgId = Int(res.intForColumnIndex(0))
                item.srcId = Int(res.intForColumnIndex(1))
                item.srcTitle = res.stringForColumnIndex(2)
                item.type = MessageType(rawValue: Int(res.intForColumnIndex(3)))!
                item.startTime = DateTime(datetimeString : res.stringForColumnIndex(4))
                item.endTime = DateTime(datetimeString : res.stringForColumnIndex(5))
                item.place = res.stringForColumnIndex(6)
                item.text = res.stringForColumnIndex(7)
                item.status = MessageStatus(rawValue: Int(res.intForColumnIndex(8)))!
                item.timestamp = DateTime(datetimeString: res.stringForColumnIndex(9))
                items.append(item)
            }
        }
        return items
    }
    private func getSentItemsPrime(suffix : String) -> [SentItem] {
        var items = [SentItem]()
        let sql = "SELECT msg_id, dst_title, type, start_time, end_time, place, text, status, timestamp FROM sent " + suffix;
        if let res = database.executeQuery(sql) {
            while res.next() {
                let item = SentItem()
                item.msgId = Int(res.intForColumnIndex(0))
                item.dstTitle = res.stringForColumnIndex(1)
                item.type = MessageType(rawValue: Int(res.intForColumnIndex(2)))!
                item.startTime = DateTime(datetimeString : res.stringForColumnIndex(3))
                item.endTime = DateTime(datetimeString : res.stringForColumnIndex(4))
                item.place = res.stringForColumnIndex(5)
                item.text = res.stringForColumnIndex(6)
                item.status = MessageStatus(rawValue: Int(res.intForColumnIndex(7)))!
                item.timestamp = DateTime(datetimeString: res.stringForColumnIndex(8))
                item.progress = getSentItemProgress(item.msgId)
                items.append(item)
            }
        }
        return items
    }

    func getConfirmItems(msgId: Int) -> [ConfirmItem] {
        var items = [ConfirmItem]()
        let sql = "SELECT confirm_id, dst_id, dst_title, status, timestamp FROM confirm WHERE msg_id=\(msgId) ORDER BY timestamp ASC;";
        if let res = database.executeQuery(sql) {
            while res.next() {
                let item = ConfirmItem()
                item.id = Int(res.intForColumnIndex(0))
                item.msgId = msgId
                item.dstId = Int(res.intForColumnIndex(1))
                item.dstTitle = res.stringForColumnIndex(2)
                item.status = MessageStatus(rawValue: Int(res.intForColumnIndex(3)))!
                item.timestamp = DateTime(datetimeString: res.stringForColumnIndex(4))
                items.append(item)
            }
        }
        return items
    }

    func getSentItemProgress(msgId: Int) -> String {
        let sql = "SELECT status, COUNT(*) FROM confirm WHERE msg_id=\(msgId) GROUP BY status;";
        var all = 0
        var confirmed = 0
        if let res = database.executeQuery(sql) {
            while res.next() {
                let n = Int(res.intForColumnIndex(1))
                if (res.intForColumnIndex(0) > 0) {
                    confirmed += n
                }
                all += n
            }
        }
        return "\(confirmed)/\(all)"
    }

    func getGroupsTitle(groups : String) -> String {
        var res = String()
        let groupArray = groups.componentsSeparatedByString(";")
    
        for group in groupArray {
            if group.isEmpty {
                continue
            }
            if (group.rangeOfString(".") == nil) {
                res += getContactTitle(Int(group)!);
            } else {
                res += getUnitTitle(group)
            }
            res += ";"
        }
        return res
    }
    
    func getUnitTitle(expr : String) -> String {
        let exprArray = expr.componentsSeparatedByString("\\.");
        let title = exprArray[0] as NSString
        let unit  = exprArray[1] as NSString
        let major = unit.substringToIndex(2)
        var res = String()
        if major != "__" {
            res += Configure.majorName[major]!
        }
        let grade = unit.substringWithRange(NSMakeRange(2, 2))
        if grade != "__" {
            res += grade + "级"
        }
        let className = unit.substringWithRange(NSMakeRange(5, 1))
        if className != "_" {
            res += className + "班";
        }
        if title.length == 0 {
            res += "全体同学"
        } else {
            var firstItem = true
            for i in 0 ..< title.length {
                if firstItem {
                    firstItem = false
                } else {
                    res += ","
                }
                let titleBrief = title.substringWithRange(NSMakeRange(i, 1))
                res += Configure.titleName[titleBrief]!
            }
        }
        return res
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.userId == rhs.userId
}