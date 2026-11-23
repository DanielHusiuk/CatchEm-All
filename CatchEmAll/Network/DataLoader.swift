//
//  DataLoader.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit

protocol DataLoaderProtocol {
    func loadImage(from urlString: String) async -> UIImage?
}

final class DataLoader: DataLoaderProtocol {
    static let shared = DataLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func loadImage(from urlString: String) async -> UIImage? {
        guard !Task.isCancelled else { return nil }
        
        let key = urlString as NSString
        if let cachedData = cache.object(forKey: key) {
            return cachedData
        }
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard !Task.isCancelled,
                  let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  let image = UIImage(data: data) else {
                return nil
            }
            
            let preparedImage = image.preparingForDisplay() ?? image
            guard !Task.isCancelled else { return nil }
            
            cache.setObject(preparedImage, forKey: key)
            return preparedImage
        } catch {
            return nil
        }
    }
    
}
