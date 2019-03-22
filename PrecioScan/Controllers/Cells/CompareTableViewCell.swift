//
//  CompareTableViewCell.swift
//  PrecioScan
//
//  Created by Félix Olivares on 26/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class CompareTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
