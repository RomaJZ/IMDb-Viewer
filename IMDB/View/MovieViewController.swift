//
//  MovieViewController.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    //MARK: Properties

    var movieViewModel: MovieViewModel?
    private let posterLoader = ImageAPI()
    
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var directorsLabel: UILabel!
    @IBOutlet private weak var castLabel: UILabel!
    @IBOutlet weak var posterLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showActivityIndicator(on: self.view)
        loadingProgress()
    }
    
    //MARK: Movie Content Config
    
    private func loadingMovieContent() {
        
        posterConfiguration()
        labelConfig(of: movieViewModel?.genres, for: genresLabel)
        releaseDateLabel.text = movieViewModel?.releaseDate
        descriptionLabel.text = movieViewModel?.description
        labelConfig(of: movieViewModel?.directors, for: directorsLabel)
        labelConfig(of: movieViewModel?.cast, for: castLabel)
    }
    
    //MARK: Labels Config
    
    private func labelConfig(of array: [String]?, for label: UILabel) {
        guard let arr = array else { return }
        guard var text = label.text else { return }
        for element in arr {
            if !text.isEmpty {
                text.append(contentsOf: ", \(element)")
            } else {
                text.append(contentsOf: element)
            }
        }
        label.text = text
    }
    
    //MARK: Loading Progres
    
    private func loadingProgress() {
        
        movieViewModel?.showLoading = { [weak self] in
            guard let self = self else { return }
            
            if !self.movieViewModel!.isLoading {
                removeActivityIndicator(on: self.view)
                self.loadingMovieContent()
            }
        }
        movieViewModel?.showError = { error in
            print(error)
        }
    }
    
    //MARK: Poster Configuration
    
    private func posterConfiguration() {
        let placeholderImage = #imageLiteral(resourceName: "PlaceholderImage")
        posterImage.image = placeholderImage
        posterLoadingIndicator.hidesWhenStopped = true
        posterLoadingIndicator.isHidden = false
        posterLoadingIndicator.startAnimating()
        
        guard let movieViewModel = movieViewModel else { return }
        loadPoster(posterPath: movieViewModel.posterUrl)
    }
    
    private func loadPoster(posterPath: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            self?.posterLoader.loadPoster(posterPath: posterPath, size: .original) { result in
                
                switch result {
                    case .success(let poster):
                        DispatchQueue.main.async {
                            self?.posterImage.image = poster
                            self?.posterLoadingIndicator.stopAnimating()
                        }
                    
                    case .failure(let error):
                        print("Error!!! \(error)")
                        DispatchQueue.main.async {
                            self?.posterLoadingIndicator.stopAnimating()
                        }
                }
            }
        }
    }
}
