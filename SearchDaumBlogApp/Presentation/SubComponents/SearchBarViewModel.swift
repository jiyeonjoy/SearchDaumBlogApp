//
//  SearchBarViewModel.swift
//  SearchDaumBlogApp
//
//  Created by Jiyeon Choi on 2023/05/31.
//

import RxSwift
import RxCocoa

struct SearchBarViewMode {
    let queryText = PublishRelay<String?>()
    // SearchBar 내부의 이벤트
    let searchButtonTapped = PublishRelay<Void>() // onNext만 있음 onError 불필요!!
    
    // SearchBar 외부로 내보낼 이벤트
    let shouldLoadResult: Observable<String>

    init() {
        self.shouldLoadResult = searchButtonTapped
            .withLatestFrom(queryText) { $1 ?? "" } // 가장 최근의 값이 보내진다.
            .filter { !$0.isEmpty }
            .distinctUntilChanged() // 한번 보내지고 나서 중복으로 보내지 않는다.
    }
}
