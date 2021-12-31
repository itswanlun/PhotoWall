import Foundation

class PhotoGridViewModel {
    let apiService: APIServiceProtocol
    let perPageCount = 30
    
    var page: Int = 1
    var previousKeyword = ""
    var isSearch: Bool = false
    var data: [PhotoItem] = [] {
        didSet {
            dataChangedClosure?(data)
        }
    }
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
    
    // MARK: - Closures
    var dataChangedClosure: (([PhotoItem]) -> Void)?
    var isLoadingClosure: ((Bool) -> Void)?
    var isNoResultClosure: ((Bool) -> Void)?
    
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
                    if isRefresh || self.previousKeyword == "" || self.previousKeyword != keyword {
                        self.data = photos
                    } else if photos.isEmpty {
                        self.isNoResult = true
                    } else {
                        self.data.append(contentsOf: photos)
                    }
                    
                    self.previousKeyword = keyword
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
        } else {
            apiService.getRandomPhoto(page: page, perPage: perPageCount, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                self.isLoadingMore = false
                
                switch result {
                case .success(let photos):
                    if isRefresh {
                        self.data = photos
                    } else if photos.isEmpty {
                        self.isNoResult = true
                    } else {
                        self.data.append(contentsOf: photos)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
        }
    }
    
    func refresh() {
        page = 1
        if previousKeyword == "" {
            loadData(isRefresh: true)
        } else {
            loadData(keyword: previousKeyword)
        }
    }
    
    func loadNextPageIfNeeded(row: Int) {
        let triggerRow = data.count - 3
        if (row > triggerRow) && !isLoadingMore && !isNoResult {
            page += 1
            if previousKeyword == "" {
                loadData()
            } else {
                loadData(keyword: previousKeyword)
            }
        }
    }
}
