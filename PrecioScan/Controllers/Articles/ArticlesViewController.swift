//
//  ArticlesViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 01/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton
import TableViewReloadAnimation

class ArticlesViewController: UIViewController {

    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var articlesCountLabel: UILabel!
    
    var articles: [Article] = []
    var filteredArticles: [Article] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureComponents()
        if !searchController.isActive{
            fetchArticles()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toArticleDetailFromArticles{
            let articleToSend: Article!
            let indexPath = sender as! IndexPath
            if isFiltering() {
                articleToSend = filteredArticles[indexPath.row]
            } else {
                articleToSend = articles[indexPath.row]
            }
            let vc = segue.destination as! ArticleDetailViewController
            vc.articleSelected = articleToSend
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hamburguerMenuButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        (self.navigationController as! NavigationArticlesViewController).showSideMenu()
    }
    func configure(){
        configureComponents()
        configureTable()
        configureSearchController()
    }
    
    func configureComponents(){
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: false)
    }
    
    func configureTable(){
        let articleTableViewCell = UINib(nibName: Identifiers.articleTableViewCell, bundle: nil)
        tableView.register(articleTableViewCell, forCellReuseIdentifier: CellIdentifiers.articleCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar Articulos"
        searchController.hidesNavigationBarDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.searchBarStyle = .minimal
        searchBarContainer.addSubview(searchBar)
        definesPresentationContext = true
    }
    
    func fetchArticles(){
        CoreDataManager.shared.articles(findWithCode: nil){_, articlesFetched, error in
            guard error == nil else {Popup.show(withError: error! as NSError, vc: self); return}
            self.articles = articlesFetched!
            self.filteredArticles = self.articles
            if self.articles.count > 0{
                self.articlesCountLabel.text = String(describing: self.articles.count)
                self.tableView.reloadData(
                    with: .simple(duration: 0.45, direction: .rotation3D(type: .ironMan),
                                  constantDelay: 0))
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredArticles = articles.filter({( article: Article) -> Bool in
            return article.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if filteredItemCount == totalItemCount{
            print("No update")
        } else if filteredItemCount == 0 {
            articlesCountLabel.text = "0"
        } else {
            articlesCountLabel.text = String(describing: filteredArticles.count)
        }
    }
}

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            self.setIsFilteringToShow(filteredItemCount: filteredArticles.count, of: articles.count)
            return filteredArticles.count
        }
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.articleCell) as! ArticleTableViewCell
        let article: Article!
        if isFiltering(){
            article = filteredArticles[indexPath.row]
        }else{
            article = articles[indexPath.row]
        }
        cell.articleNameLabel.text = article.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.toArticleDetailFromArticles, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

extension ArticlesViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive{
            filterContentForSearchText(searchController.searchBar.text!)
        }else{
            articlesCountLabel.text = String(describing: articles.count)
            self.tableView.reloadData()
        }
    }
}
