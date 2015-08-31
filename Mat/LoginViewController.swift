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
        
        MatServer.auth(user!, password: password, completionHandler: handleAuthResponse)
    }

    func handleAuthResponse(error: MatError?) {
        UserManager.currentUser = user

        if error == nil {
            MatServer.sync(user!, completionHandler: handleSyncResult)
        } else {
            usernameTextField.enabled = true
            passwordTextField.enabled = true
            loginButton.enabled = true
        }
    }

    func handleSyncResult(error: MatError?) {
        if error == nil {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            usernameTextField.enabled = true
            passwordTextField.enabled = true
            loginButton.enabled = true
            if error! == MatError.NetworkDataError {
                view.makeToast(message: "网络数据错误")
            } else {
                view.makeToast(message: "验证用户失败")
            }
        }
    }
}
