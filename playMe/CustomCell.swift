//
//  CustomCell.swift
//  playMe
//
//  Created by Szabolcs Tacman on 25/12/15.
//  Copyright © 2015 Szabolcs Tacman. All rights reserved.
//

import UIKit

/*
                ** Class for creating custom cells in TableViews **
*/

class CustomCell: UITableViewCell {

    // It has only label now
    // @IBOutlet var imageDevice: UIImageView!
    @IBOutlet var labelDevice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
