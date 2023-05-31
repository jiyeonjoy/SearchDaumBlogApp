//
//  BlogListViewModel.swift
//  SearchDaumBlogApp
//
//  Created by Jiyeon Choi on 2023/05/31.
//

import RxSwift
import RxCocoa

struct BlogListViewModel {
    let filterViewModel = FilterViewModel()
    
    let blogListCellData = PublishSubject<[BlogListCellData]>()
    //MainViewController -> BlogListView
    let cellData: Driver<[BlogListCellData]>
    
    init() {
        self.cellData = blogListCellData
            .asDriver(onErrorJustReturn: [])
    }
}
