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
        let httpResponse = response as! NSHTTPURLResponse
        var headers = httpResponse.allHeaderFields;
        if let cookiesHeader = headers["Set-Cookie"] {
            let cookies = cookiesHeader as! String
            for item in cookies.componentsSeparatedByString(" ") {
                let keyValue = item.componentsSeparatedByString("=")
                if (keyValue[0] == "COOKIEID") {
                    user.sessionId = keyValue[1]
                    user.cookieId = keyValue[1]
                }
            }
        } else {
            user.cookieId = ""
        }
        var content : NSString
        if (data == nil) {
            content = NSString(string: "")
        } else {
            content = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        }
        postExcute(content)
    }

    mutating func get(url : String) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("en-us", forHTTPHeaderField: "Content-Language")
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
        let dataTask = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }
}