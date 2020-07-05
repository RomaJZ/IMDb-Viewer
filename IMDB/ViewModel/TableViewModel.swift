//
//  TableViewModel.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class TableViewModel {
    
    //MARK: Properties
    
    private let movieFetcher = MovieAPI()
    
    private(set) var moviesResponse: MoviesResponse? {
        didSet {
            guard let moviesResponse = moviesResponse else { return }
            movies.append(contentsOf: moviesResponse.results)
        }
    }
    private(set) var movies: [Movie] = []
    
    private(set) var searchMoviesResponse: MoviesResponse? {
        didSet {
            guard let searchMoviesResponse = searchMoviesResponse else { return }
            searchMovies.append(contentsOf: searchMoviesResponse.results)
        }
    }
    var searchMovies: [Movie] = []
    
    var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }
    var showLoading: (() -> Void)?
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?
    private let group = DispatchGroup()
    
    //MARK: Loading Data
    
    func startLoadingData(query: String?) {
        
        isLoading = true
        loadMoviesResponse(page: 1, query: query)
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
        }
    }
    
    //MARK: Loading Movie List
    
    private func loadMoviesResponse(page: Int, query: String?) {
        
        group.enter()
        movieFetcher.fetchTrendingMovies(page: page, query: query) { [weak self] result in
            
            switch result {
                
            case .success(let moviesResponse):
                if query == nil {
                    self?.moviesResponse = moviesResponse
                } else {
                    self?.searchMoviesResponse = moviesResponse
                }
                
            case .failure(let error):
                self?.showError?(error)
            }
            self?.group.leave()
        }
    }
    
    //MARK: TableView UI
    
    func numberOfRows() -> Int {
        
        if searchMovies.isEmpty {
            guard !movies.isEmpty else { return 0 }
            return movies.count
        } else {
            return searchMovies.count
        }
    }
    
    func scrollBeginFetch(from page: Int, for query: String?) {
        
        DispatchQueue.global(qos: .background).async(group: group) { [weak self] in
            
            self?.loadMoviesResponse(page: page, query: query)
        }
        group.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
        }
    }
    
    //MARK: TableViewCell UI
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel? {
        
        if searchMovies.isEmpty {
            guard !movies.isEmpty else { return nil }
            let movie = movies[indexPath.row]
            return TableViewCellViewModel(movie: movie)
        } else {
            
            let searchMovie = searchMovies[indexPath.row]
            return TableViewCellViewModel(movie: searchMovie)
        }
    }
    
    //MARK: MovieView UI
    
    func movieViewModel(for indexPath: IndexPath) -> MovieViewModel? {
        
        if searchMovies.isEmpty {
            guard !movies.isEmpty else { return nil }
            let movieId = movies[indexPath.row].id
            return MovieViewModel(movieId: movieId)
        } else {
            
            let searchMovieId = searchMovies[indexPath.row].id
             return MovieViewModel(movieId: searchMovieId)
        }
    }
}
