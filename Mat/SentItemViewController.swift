//
//  SentItemViewController.swift
//  Mat
//
//  Created by 君君 on 15/8/26.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class SentItemViewController: UIViewController {
    @IBOutlet weak var contentTextView: UITextView!

    var item : SentItem? {
        didSet {
            //configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureView() {
        if let item = self.item {
            var text = ""
            text = "收件人: " + item.dstTitle + "\n发件时间: " + item.timestamp.simpleString + "\n\n内容: \n\n" + item.text + "\n\n"
            if item.type != MessageType.Text {
                text = text + "开始时间: " + item.startTime.simpleString + "\n" + "结束时间: " + item.endTime.simpleString + "\n\n"
            }

            text += "确认记录----------\n"
            let confirmItems = UserManager.currentUser?.getConfirmItems(item.msgId)
            for confirmItem in confirmItems! {
                text = text + confirmItem.dstTitle + "  "
                if confirmItem.status == MessageStatus.Init {
                    text += "未确认\n"
                } else {
                    text += "已确认\n"
                }
            }
            contentTextView.text = text
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
    @IBAction func onBack(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }

}
