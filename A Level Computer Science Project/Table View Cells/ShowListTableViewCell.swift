//
//  ShowListTableViewCell.swift
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 24/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class ShowListTableViewCell: UITableViewCell {

    @IBOutlet weak var cellNameLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellDescriptionLabel: UILabel!
    
    // Here you can customize the appearance of your cell
    override func layoutSubviews() {
        super.layoutSubviews()
        // Customize imageView like you need
        //self.cellImageView.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
        self.cellImageView.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
