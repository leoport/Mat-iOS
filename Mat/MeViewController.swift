//
//  MeViewController.swift
//  Mat
//
//  Created by 君君 on 15/8/25.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let user = UserManager.getInstance().getCurrentUser()
        if user == nil || !user!.isLogedIn() {
            performSegueWithIdentifier("Logout", sender: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onLogout(sender: UIButton) {
        let userManager = UserManager.getInstance()
        userManager.getCurrentUser()?.cookieId = ""
        userManager.setCurrentUser(nil)
    }

}
