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
    var loginTask : LoginTask?
    var user : User?

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
        user = User(userId: Int(username)!)
        loginTask = LoginTask(controller: self)
        let dict = ["username": username, "password": password]
        loginTask?.post(Configure.LOGIN_URL, params: dict)
        /*
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
                    UserManager.getInstance().setCurrentUser(user)
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
            usernameTextField.enabled = true
            passwordTextField.enabled = true
            loginButton.enabled = true
        }
        let params = "username=" + username + "&password=" + password;
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: Configure.LOGIN_URL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("en-us", forHTTPHeaderField: "Content-Language")
        request.addValue(String(request.HTTPBody!.length), forHTTPHeaderField: "Content-Length")
        let dataTask = session.dataTaskWithRequest(request, completionHandler: handleCompletion)
        dataTask.resume() */
    }
    func initUserData() {
        var initUserDataTask = InitUserDataTask(controller : self)
        initUserDataTask.get(Configure.MSG_FETCH_URL)
    }

    class LoginTask : HttpTask {
        var user : User
        var controller : LoginViewController
        required init(controller : LoginViewController) {
            self.controller = controller
            self.user = controller.user!
        }

        func postExcute(response: NSString) {
            if controller.user!.isLogedIn() {
                UserManager.getInstance().setCurrentUser(controller.user)
                //controller.dismissViewControllerAnimated(true, completion: nil)
                controller.initUserData()
            } else {
                controller.usernameTextField.enabled = true
                controller.passwordTextField.enabled = true
                controller.loginButton.enabled = true
            }
        }
    }
    class InitUserDataTask : HttpTask {
        var user : User
        var controller : LoginViewController
        required init(controller : LoginViewController) {
            self.controller = controller
            self.user = controller.user!
        }
        func postExcute(response: NSString) {
            user.sync(response as String)
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
