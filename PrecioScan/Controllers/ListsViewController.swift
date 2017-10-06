//
//  ListsViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 05/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    //MARK: - Setup TableView
    func setupTableView(){
        let listCell = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(listCell, forCellReuseIdentifier: listCellIdentifier)
        tableView.separatorStyle = .none
        //tableView.backgroundColor = UIColor.init(hexString: "F7F7F7")
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableViewAutomaticDimension

    }
}
