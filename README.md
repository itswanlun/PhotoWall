# PhotoWall

照片牆是我常使用APP中最常見的一種形式，像是 Instagram、Pinterest，照片牆給人很療癒且會不自覺的一直往下滑動新內容，因此，透過免費的[Unsplash: Beautiful Free Images & Pictures](https://unsplash.com/)且提供漂亮的圖片 API 來實作

## 設計方向

1. 載入時會呈現 random 圖片資訊
2. 在 searchbar 搜尋關鍵字，呈現關鍵字搜尋回來的圖片，點選 cancel 回到初始呈現 random 照片
3. 點選照片，進入細節頁查看圖片
4. Infinite scroll 捲軸瀏覽至底載入新資料，直到 API 沒有資料
5. Pull-to-refresh下拉更新圖片

## 使用技術

在這個作品裡我想練習的部分有以下：
1. UIKit programmatically
2. 資料來源：[https://unsplash.com/developers](https://unsplash.com/developers)
4. 使用 MVVM 架構
5. 使用 CocoaPods 管理 third-party
6. 使用 third-party
    * [SnapKit](https://github.com/SnapKit/SnapKit)(auto layout)   
    * [Kingfisher](https://github.com/onevcat/Kingfisher)(cache image)
    * [Alamofire](https://github.com/Alamofire/Alamofire)(network layer)

## 如何使用

方法一、申請unsplash Developers 取得API accessKey & secretKey 
https://unsplash.com/developers
```swift
let apiKey = UnsplashApiKey(accessKey: "Access Key", secretKey: "secret Key")

```

方法二、使用FakeAPIService
至SceneDelegate.swift
```swift
let viewModel = PhotoGridViewModel(apiService: FakeAPIService.shared)
```
