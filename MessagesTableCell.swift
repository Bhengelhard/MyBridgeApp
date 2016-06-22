//
//  MessagesTableCellTableViewCell.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MessagesTableCell: UITableViewCell {
    

    @IBOutlet weak var messageSnapshot: UILabel!
    @IBOutlet weak var messageTimestamp: UILabel!
    @IBOutlet weak var participants: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
