//
//  DetailViewController.swift
//  Mat
//
//  Created by 君君 on 15/7/30.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class InboxItemViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var confirmBarButton: UIBarButtonItem!
    @IBOutlet weak var ignoreBarButton: UIBarButtonItem!
    @IBOutlet weak var completeBarButton: UIBarButtonItem!
    var syncMessageTask : SyncMessageTask?


    var item: InboxItem? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let item = self.item {
            if let textView = self.contentTextView {
                textView.text = "发件人: " + item.srcTitle + "\n"
                    + "发件时间: " + item.timestamp.simpleString + "\n\n"
                    + "内容: " + item.text
                if item.type != MessageType.Text {
                    textView.text = textView.text + "\n\n"
                        + "开始时间: " + item.startTime.simpleString + "\n"
                        + "结束时间: " + item.endTime.simpleString
                }
            }
            if item.status != MessageStatus.Init {
                confirmBarButton.enabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    @IBAction func onConfirm(sender: UIBarButtonItem) {
        enableSyncButton(false)
        setMessageStatus(MessageStatus.Confirmed)
    }
    @IBAction func onIgnore(sender: UIBarButtonItem) {
        enableSyncButton(false)
        setMessageStatus(MessageStatus.Ignored)
    }
    @IBAction func onComplete(sender: UIBarButtonItem) {
        enableSyncButton(false)
        setMessageStatus(MessageStatus.Accomplished)
    }
    private func enableSyncButton (enabled : Bool) {
        confirmBarButton.enabled = enabled
        ignoreBarButton.enabled = enabled
        completeBarButton.enabled = enabled
    }
    private func setMessageStatus(newStatus : MessageStatus) {
        syncMessageTask = SyncMessageTask(controller: self)
        let user = UserManager.getInstance().getCurrentUser()!
        let url = String(format: Configure.MSG_CONFIRM_URL, item!.srcId, item!.msgId, newStatus.rawValue, user.dataTimestamp.digitString)
        syncMessageTask!.get(url)
    }

    class SyncMessageTask : HttpTask {
        var user : User
        var controller : InboxItemViewController
        required init(controller : InboxItemViewController) {
            self.controller = controller
            self.user = UserManager.getInstance().getCurrentUser()!
        }

        func postExcute(response: NSString) {
            if user.isLogedIn() {
                do {
                    try user.sync(response as String)
                    /*
                    if let tableViewController = controller.navigationController?.viewControllers[0] as? MainViewController {
                        tableViewController.items = user.getUndoneInboxItems()
                        tableViewController.tableView.reloadData()
                    } */
                    controller.navigationController!.popViewControllerAnimated(true)
                } catch {
                    controller.view.makeToast(message: "网络数据错误")
                    controller.enableSyncButton(true)
                }
            } else {
                controller.view.makeToast(message: "验证用户失败")
                controller.enableSyncButton(true)
            }
        }
    }
}

