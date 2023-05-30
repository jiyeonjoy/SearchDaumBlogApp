//
//  BlogListView.swift
//  SearchDaumBlogApp
//
//  Created by 최지연/클라이언트 on 2023/05/30.
//

import UIKit
import RxSwift
import RxCocoa

class BlogListView: UITableView {
    let disposeBag = DisposeBag()
    
    let headerView = FilterView(
        frame: CGRect(
            origin: .zero,
            size: CGSize(width: UIScreen.main.bounds.width, height: 50)
        )
    )
    
    //MainViewController -> BlogListView
    let cellData = PublishSubject<[BlogListCellData]>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        bind()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        cellData
        // bind와 같이 에러나도 에러 방출 안함. 유아이 변경해서 메인스레드에서 일어남. bind와 다른점은 스트림 공유가 가능하다.
        // 비슷한 걸로 signal 이 있는데 driver는 구독전 바로 최신값 받지만 signal은 구독 이후 값만 받는다!!
            .asDriver(onErrorJustReturn: []) // 에러나면 빈배열 받음
            .drive(self.rx.items) { tv, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: "BlogListCell", for: index) as! BlogListCell
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        self.backgroundColor = .white
        self.register(BlogListCell.self, forCellReuseIdentifier: "BlogListCell")
        self.separatorStyle = .singleLine
        self.rowHeight = 100
        self.tableHeaderView = headerView
    }
}
