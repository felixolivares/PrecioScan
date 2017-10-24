//
//  ListTableViewCell.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var numberOfArticlesLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            
        }
    }

    func configure(){
        borderView.layer.borderColor = UIColor(softGray)?.cgColor
        borderView.layer.borderWidth = 1.0
        borderView.layer.cornerRadius = 14.0
    }
}
