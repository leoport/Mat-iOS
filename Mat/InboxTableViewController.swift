//
//  MasterViewController.swift
//  Mat
//
//  Created by 君君 on 15/7/30.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class InboxTableViewController: UITableViewController {
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!

    var items = [InboxItem]()
    var viewUser : User?
    var viewTimestamp : DateTime?
    var itemViewController: InboxItemViewController? = nil
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

    /*
    func insertNewObject(sender: AnyObject) {
        //objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    } */

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let item = items[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = item
                //if #available(iOS 8.0, *) {
                //    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                //} else {
                //    // Fallback on earlier versions
                //}
                //controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } */
        if segue.identifier == "ShowDetail" {
            let itemViewController = segue.destinationViewController as! InboxItemViewController
            if let selectedCell = sender as? InboxTableViewCell {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxCell", forIndexPath: indexPath) as! InboxTableViewCell

        let item = items[indexPath.row]
        //cell.textLabel!.text = item.mSrcTitle + " " + item.mText
        cell.mainLabel.text = item.text
        cell.leftHintLabel.text = item.srcTitle
        if item.status == MessageStatus.Init {
            cell.icon.image = UIImage(named: "Unread")
            cell.rightHintLabel.textColor = UIColor.redColor()
            cell.rightHintLabel.text = "未确认"
        } else if item.type == MessageType.Text {
            cell.icon.image = UIImage(named: "Alert")
            cell.rightHintLabel.text = ""
        } else if item.type == MessageType.Event {
            cell.icon.image = UIImage(named: "Calendar")
            cell.rightHintLabel.text = item.startTime.simpleString + "开始"
            cell.rightHintLabel.textColor = UIColor.blackColor()
        } else if item.type == MessageType.Task {
            cell.icon.image = UIImage(named: "Task")
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
                        items = currentUser.getInboxItems()
                    } else {
                        items = currentUser.getUndoneInboxItems()
                    }
                    tableView.reloadData()
                }
            } else {
                //tabBarController!.selectedIndex = Configure.TabView.Me.rawValue
                jumpToLogin()
            }
        } else {
            //performSegueWithIdentifier("logout", sender: nil)
            //tabBarController!.selectedIndex = Configure.TabView.Me.rawValue
            jumpToLogin()
        }
    }
    @IBAction func onRightBarButtonClicked(sender: UIBarButtonItem) {
        displayAllItems = !displayAllItems
        rightBarButtonItem.title = rightBarButtonTitles[Int(displayAllItems)]
        let currentUser = UserManager.currentUser!
        if displayAllItems {
            items = currentUser.getInboxItems()
        } else {
            items = currentUser.getUndoneInboxItems()
        }
        tableView.reloadData()
    }

    func jumpToLogin() {
        UserManager.logoutCurrentUser()
        tabBarController!.selectedIndex = Configure.TabView.Me.rawValue
    }

    func onRefresh(refreshControl: UIRefreshControl) {
        /*
        syncMsgTask = SyncMessageTask(controller: self)
        let user = UserManager.currentUser!
        let url = String(format: Configure.MSG_FETCH_URL, user.dataTimestamp.digitString)
        syncMsgTask!.get(url) */

        let user = UserManager.currentUser!
        MatServer.sync(user, completionHandler: handleRefreshResult)
    }

    func handleRefreshResult(result : MatError?) {
        if result == nil {
            smartLoadData()
        } else if result! == MatError.AuthFailed {
            view.makeToast(message: "验证用户失败")
            jumpToLogin()
        } else if result! == MatError.NetworkDataError {
            view.makeToast(message: "网络数据错误")
        }
        refreshControl!.endRefreshing()
    }
    /*
        func postExcute(response: NSString) {
            if user.isLogedIn() {
                do {
                    try user.sync(response as String)
                    //controller.items = UserManager.currentUser!.getUndoneInboxItems()
                    //controller.tableView.reloadData()
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
    } */
}

