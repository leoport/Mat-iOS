//
//  MasterViewController.swift
//  Mat
//
//  Created by 君君 on 15/7/30.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    @IBOutlet weak var logoutBarButton: UIBarButtonItem!

    var detailViewController: DetailViewController? = nil
    var items = [InboxItem]()
    var msgTask : MessageTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()

        /*
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
*/
    }

    override func viewWillAppear(animated: Bool) {
        /*
        if #available(iOS 8.0, *) {
            self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        } else {
            // Fallback on earlier versions
        } */
        super.viewWillAppear(animated)
        if let user = UserManager.getInstance().getCurrentUser() {
            items = user.getUndoneInboxItems()
        } else {
            performSegueWithIdentifier("logout", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        //objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

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
            let detailController = segue.destinationViewController as! DetailViewController
            if let selectedCell = sender as? MasterTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                let selectedItem = items[indexPath.row]
                detailController.detailItem = selectedItem
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MasterTableViewCell

        let item = items[indexPath.row]
        //cell.textLabel!.text = item.mSrcTitle + " " + item.mText
        cell.mainLabel.text = item.mText
        cell.leftHintLabel.text = item.mSrcTitle
        if item.mStatus == MessageStatus.Init {
            cell.icon.image = UIImage(named: "Unread")
            cell.rightHintLabel.textColor = UIColor.redColor()
            cell.rightHintLabel.text = "未确认"
        } else if item.mType == MessageType.Text {
            cell.icon.image = UIImage(named: "Alert")
            cell.rightHintLabel.text = ""
        } else if item.mType == MessageType.Event {
            cell.icon.image = UIImage(named: "Calendar")
            cell.rightHintLabel.text = item.mStartTime.toSimpleString() + "开始"
            cell.rightHintLabel.textColor = UIColor.blackColor()
        } else if item.mType == MessageType.Task {
            cell.icon.image = UIImage(named: "Task")
            cell.rightHintLabel.text = "截至" + item.mEndTime.toSimpleString()
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
    func onRefresh(refreshControl: UIRefreshControl) {
        /*
        let user = UserManager.getInstance().getCurrentUser()
        items = UserManager.getInstance().getCurrentUser()!.getUndoneInboxItems()
        
        self.tableView.reloadData()
        refreshControl.endRefreshing() */
        msgTask = MessageTask(controller: self)
        let user = UserManager.getInstance().getCurrentUser()
        let url = String(format: Configure.MSG_FETCH_URL, user!.lastUpdateTimestamp.toDigitString())
        msgTask!.get(url)
    }
    class MessageTask : HttpTask {
        var user : User
        var controller : MasterViewController
        required init(controller : MasterViewController) {
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

