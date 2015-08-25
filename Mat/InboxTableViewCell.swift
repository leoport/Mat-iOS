//
//  MasterTableViewCell.swift
//  Mat
//
//  Created by 君君 on 15/8/18.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var leftHintLabel: UILabel!
    @IBOutlet weak var rightHintLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
