//
//  ReviewTableViewCell.swift
//  A Level Computer Science Project
//
//  Created by Seena Shafai on 16/01/2019.
//  Copyright © 2019 Seena Shafai. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var cellNameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
