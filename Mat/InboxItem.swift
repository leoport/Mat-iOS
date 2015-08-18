//
//  InboxItem.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class InboxItem {
    var mMsgId : Int
    var mSrcId : Int
    var mSrcTitle : String
    var mType : MessageType
    var mStatus : MessageStatus
    var mTimestamp : DateTime
    var mStartTime : DateTime
    var mEndTime : DateTime
    var mPlace : String
    var mText : String

    required init() {
        mMsgId = 0
        mSrcId = 0
        mSrcTitle = ""
        mType = MessageType.Text
        mStatus = MessageStatus.Init
        mTimestamp = DateTime()
        mStartTime = DateTime()
        mEndTime = DateTime()
        mPlace = ""
        mText = ""
    }
}