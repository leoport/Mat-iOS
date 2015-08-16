//
//  ConfirmItem.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class ConfirmItem {
    private var mId : Int
    private var mMsgId : Int
    private var mDstId : Int
    private var mDstTitle : String
    private var mStatus : MessageStatus
    private var mTimestamp : DateTime

    required init() {
        mId = 0
        mMsgId = 0
        mDstId = 0
        mDstTitle = ""
        mStatus = MessageStatus.Init
        mTimestamp = DateTime()
    }

    func getId() -> Int {
        return mId
    }
    func setId(id: Int) {
        mId = id
    }

    func getMsgId() -> Int {
        return mMsgId
    }
    func setMsgId(msgId : Int) {
        mMsgId = msgId
    }

    func getDstId() -> Int {
        return mDstId
    }
    func setDstId(dstId : Int) {
        mDstId = dstId
    }

    func getDstTitle() -> String {
        return mDstTitle
    }
    func setDstTitle(dstTitle : String) {
        mDstTitle = dstTitle
    }

    func getStatus() -> MessageStatus {
        return mStatus
    }
    func setStatus(status : MessageStatus) {
        mStatus = status
    }

    func getTimestamp() -> DateTime {
        return mTimestamp
    }
    func setTimestamp(timestamp : DateTime) {
        mTimestamp = timestamp
    }
}