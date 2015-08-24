//
//  InboxItem.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class InboxItem {
    var msgId : Int
    var srcId : Int
    var srcTitle : String
    var type : MessageType
    var status : MessageStatus
    var timestamp : DateTime
    var startTime : DateTime
    var endTime : DateTime
    var place : String
    var text : String

    required init() {
        msgId = 0
        srcId = 0
        srcTitle = ""
        type = MessageType.Text
        status = MessageStatus.Init
        timestamp = DateTime()
        startTime = DateTime()
        endTime = DateTime()
        place = ""
        text = ""
    }
}