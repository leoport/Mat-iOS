//
//  HttpTask.swift
//  Mat
//
//  Created by 君君 on 15/8/14.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class HttpTask {
    typealias ResponseHandler = (content: String) -> Void

    private var user : User!
    private var responseHandler : ResponseHandler!

    func completionHandler(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void {
        var content : String
        if (data == nil) {
            content = ""
        } else {
            content = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        }
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                if cookie.name == "COOKIEID" {
                    user.cookieId = cookie.value
                } else if cookie.name == "PHPSESSID" {
                    user.sessionId = cookie.value
                }
            }
        }
        if content.hasPrefix("Error/Login") {
            user.cookieId = ""
        }
        dispatch_async(dispatch_get_main_queue(), { self.responseHandler!(content: content) })
    }

    func get(user: User, url : String, responseHandler: ResponseHandler) {
        self.user = user
        self.responseHandler = responseHandler

        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("en-us", forHTTPHeaderField: "Content-Language")
        setCookies()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }

    func post(user: User, url: String, params: Dictionary<String, String>, responseHandler: ResponseHandler) {
        self.user = user
        self.responseHandler = responseHandler

        var content = ""
        for (key, value) in params {
            if !content.isEmpty {
                content += "&"
            }
            content = content + key + "=" + value
        }
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("en-us", forHTTPHeaderField: "Content-Language")
        request.addValue(String(request.HTTPBody!.length), forHTTPHeaderField: "Content-Length")
        setCookies()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }

    private func setCookies() {
        if user.isLogedIn() {
            let properties1 = [
                NSHTTPCookieDomain : "leopub.org",
                NSHTTPCookiePath : "/",
                NSHTTPCookieName : "COOKIEID",
                NSHTTPCookieValue : user.cookieId,
                NSHTTPCookieDiscard : "TRUE" ]
            let cookie1 = NSHTTPCookie(properties: properties1)
            let properties2 = [
                NSHTTPCookieDomain : "leopub.org",
                NSHTTPCookiePath : "/",
                NSHTTPCookieName : "USERNAME",
                NSHTTPCookieValue : String(user.userId)]
            let cookie2 = NSHTTPCookie(properties: properties2)
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie1!)
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie2!)
        }
    }
}