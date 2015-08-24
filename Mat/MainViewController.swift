//
//  MasterViewController.swift
//  Mat
//
//  Created by 君君 on 15/7/30.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    @IBOutlet weak var logoutBarButton: UIBarButtonItem!

    var items = [InboxItem]()
    var syncMsgTask : SyncMessageTask?
    var viewUser : User?
    var viewTimestamp : DateTime?
    var itemViewController: InboxItemViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // add listener function for pull-refresh action
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        smartLoadData()
        if !viewUser!.isLogedIn() {
        }
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
            if let selectedCell = sender as? MainTableViewCell {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MainTableViewCell

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
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    @IBAction func onLogout(sender: UIBarButtonItem) {
        UserManager.getInstance().setCurrentUser(nil)
    }
    func smartLoadData() {
        if let currentUser = UserManager.getInstance().getCurrentUser() {
            if viewUser == nil || viewUser! != currentUser || viewTimestamp != currentUser.dataTimestamp {
                viewUser = currentUser
                viewTimestamp = currentUser.dataTimestamp
                items = currentUser.getUndoneInboxItems()
                tableView.reloadData()
            }
        } else {
            performSegueWithIdentifier("logout", sender: nil)
        }
    }

    func onRefresh(refreshControl: UIRefreshControl) {
        syncMsgTask = SyncMessageTask(controller: self)
        let user = UserManager.getInstance().getCurrentUser()
        let url = String(format: Configure.MSG_FETCH_URL, user!.dataTimestamp.digitString)
        syncMsgTask!.get(url)
    }
    class SyncMessageTask : HttpTask {
        var user : User
        var controller : MainViewController
        required init(controller : MainViewController) {
            self.controller = controller
            self.user = UserManager.getInstance().getCurrentUser()!
        }
        func postExcute(response: NSString) {
            if user.isLogedIn() {
                do {
                    try user.sync(response as String)
                    controller.items = UserManager.getInstance().getCurrentUser()!.getUndoneInboxItems()
                    controller.tableView.reloadData()
                } catch {
                    controller.view.makeToast(message: "网络数据错误")
                }
            } else {
                controller.view.makeToast(message: "验证用户失败")
                controller.performSegueWithIdentifier("logout", sender: nil)
            }
            controller.refreshControl!.endRefreshing()
        }
    }
}

