//
//  TableViewController.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    //MARK: Properties
    
    private let tableViewModel = TableViewModel()
    private var searchController: UISearchController!

    private let cellID = "movieCell"
    private let segueID = "showMovie"
    private var canFetchMore = true
    private var pageOfMovies = 2
    
    private var searchTextString = ""
    private var savedSearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureSearchController()
        loadingTableViewContent(query: nil)
    }
    
    //MARK: Configure TableView
    
    private func loadingTableViewContent(query: String?) {
        
        showActivityIndicator(on: self.view)
        tableViewModel.startLoadingData(query: query)
        loadingProgress()
    }
    
    private func loadingProgress() {
        
        tableViewModel.showLoading = {
            if !self.tableViewModel.isLoading {
                removeActivityIndicator(on: self.view)
            }
        }
        tableViewModel.showError = { error in
            print(error)
        }
        tableViewModel.reloadData = {
            self.tableView.reloadData()
        }
    }
    
    //MARK: Configure SearchController
    
    private func configureSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        let searchBar = searchController.searchBar
        searchBar.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Search movies", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        let textField = searchBar.searchTextField
        let searchImage = #imageLiteral(resourceName: "icons8-search-50-2")
        let searchImageView = UIImageView(image: searchImage)
        textField.leftView = searchImageView
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID, let movieVC = segue.destination as? MovieViewController {
            
            if let cell = sender as? TableViewCell, let indexPath = tableView.indexPath(for: cell) {
                
                let movieViewModel = tableViewModel.movieViewModel(for: indexPath)
                movieVC.movieViewModel = movieViewModel
            }
        }
    }

    // MARK:  TableView DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewModel.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? TableViewCell

        guard let tableViewCell = cell else { return UITableViewCell() }
        
        let cellViewModel = tableViewModel.cellViewModel(for: indexPath)
        
        tableViewCell.tableCellViewModel = cellViewModel
        
        return tableViewCell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var moviesResponses: MoviesResponse? = nil
        var query: String? = nil
        
        if tableViewModel.moviesResponse != nil {
            moviesResponses = tableViewModel.moviesResponse
            query = nil
        } else if tableViewModel.searchMoviesResponse != nil {
            moviesResponses = tableViewModel.searchMoviesResponse
            query = searchController.searchBar.text
        }
        
        guard let moviesResponse = moviesResponses else { return }
        
        if pageOfMovies <= moviesResponse.totalPages {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - (2 * scrollView.frame.height) {
                if canFetchMore {
                    canFetchMore = false
                    tableViewModel.scrollBeginFetch(from: pageOfMovies, for: query)
                    tableViewModel.reloadData = {
                        self.tableView.reloadData()
                        self.canFetchMore = true
                    }
                    pageOfMovies += 1
                }
            }
        }
    }
}

//MARK: Search Results Update

extension TableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        if self.view.subviews.contains(activityIndicatorView ?? UIView()) {
            activityIndicatorView?.removeFromSuperview()
        }
        
        if searchTextString.isEmpty {
            if !tableViewModel.searchMovies.isEmpty {
                tableViewModel.searchMovies.removeAll()
                self.tableView.reloadData()
            }
        }
        
        if !searchText.isEmpty {
            if savedSearchText != searchText {
                savedSearchText = searchText
                
                tableViewModel.searchMovies.removeAll()
                loadingTableViewContent(query: searchText)
                loadingProgress()
            }
        }
    }
}

extension TableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextString = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchTextString.removeAll()
        savedSearchText.removeAll()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = searchTextString
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchTextString
    }
}

//MARK: Keyboard Dismiss

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

