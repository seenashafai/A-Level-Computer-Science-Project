//
//  TicketTableViewCell
//  A Level Computer Science Project
//
//  Created by Shafai, Seena (JRBS) on 24/09/2018.
//  Copyright © 2018 Seena Shafai. All rights reserved.
//

import UIKit

class TicketTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellNameLabel: UILabel!
    @IBOutlet weak var cellDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
