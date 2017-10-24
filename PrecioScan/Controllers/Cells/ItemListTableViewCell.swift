//
//  ItemListTableViewCell.swift
//  PrecioScan
//
//  Created by Félix Olivares on 19/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitaryPriceLabel: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(){
        self.layoutIfNeeded()
    }
    
}
