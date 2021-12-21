//
//  ViewController.swift
//  PhotoWall
//
//  Created by Wan-lun Zheng on 2021/12/17.
//

import UIKit
import SnapKit

class PhotoGridViewController: UIViewController {
    var data: [PhotoItem] = []
    var isSearch: Bool = false
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = UISearchBar.Style.default
        search.placeholder = "Plase Enter Keyword"
        search.delegate = self
        //search.backgroundColor = .gray
        
        return search
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoGridCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PhotoGridCollectionViewCell.self))
        
        return collectionView
    }()
    
    lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func loadData(keyword: String? = nil) {
        if let keyword = keyword {
            APIService.shared.getSearchPhoto(page: 1, perPage: 5, keyword: keyword, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let photos):
                    
                    self.data = photos
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
        } else {
            APIService.shared.getRandomPhoto(page: 1, perPage: 5, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let photos):
                    self.data = photos
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
        }

    }
    
    //    @objc func handleShoeSearchBar() {
    //        print("Show search Bar")
    //    }
    
    
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
            cell.photoImageView.setImage(url: url)
        }
        //cell.photoImageView.image = UIImage(named: "isabela-kronemberger-fXrpmxzyi2g-unsplash")
        
        //cell.backgroundColor = .blue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let columns: CGFloat = 4
        let space: CGFloat = flowayout.sectionInset.left + flowayout.sectionInset.right + (flowayout.minimumInteritemSpacing * (columns - 1))
        let width: CGFloat = (collectionView.frame.size.width - space) / columns
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let vc = DetailViewController()
        //        let nc = UINavigationController(rootViewController: vc)
        //
        //        present(nc, animated: true, completion: nil)
        
        let vc = PhotoDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        if let url = URL(string: data[indexPath.row].urls.small) {
            vc.url = url
        }
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
        isSearch = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false
        print(searchBar.text)
        loadData(keyword: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
