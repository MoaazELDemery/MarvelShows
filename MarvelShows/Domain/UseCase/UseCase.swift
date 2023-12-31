import Foundation

protocol MarvelShowsUseCase {
    func fetchShows(completion: @escaping (Result<SeriesResponse, Error>) -> Void)
    func fetchMoreShows(completion: @escaping (Result<SeriesResponse, Error>) -> Void)
    func filterShows(with searchText: String) -> [Series]
}
class MarvelShowsUseCaseImpl: MarvelShowsUseCase {
    private let marvelApiService: MarvelApiService
    private var series: SeriesResponse?
    private var filteredData: [Series] = []
    private var offsetNum = 0

    init(marvelApiService: MarvelApiService) {
        self.marvelApiService = marvelApiService
    }
    func fetchShows(completion: @escaping (Result<SeriesResponse, Error>) -> Void) {
        offsetNum = 0
        marvelApiService.fetchData(offset: offsetNum) { [weak self] result in
            guard let self = self else { return }
            if let result = result {
                self.series = result
                self.filteredData = result.data.results
                completion(.success(result))
            } else {
                completion(.failure(MarvelShowsError.failedToFetchData))
            }
        }
    }
    func fetchMoreShows(completion: @escaping (Result<SeriesResponse, Error>) -> Void) {
        offsetNum += 1 
        marvelApiService.fetchData(offset: offsetNum) { [weak self] result in
            guard let self = self else { return }
            if let result = result {
                let newResults = result.data.results
                self.series?.data.results.append(contentsOf: newResults)
                self.filteredData.append(contentsOf: newResults)
                completion(.success(result))
            } else {
                completion(.failure(MarvelShowsError.failedToFetchData))
            }
        }
    }
    func filterShows(with searchText: String) -> [Series] {
        guard let series = series else { return [] }
        if searchText.isEmpty {
            return series.data.results
        } else {
            let filteredResults = series.data.results.filter({ (result) -> Bool in
                return result.title.lowercased().contains(searchText.lowercased())
            })
            return filteredResults
        }
    }
}
enum MarvelShowsError: Error {
    case failedToFetchData
}
