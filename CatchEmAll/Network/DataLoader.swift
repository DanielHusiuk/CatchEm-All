//
//  DataLoader.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit

protocol DataLoaderProtocol {
    func loadImage(
        from urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) -> URLSessionDataTask?
}

final class DataLoader: DataLoaderProtocol {
    static let shared = DataLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    @discardableResult
    func loadImage(
        from urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) -> URLSessionDataTask? {
        
        if let cachedData = cache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(cachedData)
            }
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard (error as? URLError)?.code != .cancelled else { return }
            
            guard
                let http = response as? HTTPURLResponse,
                200...299 ~= http.statusCode,
                let data = data,
                let image = UIImage(data: data)
                    else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let preparedImage = image.preparingForDisplay() ?? image
            self?.cache.setObject(preparedImage, forKey: urlString as NSString)
            DispatchQueue.main.async {
                completion(preparedImage)
            }
        }
        task.resume()
        return task
    }
}
