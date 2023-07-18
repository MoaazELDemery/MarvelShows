import UIKit

class MainViewController: UIViewController {

    var currentPage = 0
    var isLoading = false
    var isSearching = false
    var series: SeriesResponse?
    let fetchPhoto = FetchPhoto()
    var filteredData: [Series] = []
    let apiService = MarvelApiService()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let showNib = UINib(nibName: "ShowCollectionViewCell", bundle: nil)
        collectionView.register(showNib, forCellWithReuseIdentifier: "showCell")
        
        collectionViewLayout()
        
        activityIndicatorView.center = collectionView.center
        collectionView.addSubview(activityIndicatorView)
        
        loadInitialData()
        
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func loadInitialData() {
        isLoading = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        apiService.fetchData(page: currentPage) { [weak self] result in
            guard let result = result else { return }
            print(result.data.results.count)
            self?.series = result
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.isHidden = true
                self?.isLoading = false
            }
        }
    }
    func loadMoreData() {
            guard !isLoading else { return }
            isLoading = true
            currentPage += 10
            apiService.fetchData(page: currentPage) { [weak self] result in
                guard let result = result else { return }
                let newResults = result.data.results
                self?.series?.data.results.append(contentsOf: newResults)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.isLoading = false
                }
            }
        }
}
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        } else {
            return series?.data.results.count ?? 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showCell", for: indexPath) as! ShowCollectionViewCell
        let lastItem = isSearching ? filteredData.count-1 : series!.data.results.count-1
                if indexPath.row == lastItem && !isLoading {
                    loadMoreData()
                }
        cell.showImgView.image = nil
        cell.showNameLbl.text = ""
        cell.showDateLbl.text = ""
        cell.showRatingLbl.text = ""
        let result = series?.data.results[indexPath.row]
        let path = result?.thumbnail.path ?? ""
        let exten = result?.thumbnail.extension ?? ""
        let imageURL = URL(string: "\(path).\(exten)")!
        fetchPhoto.loadImage(fromURL: imageURL) { (photo) in
            guard let image = photo else {
                print("Failed to load image")
                return
            }
            DispatchQueue.main.async {
                cell.showImgView.image = image
            }
        }
        let show = isSearching ? filteredData[indexPath.row] : result
        cell.showNameLbl.text = show?.title
        if let startYear = result?.startYear {
            cell.showDateLbl.text = "Start Year: \(String(startYear))"
        }
        cell.showRatingLbl.text = "Rating: \(show?.rating ?? "Not Rated")"
        if show?.rating == "" {
            cell.showRatingLbl.text = "Rating: Not Rated"
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Selected", bundle: nil)
        let selectedVC = storyboard.instantiateViewController(withIdentifier: "selectedVC") as! SelectedViewController
        selectedVC.seriesId = series?.data.results[indexPath.row].id
        navigationController?.present(selectedVC, animated: true)
    }
    func collectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.width/2.2, height: self.view.frame.width/1.8)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView!.collectionViewLayout = layout
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
            collectionView.reloadData()
    }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = nil
            isSearching = false
            filteredData = series?.data.results ?? []
            collectionView.reloadData()
        }
}
