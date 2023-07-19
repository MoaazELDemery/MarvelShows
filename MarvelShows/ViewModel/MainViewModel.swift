import Foundation

protocol MainViewControllerProtocol: AnyObject {
    func displayShows(data: SeriesResponse)
    func displayMoreShows(data: SeriesResponse)
    func displayError(error: String)
}

class MainViewModel {
    private let marvelShowsUseCase: MarvelShowsUseCase
    private var data: String = ""
    
    // Closure for view binding
    var onDataUpdate: ((SeriesResponse) -> Void)?
    
    // Delegate for view binding
    weak var viewDelegateProtocol: MainViewControllerProtocol?
    
    init(marvelShowsUseCase: MarvelShowsUseCase) {
        self.marvelShowsUseCase = marvelShowsUseCase
    }
    func fetchShows(page: Int) {
        marvelShowsUseCase.fetchShows(page: page, completion: { [weak self] result in
            switch result {
            case .success(let response):
                self?.viewDelegateProtocol?.displayShows(data: response)
            case .failure(let error):
                self?.viewDelegateProtocol?.displayError(error: error.localizedDescription)
            }
        })
    }
    func fetchMoreShows(page: Int) {
        marvelShowsUseCase.fetchMoreShows(completion: { [weak self] result in
            switch result {
            case .success(let response):
                self?.viewDelegateProtocol?.displayShows(data: response)
            case .failure(let error):
                self?.viewDelegateProtocol?.displayError(error: error.localizedDescription)
            }
        })
    }
}
