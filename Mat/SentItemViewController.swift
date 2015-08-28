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
            contentTextView.text = "收件人: " + item.dstTitle + "\n发件时间: " + item.timestamp.simpleString + "\n\n内容: " + item.text
            if item.type != MessageType.Text {
                contentTextView.text = contentTextView.text + "\n\n"
                    + "开始时间: " + item.startTime.simpleString + "\n"
                    + "结束时间: " + item.endTime.simpleString
            }
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
