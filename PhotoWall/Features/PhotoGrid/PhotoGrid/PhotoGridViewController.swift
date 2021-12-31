import UIKit
import SnapKit
import Kingfisher

class PhotoGridViewController: UIViewController {
    let viewModel: PhotoGridViewModel
    let footerHeight: CGFloat = 40
    
    lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "End"
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        return label
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
    
    init(viewModel: PhotoGridViewModel = PhotoGridViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsCancelButton = true
        setupUI()
        bindViewModel()
        viewModel.loadData()
    }
    
    func bindViewModel() {
        viewModel.dataChangedClosure = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        viewModel.isLoadingClosure = { [weak self] isLoading in
            if isLoading {
                self?.indicatorView.startAnimating()
            } else {
                self?.indicatorView.stopAnimating()
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.isNoResultClosure = { [weak self] result in
            if result {
                self?.noResultLabel.isHidden = false
            } else {
                self?.noResultLabel.isHidden = true
            }
        }
    }
}

// MARK: - SetUp UI
extension PhotoGridViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.titleView = searchBar
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }
    
    @objc func refresh() {
        viewModel.refresh()
    }
}

// MARK: - Delegate
extension PhotoGridViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoGridCollectionViewCell.self), for: indexPath) as? PhotoGridCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.data[indexPath.row]
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
        if let url = URL(string: viewModel.data[indexPath.row].urls.small) {
            vc.url = url
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                     withReuseIdentifier: String(describing: UICollectionReusableView.self),
                                                                     for: indexPath)
        
        footer.addSubview(indicatorView)
        footer.addSubview(noResultLabel)
        indicatorView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: footerHeight)
        noResultLabel.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: footerHeight)
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: footerHeight)
    }
}

extension PhotoGridViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        viewModel.isSearch = false
        viewModel.isNoResult = false
        viewModel.previousKeyword = ""
        viewModel.page = 1
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: true)
        viewModel.loadData(isRefresh: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.isSearch = false
        viewModel.isNoResult = false
        viewModel.page = 1
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: true)
        viewModel.loadData(keyword: searchBar.text, isRefresh: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
