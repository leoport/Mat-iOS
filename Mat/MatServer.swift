//
//  MatServer.swift
//  Mat
//
//  Created by 君君 on 15/8/28.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class MatServer {
    typealias CompletionHanlder = (MatError?) -> Void

    static private var user : User!
    static private var authCompletionHandler : CompletionHanlder!
    static private var syncCompletionHandler : CompletionHanlder!
    static private var httpTask = HttpTask()

    static func auth(user: User, password: String, completionHandler: (MatError?) -> Void) {
        self.user = user
        self.authCompletionHandler = completionHandler

        let url = String(format: Configure.LOGIN_URL, user.dataTimestamp.digitString)
        let dict = ["username": String(user.userId), "password": password]
        httpTask.post(user, url: url, params: dict, responseHandler: handleAuthResponse)
    }

    static func sync(user: User, completionHandler: (MatError?) -> Void) {
        self.user = user
        self.syncCompletionHandler = completionHandler

        let url = String(format: Configure.MSG_FETCH_URL, user.dataTimestamp.digitString)
        httpTask.get(user, url: url, responseHandler: handleSyncResponse)
    }

    static func setInboxItemStatus(user: User, item: InboxItem, status: MessageStatus, completionHandler: (MatError?) -> Void) {
        self.user = user
        self.syncCompletionHandler = completionHandler
    
        let url = String(format: Configure.MSG_CONFIRM_URL, item.srcId, item.msgId, status.rawValue, user.dataTimestamp.digitString)
        httpTask.get(user, url: url, responseHandler: handleSyncResponse)
    }

    static func sendMessage(user: User, dst: String, type: MessageType, startTime: DateTime, endTime: DateTime, place: String, text: String, completionHanlder: (MatError?) -> Void ) {
        self.user = user
        self.syncCompletionHandler = completionHanlder
        
        let params: Dictionary<String, String> = [
            "since": user.dataTimestamp.digitString,
            "dst": dst,
            "type": String(type.rawValue),
            "start_time": startTime.completeString,
            "end_time": endTime.completeString,
            "place": place,
            "text": text]
        httpTask.post(user, url: Configure.MSG_POST_URL, params: params, responseHandler: handleSyncResponse)
    }

    static func handleAuthResponse(content: String) {
        let user = MatServer.user
        var res : MatError?
        if user.isLogedIn() {
            res = nil
        } else {
            res = MatError.AuthFailed
        }
        authCompletionHandler(res)
    }

    static func handleSyncResponse(content: String) {
        let user = MatServer.user
        var res : MatError?

        if user.isLogedIn() {
            do {
                try user.sync(content)
                res = nil
            } catch {
                res = MatError.NetworkDataError
            }
        } else {
            res = MatError.AuthFailed
        }
        syncCompletionHandler(res)
    }
}