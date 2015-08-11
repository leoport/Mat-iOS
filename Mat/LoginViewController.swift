//
//  LoginViewController.swift
//  Mat
//
//  Created by 君君 on 15/8/10.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onLogin(sender: UIButton) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        usernameTextField.enabled = false
        passwordTextField.enabled = false
        loginButton.enabled = false
        login(username, password: password)
        
    }
    func login(username: String, password: String) {
        func handleCompletion(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void {
            //let newStr = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
            let httpResponse = response as! NSHTTPURLResponse
            var headers = httpResponse.allHeaderFields;
            let cookies = headers["Set-Cookie"] as! String
            for item in cookies.componentsSeparatedByString(" ") {
                let keyValue = item.componentsSeparatedByString("=")
                if (keyValue[0] == "COOKIEID") {
                    let user = User(userId: Int(username)!)
                    user.sessionId = keyValue[1]
                    user.cookieId = keyValue[1]
                    UserManager.Instance.currentUser = user
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        let params = "username=" + username + "&password=" + password;
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: Configure.loginURL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("en-us", forHTTPHeaderField: "Content-Language")
        request.addValue(String(request.HTTPBody!.length), forHTTPHeaderField: "Content-Length")
        let dataTask = session.dataTaskWithRequest(request, completionHandler: handleCompletion)
        dataTask.resume()
    }
}
