//
//  NewPostsHeaderView    .swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import UIKit

final class NewPostsHeaderView: UICollectionReusableView {
    
    private lazy var button = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.isHidden = true
    }

    required init?(coder: NSCoder) { nil }

    func set(target: Any?, action: Selector, title: String, show: Bool) {
        button.isHidden = !show
        button.setTitle(title, for: .normal)
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(target, action: action, for: .touchUpInside)
    }
}
