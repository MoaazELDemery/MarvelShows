import UIKit
import IGListKit
class MainListAdapter: NSObject, IGListAdapterDataSource {
    let apiService = ApiService()
    var shows: [Show] = []
    var isSearching = false
    var currentPage = 0
    let pageLimit = 20
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return shows as [IGListDiffable]
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return ShowSectionController()
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
    
    func fetchNextPage(completion: @escaping () -> Void) {
        apiService.fetchShows(page: currentPage + 1, limit: pageLimit) { [weak self] result in
            guard let result = result else { return }
            self?.currentPage += 1
            self?.shows.append(contentsOf: result)
            completion()
        }
    }
}
