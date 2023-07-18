import UIKit

class SelectedViewController: UIViewController {

    var seriesId: Int?
    let fetchPhoto = FetchPhoto()
    let defaults = UserDefaults.standard
    var series: Series? = nil
    var selectedSeries: SelectedResponce?
    let selectedApiService = DetailsApiService()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)

    @IBOutlet var selectedNameLbl: UILabel!
    @IBOutlet var selectedStartDateLbl: UILabel!
    @IBOutlet var selectedEndDateLbl: UILabel!
    @IBOutlet var selectedRatingLbl: UILabel!
    @IBOutlet var selectedCreatorLbl: UILabel!
    @IBOutlet var selectedImgView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView.center = view.center
        view.addSubview(activityIndicatorView)
        
        loadSelectedData()
    }
    func loadSelectedData() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
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
                self.selectedNameLbl.text = series.title
                self.selectedStartDateLbl.text = "Start Year: \(String(series.startYear))"
                self.selectedEndDateLbl.text = "End Year: \(String(series.endYear))"
                self.selectedRatingLbl.text = "Rating: \(series.rating)"
                if series.rating == "" {
                    self.selectedRatingLbl.text = "Rating: Not Rated"
                }
                self.selectedCreatorLbl.text = "Creator: \(series.creators.items.first?.name ?? "")"
                if series.creators.items.first?.name == nil {
                    self.selectedCreatorLbl.text = "Creator: N/A"
                }
                let path = series.thumbnail.path
                let exten = series.thumbnail.extension
                let imageURL = URL(string: "\(path).\(exten)")!
                
                self.fetchPhoto.loadImage(fromURL: imageURL) { [weak self] (photo) in
                    guard let image = photo else {
                        print("Failed to load image") // Debugging statement
                        return
                    }
                    DispatchQueue.main.async {
                        self?.selectedImgView.image = image
                        self?.activityIndicatorView.stopAnimating()
                        self?.activityIndicatorView.isHidden = true
                    }
                }
            }
        }
    }
}
