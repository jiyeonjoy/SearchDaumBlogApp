//
//  FilterViewModel.swift
//  SearchDaumBlogApp
//
//  Created by Jiyeon Choi on 2023/05/31.
//

import RxSwift
import RxCocoa

struct FilterViewModel {
    //FilterView 외부에서 관찰
    let sortButtonTapped = PublishRelay<Void>()
    
    init() {
        
    }
}
