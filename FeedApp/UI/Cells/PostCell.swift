//
//  PostCell.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import UIKit
import SnapKit

final class PostCell: UICollectionViewCell, ConfigurableCell {
    
    typealias Model = Post

    private lazy var imageView = UIImageView()
    private lazy var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        prepare()
    }

    func configure(with model: Model) {
        configureLabel(with: model.title)
        configureImageView(with: model.imageUrl)
    }
}

// MARK: - Configuration
extension PostCell {
    
    func configureLabel(with title: String?) {
        guard let title else { return }
        label.text = title
    }
    
    func configureImageView(with imageUrl: String?) {
        guard let urlString = imageUrl, let url = URL(string: urlString) else { return }
        ImageLoader.shared.load(url: url, into: imageView)
    }
    
    private func prepare() {
        ImageLoader.shared.cancelLoad(for: imageView)
        imageView.image = nil
        label.text = nil
    }
}

// MARK: - Setup
private extension PostCell {
    
    func setupUI() {
        setupContentView()
        setupImageView()
        setupLabel()
    }
    
    func setupContentView() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    func setupLabel() {
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }

    }
}
