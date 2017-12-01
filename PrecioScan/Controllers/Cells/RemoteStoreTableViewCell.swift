//
//  RemoteStoreTableViewCell.swift
//  PrecioScan
//
//  Created by Félix Olivares on 29/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class RemoteStoreTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
