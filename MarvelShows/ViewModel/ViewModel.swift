import Foundation

class ViewModel {
    var isLoading = false
    var isSearching = false
    var series: SeriesResponse?
    var filteredData: [Series] = []
    let marvelShowsUseCase: MarvelShowsUseCase
    init(marvelShowsUseCase: MarvelShowsUseCase) {
        self.marvelShowsUseCase = marvelShowsUseCase
    }
    func fetchData(completion: @escaping () -> Void) {
        isLoading = true
        marvelShowsUseCase.fetchShows { [weak self] result in
            switch result {
            case .success(let seriesResponse):
                self?.series = seriesResponse
                self?.filteredData = seriesResponse.data.results
            case .failure(_):
                break
            }
            self?.isLoading = false
            completion()
        }
    }
    func loadMoreData(completion: @escaping () -> Void) {
        guard !isLoading else { return }
        isLoading = true
        marvelShowsUseCase.fetchMoreShows { [weak self] result in
            switch result{
            case .success(let seriesResponse):
                self?.series = seriesResponse
                self?.filteredData = seriesResponse.data.results
            case .failure(_):
                break
            }
            self?.isLoading = false
            completion()
        }
    }
    func filterData(with searchText: String) {
        isSearching = !searchText.isEmpty
        filteredData = marvelShowsUseCase.filterShows(with: searchText)
    }
}

