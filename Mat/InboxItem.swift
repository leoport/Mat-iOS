//
//  InboxItem.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class InboxItem {
    private var mMsgId : Int
    private var mSrcId : Int
    private var mSrcTitle : String
    private var mType : MessageType
    private var mStatus : MessageStatus
    private var mTimestamp : DateTime
    private var mStartTime : DateTime
    private var mEndTime : DateTime
    private var mPlace : String
    private var mText : String

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