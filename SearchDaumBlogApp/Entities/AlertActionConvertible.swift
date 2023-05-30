//
//  AlertActionConvertible.swift
//  SearchDaumBlogApp
//
//  Created by 최지연/클라이언트 on 2023/05/30.
//

import UIKit

protocol AlertActionConvertible {
    var title: String { get }
    var style: UIAlertAction.Style { get }
}
