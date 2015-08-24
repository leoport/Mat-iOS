//
//  HttpTask.swift
//  Mat
//
//  Created by 君君 on 15/8/14.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

protocol HttpTask {
    var user : User { get set}
    func postExcute(response : NSString) -> Void
}

extension HttpTask {
    func completionHandler(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void {
        /*
        let httpResponse = response as! NSHTTPURLResponse
        var headers = httpResponse.allHeaderFields;
        if let cookiesHeader = headers["Set-Cookie"] {
            let cookies = cookiesHeader as! String
            for item in cookies.componentsSeparatedByString(" ") {
                let keyValue = item.componentsSeparatedByString("=")
                if (keyValue[0] == "COOKIEID") {
                    print("COOKIE ID:" + keyValue[1] + "\n")
                    //user.cookieId = keyValue[1]
                } else if (keyValue[0] == "PHPSESSID") {
                    //user.sessionId = keyValue[1].stringByReplacingOccurrencesOfString(";", withString: "")
                }
            }
        } */
        var content : NSString
        if (data == nil) {
            content = NSString(string: "")
        } else {
            content = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        }
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                if cookie.name == "COOKIEID" {
                    print("cookie.value=" + cookie.value)
                    user.cookieId = cookie.value
                } else if cookie.name == "PHPSESSID" {
                    user.sessionId = cookie.value
                }
            }
        }
        if content.hasPrefix("Error/Login") {
            user.cookieId = ""
        }
        dispatch_async(dispatch_get_main_queue(), { self.postExcute(content) })
    }

    mutating func get(url : String) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("en-us", forHTTPHeaderField: "Content-Language")
        setCookies()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }

    mutating func post(url : String, params : Dictionary<String, String>) {
        var content = ""
        for (key, value) in params {
            if !content.isEmpty {
                content += "&"
            }
            content = content + key + "=" + value
        }
        //let params = "username=" + username + "&password=" + password;
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