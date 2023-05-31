//
//  MainViewModel.swift
//  SearchDaumBlogApp
//
//  Created by Jiyeon Choi on 2023/05/31.
//

import UIKit
import RxSwift
import RxCocoa

struct MainViewModel {
    let disposeBag = DisposeBag()

    let searchBarViewModel = SearchBarViewModel()
    let blogListViewModel = BlogListViewModel()
    
    let alertActionTapped = PublishRelay<MainViewController.AlertAction>()
    let shouldPresentAlert: Signal<MainViewController.Alert>
    
    init() {
        let blogResult = searchBarViewModel.shouldLoadResult
            .flatMapLatest {
                SearchBlogNetwork().searchBlog(query: $0)
            }
            .share()
        
        let blogValue = blogResult
            .map { data -> DKBlog? in
                guard case .success(let value) = data else {
                    return nil
                }
                return value
            }
            .filter { $0 != nil }
        
        let blogError = blogResult
            .map { data -> String? in
                guard case .failure(let error) = data else {
                    return nil
                }
                return error.message
            }
            .filter { $0 != nil }
        
        // 네트워크를 통해 가져온 값을 CellData로 변환
        let cellData = blogValue
            .map { blog -> [BlogListCellData] in
                guard let blog = blog else {
                    return []
                }
                
                return blog.documents
                    .map {
                        let thumbnailURL = URL(string: $0.thumbnail ?? "")
                        return BlogListCellData(
                            thumbnailURL: thumbnailURL,
                            name: $0.name,
                            title: $0.title,
                            datetime: $0.datetime
                        )
                    }
            }
        
        // FilterView를 선택했을 때 나오는 alertsheet를 선택했을 때 type
        let sortedType = alertActionTapped
            .filter {
                switch $0 {
                case .title, .datetime:
                    return true
                default:
                    return false
                }
            }
            .startWith(.title)
        
        // MainViewController -> ListView
        Observable
            .combineLatest( // 두개를 결합해서 모두 최신것을 보여줌.
                sortedType,
                cellData
            ) { type, data -> [BlogListCellData] in
                switch type {
                case .title:
                    return data.sorted { $0.title ?? "" < $1.title ?? "" }
                case .datetime:
                    return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date() }
                case .cancel, .confirm:
                    return data
                }
            }
            .bind(to: blogListViewModel.blogListCellData)
            .disposed(by: disposeBag)
        
        let alertSheetForSorting = blogListViewModel.filterViewModel.sortButtonTapped
            .map { _ -> MainViewController.Alert in
                return (title: nil, message: nil, actions: [.title, .datetime, .cancel], style: .actionSheet)
            }
        
        let alertForErrorMessage = blogError
            .do(onNext: { message in
                print("error: \(message ?? "")")
            })
                .map { _ -> MainViewController.Alert in
                return (
                    title: "앗!",
                    message: "예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
                    actions: [.confirm],
                    style: .alert
                )
            }
        
        self.shouldPresentAlert = Observable
            .merge(
                alertSheetForSorting,
                alertForErrorMessage
            )
            .asSignal(onErrorSignalWith: .empty())
    }
}
