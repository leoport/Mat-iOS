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

        rightBarButtonItem.title = rightBarButtonTitles[Int(displayAllItems)]
        smartLoadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        autoJumpToLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
                        items = currentUser.inboxItems
                    } else {
                        items = currentUser.undoneInboxItems
                    }
                    tableView.reloadData()
                }
            }
        }
        autoJumpToLogin()
    }
    @IBAction func onRightBarButtonClicked(sender: UIBarButtonItem) {
        displayAllItems = !displayAllItems
        rightBarButtonItem.title = rightBarButtonTitles[Int(displayAllItems)]
        let currentUser = UserManager.currentUser!
        if displayAllItems {
            items = currentUser.inboxItems
        } else {
            items = currentUser.undoneInboxItems
        }
        tableView.reloadData()
    }

    func autoJumpToLogin() {
        let user = UserManager.currentUser
        if user == nil || !user!.isLogedIn() {
            tabBarController!.selectedIndex = Configure.TabView.Me.rawValue
        }
    }

    func onRefresh(refreshControl: UIRefreshControl) {
        let user = UserManager.currentUser!
        MatServer.sync(user, completionHandler: handleRefreshResult)
    }

    func handleRefreshResult(result : MatError?) {
        if result == nil {
            smartLoadData()
        } else if result! == MatError.AuthFailed {
            view.makeToast(message: "验证用户失败")
        } else if result! == MatError.NetworkDataError {
            view.makeToast(message: "网络数据错误")
        }
        refreshControl!.endRefreshing()
        autoJumpToLogin()
    }
}

