//
//  ConfigurableCell.swift
//  FeedApp
//
//  Created by Berk Akkerman on 25.05.2025.
//

import UIKit

protocol ConfigurableCell {
    associatedtype Model
    func configure(with model: Model)
}
