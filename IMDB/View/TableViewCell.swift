//
//  TableViewCell.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var movieTitleLabel: UILabel!
    @IBOutlet private weak var movieDescriptionLabel: UILabel!
    @IBOutlet private weak var posterLoadingIndicator: UIActivityIndicatorView!
    
    private let posterLoader = ImageAPI()
    
    weak var tableCellViewModel: TableViewCellViewModel? {
        willSet(viewModel) {
            posterConfiguration()
            
            guard let viewModel = viewModel else { return }
            loadPoster(posterPath: viewModel.posterUrl)
            movieTitleLabel.text = viewModel.name
            movieDescriptionLabel.text = viewModel.description
        }
    }
    
    //MARK: Poster Configuration
    
    private func posterConfiguration() {
        let placeholderImage = #imageLiteral(resourceName: "PlaceholderImage")
        posterImage.image = placeholderImage
        posterLoadingIndicator.hidesWhenStopped = true
        posterLoadingIndicator.isHidden = false
        posterLoadingIndicator.startAnimating()
    }
    
    private func loadPoster(posterPath: String?) {
        
        guard let posterPath = posterPath else {
            posterLoadingIndicator.stopAnimating()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            self?.posterLoader.loadPoster(posterPath: posterPath, size: .small) { result in
                
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
    
    //MARK: Cell Animation
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }

    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        let animationOptions: UIView.AnimationOptions = [.allowUserInteraction]
        if isHighlighted {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 6,
                           options: animationOptions, animations: {
                            self.transform = .init(scaleX: 0.9, y: 0.9)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 6,
                           options: animationOptions, animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }
    
}
