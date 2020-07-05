//
//  ActivityIndicator.swift
//  IMDB
//
//  Created by Roma Filipenko on 02.07.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

var activityIndicatorView: UIView?

func showActivityIndicator(on view: UIView) {
    
    activityIndicatorView = UIView(frame: view.bounds)
    activityIndicatorView?.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    view.isUserInteractionEnabled = false
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .white
    activityIndicator.center = activityIndicatorView!.center
    activityIndicator.startAnimating()
    
    activityIndicatorView?.addSubview(activityIndicator)
    view.addSubview(activityIndicatorView!)
}

func removeActivityIndicator(on view: UIView) {
    
    view.isUserInteractionEnabled = true
    activityIndicatorView?.removeFromSuperview()
    activityIndicatorView = nil
}
