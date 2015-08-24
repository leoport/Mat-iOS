//
//  ConfirmItem.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class ConfirmItem {
    var id : Int = -1
    var msgId : Int = -1
    var dstId : Int = -1
    var dstTitle : String = ""
    var status : MessageStatus = MessageStatus.Init
    var timestamp : DateTime = DateTime()
}