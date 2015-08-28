//
//  SentItem.swift
//  Mat
//
//  Created by 君君 on 15/8/26.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class SentItem {
    var msgId = -1;
    var dstTitle = ""
    var type = MessageType.Text
    var startTime = DateTime.Zero
    var endTime = DateTime.Zero
    var place = ""
    var text = ""
    var status = MessageStatus.Init
    var timestamp = DateTime.Zero
}