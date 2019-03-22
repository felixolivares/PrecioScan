//
//  StoreTableViewCell.swift
//  PrecioScan
//
//  Created by Félix Olivares on 27/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    func configureCell(){
        containerView.layer.borderColor = UIColor(softGray)?.cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 14.0
    }
}
