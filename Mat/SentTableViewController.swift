//
//  SentTableViewController.swift
//  Mat
//
//  Created by 君君 on 15/8/26.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class SentTableViewController: UITableViewController {
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!

    var items = [SentItem]()
    var syncMsgTask : SyncMessageTask?
    var viewUser : User?
    var viewTimestamp : DateTime?
    var itemViewController: SentItemViewController? = nil
    var displayAllItems : Bool = false
    let rightBarButtonTitles = ["全部消息", "待办事项"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // add listener function for pull-refresh action
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        smartLoadData()
        rightBarButtonItem.title = rightBarButtonTitles[Int(displayAllItems)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSentItem" {
            let itemViewController = segue.destinationViewController as! SentItemViewController
            if let selectedCell = sender as? SentTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                let selectedItem = items[indexPath.row]
                itemViewController.item = selectedItem
            }
        }

    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentCell", forIndexPath: indexPath) as! SentTableViewCell

        let item = items[indexPath.row]
        //cell.textLabel!.text = item.mSrcTitle + " " + item.mText
        cell.mainLabel.text = item.text
        cell.leftHintLabel.text = item.dstTitle
        //if item.status == MessageStatus.Init {
        //    cell.iconImageView.image = UIImage(named: "Unread")
        //    cell.rightHintLabel.textColor = UIColor.redColor()
        //    cell.rightHintLabel.text = "未确认"
        //} else if item.type == MessageType.Text {
        if item.type == MessageType.Text {
            cell.iconImageView.image = UIImage(named: "Alert")
            cell.rightHintLabel.text = ""
        } else if item.type == MessageType.Event {
            cell.iconImageView.image = UIImage(named: "Calendar")
            cell.rightHintLabel.text = item.startTime.simpleString + "开始"
            cell.rightHintLabel.textColor = UIColor.blackColor()
        } else if item.type == MessageType.Task {
            cell.iconImageView.image = UIImage(named: "Task")
            cell.rightHintLabel.text = "截至" + item.endTime.simpleString
            cell.rightHintLabel.textColor = UIColor.blackColor()
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    } */

    func smartLoadData() {
        if let currentUser = UserManager.currentUser {
            if currentUser.isLogedIn() {
                if viewUser == nil || viewUser! != currentUser || viewTimestamp != currentUser.dataTimestamp {
                    viewUser = currentUser
                    viewTimestamp = currentUser.dataTimestamp
                    if displayAllItems {
                        items = currentUser.getSentItems()
                    } else {
                        items = currentUser.getSentItems()
                    }
                    tableView.reloadData()
                }
            } else {
                jumpToLogin()
            }
        } else {
            jumpToLogin()
        }
    }
    @IBAction func onRightBarButtonClicked(sender: UIBarButtonItem) {
        displayAllItems = !displayAllItems
        rightBarButtonItem.title = rightBarButtonTitles[Int(displayAllItems)]
        let currentUser = UserManager.currentUser!
        if displayAllItems {
            items = currentUser.getSentItems()
        } else {
            items = currentUser.getSentItems()
        }
        tableView.reloadData()
    }

    func jumpToLogin() {
        UserManager.logoutCurrentUser()
        tabBarController!.selectedIndex = Configure.TabView.Me.rawValue
    }

    func onRefresh(refreshControl: UIRefreshControl) {
        syncMsgTask = SyncMessageTask(controller: self)
        let user = UserManager.currentUser!
        let url = String(format: Configure.MSG_FETCH_URL, user.dataTimestamp.digitString)
        syncMsgTask!.get(url)
    }
    class SyncMessageTask : HttpTask {
        var user : User
        var controller : SentTableViewController
        required init(controller : SentTableViewController) {
            self.controller = controller
            self.user = UserManager.currentUser!
        }
        func postExcute(response: NSString) {
            if user.isLogedIn() {
                do {
                    try user.sync(response as String)
                    controller.smartLoadData()
                } catch {
                    controller.view.makeToast(message: "网络数据错误")
                }
            } else {
                controller.view.makeToast(message: "验证用户失败")
                //controller.performSegueWithIdentifier("logout", sender: nil)
                //tabBarController!.selectedIndex = Configure.TabView.Me.rawValue
                controller.jumpToLogin()
            }
            controller.refreshControl!.endRefreshing()
        }
    }
}
