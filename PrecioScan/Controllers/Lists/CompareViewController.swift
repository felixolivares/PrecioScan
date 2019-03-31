//
//  CompareViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 25/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import TableViewReloadAnimation

class CompareViewController: UIViewController {

    @IBOutlet weak var articleNameLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var todayTitleLabel: UILabel!
    
    var articleCode: String!
    var articleFound: Article!
    var store: Store!
    var todayPrice: String!
    var headerKeys: [String] = []
    var items: [[ItemList]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticle()
        fetchItemLists()
        configureTable()
    }

    func configureTable(){
        let compareTableViewCell = UINib(nibName: Identifiers.compareTableViewCell, bundle: nil)
        tableView.register(compareTableViewCell, forCellReuseIdentifier: CellIdentifiers.compareCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func fetchArticle(){
        CoreDataManager.shared.articles(findWithCode: articleCode){ stack, articles, error in
            if let articles = articles{
                self.articleFound = articles.first
                self.populateArticleInfo()
            }
        }
    }
    
    func fetchItemLists(){
        guard articleCode != nil else {return}
        CompareOperations().getItemLists(byArticleCode: articleCode){ keys, items in
            self.headerKeys = keys
            self.items = items
            self.tableView.reloadData()
        }
    }
    
    func populateArticleInfo(){
        articleNameLabel.text = articleFound.name
        if store != nil{
            storeNameLabel.text = store.name + " - " + store.location
        }else{
            storeNameLabel.text = ""
        }
        
        if todayPrice != "" {
            priceLabel.text = todayPrice
        } else {
            priceLabel.text = ""
            todayTitleLabel.text = Constants.Compare.historyTitle
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK: - Table View Extension
extension CompareViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.compareCell) as! CompareTableViewCell
        cell.dateLabel.text = DateOperations().dateToString(date: items[indexPath.section][indexPath.row].date as Date)
        cell.priceLabel.text = "$" + String(format: "%.2f", Double(items[indexPath.section][indexPath.row].unitaryPrice))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed(Identifiers.headerCompareTableViewCell, owner: self, options: nil)?.first as! HeaderCompareTableViewCell
        headerView.storeNameLabel.text = headerKeys[section]
        return headerView
    }
}
