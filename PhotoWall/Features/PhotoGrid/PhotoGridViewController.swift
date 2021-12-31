import UIKit
import SnapKit
import Kingfisher

class PhotoGridViewController: UIViewController {
    let apiService: APIServiceProtocol
    let footerHeight: CGFloat = 40
    let perPageCount = 30
    var page: Int = 1
    var previousKeyword = ""
    var isNoResult = false
    
    var isLoadingMore: Bool = false {
        didSet {
            if isLoadingMore {
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
            }
        }
    }
    
    var data: [PhotoItem] = []
    var isSearch: Bool = false
    
    lazy var noResult: UILabel = {
        let noResult = UILabel()
        return noResult
    }()
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = UISearchBar.Style.default
        search.placeholder = "Please enter keyword"
        search.delegate = self
        
        return search
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoGridCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PhotoGridCollectionViewCell.self))
        collectionView.refreshControl = refreshControl
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: String(describing: UICollectionReusableView.self))
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        return layout
    }()
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsCancelButton = true
        setupUI()
        loadData()
    }
}

// MARK: - SetUp UI
extension PhotoGridViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.titleView = searchBar
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target:self, action: #selector(handleShoeSearchBar))
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }
    
    private func loadData(keyword: String? = nil, isRefresh: Bool = false) {
        isLoadingMore = true
        if let keyword = keyword {
            apiService.getSearchPhoto(page: page, perPage: perPageCount, keyword: keyword, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                self.isLoadingMore = false
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let photos):
                    if isRefresh || self.previousKeyword == "" || self.previousKeyword != keyword {
                        self.data = photos
                    } else if photos.isEmpty {
                        self.noResult.isHidden = false
                        self.isNoResult = true
                        return
                    } else {
                        self.data.append(contentsOf: photos)
                    }
                    
                    self.previousKeyword = keyword
                    
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
        } else {
            apiService.getRandomPhoto(page: page, perPage: perPageCount, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                self.isLoadingMore = false
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let photos):
                    if isRefresh {
                        self.data = photos
                    } else if photos.isEmpty {
                        self.noResult.isHidden = false
                        self.isNoResult = true
                        return
                    } else {
                        self.data.append(contentsOf: photos)
                    }
                    
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
        }

    }
    
    @objc func refresh() {
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

// MARK: - Delegate
extension PhotoGridViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoGridCollectionViewCell.self), for: indexPath) as? PhotoGridCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = data[indexPath.row]
        if let url = URL(string: item.urls.small) {
            cell.photoImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let columns: CGFloat = 3
        let space: CGFloat = flowayout.sectionInset.left + flowayout.sectionInset.right + (flowayout.minimumInteritemSpacing * (columns - 1))
        let width: CGFloat = (collectionView.frame.size.width - space) / columns
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        if let url = URL(string: data[indexPath.row].urls.small) {
            vc.url = url
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                     withReuseIdentifier: String(describing: UICollectionReusableView.self),
                                                                     for: indexPath)
        
        footer.addSubview(indicatorView)
        footer.addSubview(noResult)
        indicatorView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: footerHeight)
        noResult.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: footerHeight)
        noResult.text = "End"
        noResult.textColor = .gray
        noResult.textAlignment = .center
        noResult.isHidden = true
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadNextPageIfNeeded(row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: footerHeight)
    }
}

extension PhotoGridViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        isSearch = false
        isNoResult = false
        previousKeyword = ""
        page = 1
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                    animated: true)
        loadData(isRefresh: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false
        isNoResult = false
        page = 1
        //let topOffest = CGPoint(x: 0, y: -(collectionView.contentInset.top ?? 0))
        //collectionView.setContentOffset(topOffest, animated: true)
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                    animated: true)
        loadData(keyword: searchBar.text, isRefresh: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
