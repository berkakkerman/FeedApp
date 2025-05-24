//
//  ImageLoader.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private var tasks: [UIImageView: URLSessionDataTask] = [:]

    func load(url: URL, into imageView: UIImageView) {
        tasks[imageView]?.cancel()
        imageView.image = nil

        if let img = cache.object(forKey: url as NSURL) {
            imageView.image = img
            tasks[imageView] = nil
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let self = self,
                  let imageView = imageView,
                  let data = data,
                  let image = UIImage(data: data)
            else { return }

            self.cache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                imageView.image = image
            }
            self.tasks[imageView] = nil
        }
        tasks[imageView] = task
        task.resume()
    }

    func cancelLoad(for imageView: UIImageView) {
        tasks[imageView]?.cancel()
        tasks[imageView] = nil
    }
}
