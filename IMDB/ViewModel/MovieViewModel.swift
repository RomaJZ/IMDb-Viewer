//
//  MovieViewModel.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class MovieViewModel {
    
    private var movieId: Int
    
    init(movieId: Int) {
        self.movieId = movieId
        
        loadMovie(movieId: movieId)
    }
    
    private let group = DispatchGroup()
    private let movieFetcher = MovieAPI()
    
    var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }
    var showLoading: (() -> Void)?
    var showError: ((Error) -> Void)?
    
    func loadMovie(movieId: Int) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async(group: group) { [weak self] in
            guard let self = self else { return }
            
            self.group.enter()
            self.movieFetcher.fetchMovie(id: movieId) { [weak self] result in
                
                switch result {
                    
                case .success(let movie):
                    self?.movie = movie
                    
                case .failure(let error):
                    self?.showError?(error)
                }
                self?.group.leave()
            }
            
            self.group.enter()
            self.movieFetcher.fetchCredits(id: movieId) { [weak self] result in
                
                switch result {
                    
                case .success(let credits):
                    self?.credits = credits
                    
                case .failure(let error):
                    self?.showError?(error)
                }
                self?.group.leave()
            }
            
            self.group.notify(queue: .main) {
                self.isLoading = false
            }
        }
    }
    
    var movie: Movie?
    
    var name: String {
        return movie?.name ?? ""
    }
    
    var description: String {
        return movie?.description ?? ""
    }
    
    var posterUrl: String {
        return movie?.posterURL ?? ""
    }
    
    var releaseDate: String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "d MMM, yyyy"
        
        guard let date = dateFormatterGet.date(from: movie?.releaseDate ?? "") else { return "Date decoding error!" }
        
        return dateFormatterPrint.string(from: date)
    }
    
    var genres: [String] {
        guard let genres = movie?.genres else { return ["No info"] }
        return genres.map {$0.name!}
    }
    
    private var credits: Credits?
    
    var directors: [String] {
        guard let credits = credits else { return ["No info"] }
        let crew = credits.crew
        
        let directors = crew.filter { $0.job == "Director" }
        return directors.map { $0.name }
    }
    
    var cast: [String] {
        guard let credits = credits else { return ["No info"] }
        let cast = credits.cast
        let castNames = cast.map { $0.name }
        
        return Array(castNames.prefix(5))
    }
}
