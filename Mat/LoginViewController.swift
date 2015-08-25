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
    }
    func initUserData() {
        var initUserDataTask = InitUserDataTask(controller : self)
        let url = String(format: Configure.MSG_FETCH_URL, user!.dataTimestamp.digitString)
        initUserDataTask.get(url)
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
                UserManager.currentUser = controller.user
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
            if user.isLogedIn() {
                do {
                    try user.sync(response as String)
                } catch {
                    controller.view.makeToast(message: "网络数据错误")
                    controller.usernameTextField.enabled = true
                    controller.passwordTextField.enabled = true
                    controller.loginButton.enabled = true
                }
                /*
                if let tableViewController = controller.navigationController?.viewControllers[0] as? InboxTableViewController {
                    tableViewController.items = user.getUndoneInboxItems()
                    tableViewController.tableView.reloadData()
                } */
                controller.dismissViewControllerAnimated(true, completion: nil)
            } else {
                controller.view.makeToast(message: "验证用户失败")
                controller.usernameTextField.enabled = true
                controller.passwordTextField.enabled = true
                controller.loginButton.enabled = true
            }
        }
    }
}
