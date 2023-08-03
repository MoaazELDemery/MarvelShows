import UIKit

class MainViewController: UIViewController {
    
    var seriesId: Int?
    var selectedIndex = -1
    var isColapse = false
    var isLoading = false
    var isSearching = false
    var series: SeriesResponse?
    let fetchPhoto = FetchPhoto()
    var filteredData: [Series] = []
    var mainCell: ShowTableViewCell?
    let apiService = MarvelApiService()
    let defaults = UserDefaults.standard
    var selectedSeries: SelectedResponce?
    let selectedApiService = DetailsApiService()
    let imageCache = NSCache<NSString, UIImage>()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    private var viewModel: MainViewModel = .init(marvelShowsUseCase: MarvelShowsUseCaseImpl(marvelApiService: MarvelApiService()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDelegateProtocol = self
        setupView()
        loadInitialData()
    }
    func setupView() {
        let showNib = UINib(nibName: "ShowTableViewCell", bundle: nil)
        tableView.register(showNib, forCellReuseIdentifier: "showCell")
        activityIndicatorView.center = tableView.center
        tableView.addSubview(activityIndicatorView)
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 215
        tableView.rowHeight = UITableView.automaticDimension
    }
    func loadInitialData() {
        isLoading = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        viewModel.fetchShows()
    }
    func loadMoreData() {
        if series!.data.results.count <= series!.data.total {
            guard !isLoading else { return }
            isColapse = false
            isLoading = true
            apiService.offset += 10
            apiService.fetchData(offset: apiService.offset) { [weak self] result in
                guard let result = result else { return }
                let newResults = result.data.results
                self?.series?.data.results.append(contentsOf: newResults)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.isLoading = false
                }
            }
        }
    }
    func loadSelectedData() {
        let cacheKey = "selectedSeries_\(seriesId ?? 0)"
        if let data = defaults.data(forKey: cacheKey),
           let selectedSeries = try? JSONDecoder().decode(SelectedResponce.self, from: data) {
            self.selectedSeries = selectedSeries
            updateUI()
            return
        }
        selectedApiService.fetchData(seriesId: seriesId) { [weak self] result in
            guard let result = result else { return }
            self?.selectedSeries = result
            self?.saveSelectedData(cacheKey: cacheKey)
            self?.updateUI()
        }
    }
    func saveSelectedData(cacheKey: String) {
        guard let data = try? JSONEncoder().encode(selectedSeries) else { return }
        defaults.set(data, forKey: cacheKey)
    }
    func updateUI() {
        DispatchQueue.main.async {
            if let series = self.selectedSeries?.data.results[0] {
                self.mainCell?.showEndYearLbl.text = "End Year: \(String(series.endYear))"
                self.mainCell?.showCreatorLbl.text = "Creator: \(series.creators.items.first?.name ?? "")"
                if series.creators.items.first?.name == nil {
                    self.mainCell?.showCreatorLbl.text = "Creator: N/A"
                }
                self.mainCell?.indicatorView.isHidden = true
                self.mainCell?.indicatorView.stopAnimating()
            }
        }
    }
}
extension MainViewController: MainViewControllerProtocol {
    func displayShows(data: SeriesResponse) {
        self.series = data
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.activityIndicatorView.stopAnimating()
            self?.activityIndicatorView.isHidden = true
            self?.isLoading = false
        }
    }
    func displayMoreShows(data: SeriesResponse) {
        let newResults = data.data.results
        self.series?.data.results.append(contentsOf: newResults)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.isLoading = false
        }
    }
    func displayError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            let window = UIApplication.shared.keyWindow
            window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row && isColapse == true {
            return 215
        } else {
            return 130
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        } else {
            return series?.data.results.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowTableViewCell
        mainCell = cell
        cell.indicatorView.isHidden = false
        cell.indicatorView.startAnimating()
        let result = series?.data.results[indexPath.row]
        let show = isSearching ? filteredData[indexPath.row] : result
        let path = show?.thumbnail.path ?? ""
        let exten = show?.thumbnail.extension ?? ""
        let imageURL = URL(string: "\(path).\(exten)")!
        if let cachedImage = imageCache.object(forKey: imageURL.absoluteString as NSString) {
            cell.showImgView.image = cachedImage
        } else {
            tableView.performBatchUpdates({
                cell.showImgView.image = nil
                fetchPhoto.loadImage(fromURL: imageURL) { (photo) in
                    guard let image = photo else {
                        print("Failed to load image")
                        return
                    }
                    self.imageCache.setObject(image, forKey: imageURL.absoluteString as NSString)
                    DispatchQueue.main.async {
                        cell.showImgView.image = image
                    }
                }
            }) { (finished) in
            }
        }
        cell.showNameLbl.text = show?.title
        if let startYear = show?.startYear {
            cell.showDateLbl.text = "Start Year: \(String(startYear))"
        }
        cell.showRatingLbl.text = "Rating: \(show?.rating ?? "Not Rated")"
        if show?.rating == "" {
            cell.showRatingLbl.text = "Rating: Not Rated"
        }
        if selectedIndex == indexPath.row && isColapse == true {
            cell.showMoreImg.image = UIImage(systemName: "chevron.up")
        } else {
            cell.showMoreImg.image = UIImage(systemName: "chevron.down")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if selectedIndex == indexPath.row {
            isColapse.toggle()
        } else {
            isColapse = false
        }
        loadSelectedData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        let selectedShow: Series
        selectedShow = series!.data.results[indexPath.row]
        seriesId = selectedShow.id
    }
}
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let series = series else { return }
        if searchText.isEmpty {
            isSearching = false
            filteredData = series.data.results
        } else {
            isSearching = true
            filteredData = series.data.results.filter({ (result) -> Bool in
                return result.title.lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        isSearching = false
        filteredData = series?.data.results ?? []
        tableView.reloadData()
    }
}
extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            loadMoreData()
        }
    }
}
