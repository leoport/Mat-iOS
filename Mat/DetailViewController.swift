//
//  DetailViewController.swift
//  Mat
//
//  Created by 君君 on 15/7/30.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var confirmBarButton: UIBarButtonItem!
    @IBOutlet weak var ignoreBarButton: UIBarButtonItem!
    @IBOutlet weak var completeBarButton: UIBarButtonItem!
    var msgTask : MsgTask?


    var detailItem: InboxItem? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let textView = self.detailTextView {
                textView.text = "发件人: " + detail.mSrcTitle + "\n"
                    + "发件时间: " + detail.mTimestamp.toSimpleString() + "\n\n"
                    + "内容: " + detail.mText
                if detail.mType != MessageType.Text {
                    textView.text = textView.text + "\n\n"
                        + "开始时间: " + detail.mStartTime.toSimpleString() + "\n"
                        + "结束时间: " + detail.mEndTime.toSimpleString()
                    
                }
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
        //navigationController!.popViewControllerAnimated(true)
        setMessageStatus(MessageStatus.Confirmed)
    }
    @IBAction func onIgnore(sender: UIBarButtonItem) {
        //navigationController!.popViewControllerAnimated(true)
        setMessageStatus(MessageStatus.Ignored)
    }
    @IBAction func onComplete(sender: UIBarButtonItem) {
        //navigationController!.popViewControllerAnimated(true)
        setMessageStatus(MessageStatus.Accomplished)
    }
    private func setMessageStatus(newStatus : MessageStatus) {
        msgTask = MsgTask(controller: self)
        let user = UserManager.getInstance().getCurrentUser()!
        let url = String(format: Configure.MSG_CONFIRM_URL, detailItem!.mSrcId, detailItem!.mMsgId, newStatus.rawValue, user.lastUpdateTimestamp.toDigitString())
        msgTask!.get(url)
    }

    class MsgTask : HttpTask {
        var user : User
        var controller : DetailViewController
        required init(controller : DetailViewController) {
            self.controller = controller
            self.user = UserManager.getInstance().getCurrentUser()!
        }

        func postExcute(response: NSString) {
            if user.isLogedIn() {
                do {
                    try user.sync(response as String)
                    controller.navigationController!.popViewControllerAnimated(true)
                } catch {
                    controller.view.makeToast(message: "网络数据错误")
                }
            } else {
                controller.view.makeToast(message: "验证用户失败")
            }
        }
    }
}

