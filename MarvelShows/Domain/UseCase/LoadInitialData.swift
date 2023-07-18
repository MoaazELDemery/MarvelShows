//
//  LoadInitialData.swift
//  MarvelShows
//
//  Created by M.Ibrahim on 18/07/2023.
//

import Foundation
import UIKit

class LoadInitialData{
    var currentPage = 0
    var isLoading = false
    var series: SeriesResponse?
    let apiService = MarvelApiService()
    let mainVC = MainViewController()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    func loadInitialData() {
            isLoading = true
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            
            apiService.fetchData(page: currentPage) { [weak self] result in
                guard let result = result else { return }
                print(result.data.results.count)
                self?.series = result
                DispatchQueue.main.async {
                    self?.mainVC.collectionView.reloadData()
                    self?.activityIndicatorView.stopAnimating()
                    self?.activityIndicatorView.isHidden = true
                    self?.isLoading = false
                }
            }
        }

}
