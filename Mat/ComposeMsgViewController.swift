//
//  ComposeMessageViewController.swift
//  Mat
//
//  Created by 君君 on 15/8/27.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class ComposeMessageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let typeStrings = ["文本消息", "集会消息", "任务消息"]

    @IBOutlet weak var receiverTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    var startTimeDatePicker : UIDatePicker?
    var endTimeDatePicker : UIDatePicker?
    let dateFormatter = DateTime.DateFormatterWrapper(format: "yyyy-MM-dd HH:mm")
    var syncMessageTask : SyncMessageTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let typePicker = UIPickerView()
        typePicker.delegate = self
        typeTextField.inputView = typePicker
        typeTextField.text = typeStrings[0]

        startTimeDatePicker = UIDatePicker()
        startTimeDatePicker!.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        startTimeTextField.inputView = startTimeDatePicker
        startTimeTextField.text = dateFormatter.stringFromDate(startTimeDatePicker!.date)
        startTimeTextField.hidden = true
        startTimeLabel.hidden = true

        endTimeDatePicker = UIDatePicker()
        endTimeDatePicker!.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        endTimeTextField.inputView   = endTimeDatePicker
        endTimeTextField.text = dateFormatter.stringFromDate(endTimeDatePicker!.date)
        endTimeTextField.hidden = true
        endTimeLabel.hidden = true

        contentTextView.text = ""
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.grayColor().CGColor

        syncMessageTask = SyncMessageTask(controller: self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func handleDatePicker(sender : UIDatePicker) {
        if (sender == startTimeDatePicker) {
            startTimeTextField.text = dateFormatter.stringFromDate(sender.date)
        } else if (sender == endTimeDatePicker) {
            endTimeTextField.text = dateFormatter.stringFromDate(sender.date)
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return typeStrings.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeStrings[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = typeStrings[row]
        let hideDatePicker = (row == 0)
        startTimeLabel.hidden = hideDatePicker
        startTimeTextField.hidden = hideDatePicker
        endTimeLabel.hidden = hideDatePicker
        endTimeTextField.hidden = hideDatePicker
        self.view.endEditing(true)
    }
    @IBAction func onSend(sender: UIButton) {
        
    }
    class SyncMessageTask : HttpTask {
        var user : User
        var controller : ComposeMessageViewController
        required init(controller : ComposeMessageViewController) {
            self.controller = controller
            self.user = UserManager.currentUser!
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
                    //controller.navigationController!.popViewControllerAnimated(true)
                    controller.dismissViewControllerAnimated(true, completion: nil)
                } catch {
                    controller.view.makeToast(message: "网络数据错误")
                    //controller.enableSyncButton(true)
                }
            } else {
                controller.view.makeToast(message: "验证用户失败")
                //controller.enableSyncButton(true)
            }
        }
    }
}
