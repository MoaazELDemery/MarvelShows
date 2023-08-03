import UIKit

class ShowTableViewCell: UITableViewCell {

    @IBOutlet var showImgView: UIImageView!
    @IBOutlet var showMoreImg: UIImageView!
    @IBOutlet var showNameLbl: UILabel!
    @IBOutlet var showDateLbl: UILabel!
    @IBOutlet var showRatingLbl: UILabel!
    @IBOutlet var showCreatorLbl: UILabel!
    @IBOutlet var showEndYearLbl: UILabel!
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        showNameLbl.text = ""
        showDateLbl.text = ""
        showRatingLbl.text = ""
        showCreatorLbl.text = ""
        showEndYearLbl.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
