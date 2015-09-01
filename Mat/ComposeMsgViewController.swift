//
//  ComposeMessageViewController.swift
//  Mat
//
//  Created by 君君 on 15/8/27.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class ComposeMessageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate {
    let typeStrings = ["文本消息", "集会消息", "任务消息"]

    @IBOutlet weak var receiverTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    var startTimeDatePicker : UIDatePicker?
    var endTimeDatePicker : UIDatePicker?
    var unitContactRE: NSRegularExpression!
    let dateFormatter = DateTime.DateFormatterWrapper(format: "yyyy-MM-dd HH:mm")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            unitContactRE = try NSRegularExpression(pattern: Configure.UNIT_CONTACT_RE, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            fatalError("INVALID REGULAR EXPRESSION for UNIT CONTACT")
        }

        receiverTextField.delegate = self

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
        placeLabel.hidden = hideDatePicker
        placeTextField.hidden = hideDatePicker
        self.view.endEditing(true)
    }
    @IBAction func onSend(sender: UIButton) {
        let user = UserManager.currentUser!
        var receivers = ""
        let contacts = receiverTextField.text!.componentsSeparatedByString(";")
        for contact in contacts {
            if !contact.isEmpty {
                receivers = receivers + contact.componentsSeparatedByString(",")[0] + ";"
            }
        }
        let type = MessageType(rawValue: typeStrings.indexOf(typeTextField.text!)!)!
        var startTime = DateTime.Zero
        var endTime = DateTime.Zero
        var place = ""
        if type != MessageType.Text {
            startTime = DateTime(date: startTimeDatePicker!.date)
            endTime = DateTime(date: endTimeDatePicker!.date)
            place = placeTextField!.text!
        }
        //MatServer.sendMessage(user, dst: receiver, type: type, startTime: startTime, endTime: endTime, place: "", text: contentTextView!.text, completionHanlder: handleSendMessageResult)
        MatServer.sendMessage(user, dst: receivers, type: type, startTime: startTime, endTime: endTime, place: place, text: contentTextView!.text, completionHanlder: handleSendMessageResult)
    }
    
    func handleSendMessageResult(result : MatError?) {
        if result == nil {
            dismissViewControllerAnimated(true, completion: nil)
            navigationController!.popViewControllerAnimated(true)
        } else if result! == MatError.AuthFailed {
            view.makeToast(message: "验证用户失败")
        } else if result! == MatError.NetworkDataError {
            view.makeToast(message: "网络数据错误")
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let seperator =  NSString(string: ";").characterAtIndex(0)
        if range.location == text.length && range.length == 0 {
            if (string == " ") { // the end of editing an item
                let items = text.componentsSeparatedByString(";")
                let lastItem = items[items.count - 1]
                let text = text.substringToIndex(text.length - (lastItem as NSString).length)
                receiverTextField.text = text
                onChooseContactFromTextField(items[items.count - 1])
                return false
            } else { // normal input
                return true
            }
        } else if string.isEmpty {
            var index1 = range.location - 1
            while index1 >= 0 && text.characterAtIndex(index1) !=  seperator {
                index1--
            }
            var index2 = range.location + range.length - 1
            while index2 < text.length - 1 && text.characterAtIndex(index2) !=  seperator {
                index2++
            }
            textField.text = text.substringToIndex(index1 + 1) + text.substringFromIndex(index2 + 1)
            return false
        }else {
            return false
        }
    }
    func onChooseContactFromTextField(string: String) {
        if unitContactRE.matchesInString(string, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0,(string as NSString).length)).count > 0 {
            let unitTitle = UserManager.currentUser!.getUnitTitle(string)
            receiverTextField.text = receiverTextField.text! + "\(string),\(unitTitle);"
            return
        }
        let candidates = UserManager.currentUser!.getContacts(string)
        if candidates.count == 1 {
            receiverTextField.text = receiverTextField.text! + "\(candidates[0].id),\(candidates[0].name);"
            return
        }
        let menu = UIActionSheet(title: "选择联系人", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        for candidate in candidates {
            menu.addButtonWithTitle(String(candidate.id) + "," + candidate.name)
        }
        menu.showInView(self.view)
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 {
            let chosen = actionSheet.buttonTitleAtIndex(buttonIndex)!
            receiverTextField.text = receiverTextField.text! + chosen + ";"
        }
    }
}
