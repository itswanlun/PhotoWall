import Foundation

class PhotoGridViewModel {
    let apiService: APIServiceProtocol
    let perPageCount = 30
    
    private(set) var page: Int = 1
    var keyword: String?
    var data: [PhotoItem] = []
    var isLoadingMore: Bool = false {
        didSet {
            isLoadingClosure?(isLoadingMore)
        }
    }
    var isNoResult: Bool = false {
        didSet {
            isNoResultClosure?(isNoResult)
        }
    }
    
    var message: (title: String?, description: String?) = (nil, nil) {
        didSet {
            showMessageClosure?(message.title, message.description)
        }
    }
    
    // MARK: - Closures
    var dataChangedClosure: (([PhotoItem], Bool) -> Void)?
    var isLoadingClosure: ((Bool) -> Void)?
    var isNoResultClosure: ((Bool) -> Void)?
    var showMessageClosure: ((String?, String?) -> Void)?
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func loadData(keyword: String? = nil, isRefresh: Bool = false) {
        isLoadingMore = true
        if let keyword = keyword {
            apiService.getSearchPhoto(page: page, perPage: perPageCount, keyword: keyword, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                self.isLoadingMore = false
                
                switch result {
                case .success(let photos):
                    guard !photos.isEmpty else {
                        self.isNoResult = true
                        return
                    }
                    
                    if isRefresh {
                        self.data = photos
                    } else {
                        self.data.append(contentsOf: photos)
                    }
                    
                    self.dataChangedClosure?(self.data, isRefresh)
                case .failure:
                    self.message = (title: "Error", description: "Something went wrong!")
                }
            })
        } else {
            apiService.getRandomPhoto(page: page, perPage: perPageCount, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                self.isLoadingMore = false
                
                switch result {
                case .success(let photos):
                    guard !photos.isEmpty else {
                        self.isNoResult = true
                        return
                    }
                    
                    if isRefresh {
                        self.data = photos
                    } else {
                        self.data.append(contentsOf: photos)
                    }
                    
                    self.dataChangedClosure?(self.data, isRefresh)
                case .failure:
                    self.message = (title: "Error", description: "Something went wrong!")
                }
            })
        }
    }
    
    func reset() {
        isNoResult = false
        page = 1
        keyword = nil
    }
    
    func refresh() {
        page = 1
        loadData(keyword: keyword, isRefresh: true)
    }
    
    func loadNextPageIfNeeded(row: Int) {
        let triggerRow = data.count - 3
        if (row > triggerRow) && !isLoadingMore && !isNoResult {
            page += 1
            loadData(keyword: keyword)
        }
    }
}
