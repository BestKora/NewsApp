//
//  ImageData.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 09/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import UIKit
import Combine

 //---------------
class ImageLoaderCache {
    static let shared = ImageLoaderCache()
    var loaders: NSCache<NSString, ImageLoader> = NSCache()
    
    func loaderFor(article: Article) -> ImageLoader {
        let key = NSString(string: "\(article.title)")
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let url = (article.urlToImage != nil && article.urlToImage != "null")
                ? URL(string: article.urlToImage!)
                : nil
            let loader = ImageLoader (url: url)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
}

final class ImageLoader: ObservableObject {
    // input
    @Published var url: URL?
    // output
    @Published var image: UIImage?
    @Published var noData = false
    
    // Init with Error
    init(url: URL?) {
        self.url = url
        $url
        .setFailureType(to: Error.self)
        .flatMap { (url) -> AnyPublisher<UIImage?, Error> in
                self.fetchImageErr(for: url).eraseToAnyPublisher()
        }
        .sink(receiveCompletion:  {[unowned self] (completion) in
            if case .failure(_) = completion {
                self.noData = true
            }},
              receiveValue: { [unowned self] in
                self.image = $0
        })
        .store(in: &self.cancellableSet)
    }

   // выборка изображения UIImage? с учетом ошибок
    func fetchImageErr(for  url: URL?) -> AnyPublisher<UIImage?, Error>{
        Future<UIImage?, Error> { [unowned self] promise in
    
            guard let url = url, !self.noData  else {           // 0
                return promise(
                    .failure(URLError(.unsupportedURL)))
            }
            URLSession.shared.dataTaskPublisher(for: url)      // 1
                .tryMap { (data, response) -> Data in          // 2
                    guard let httpResponse = response as? HTTPURLResponse,
                        200...299 ~= httpResponse.statusCode else {
                            throw URLError(.unsupportedURL)
                    }
                    return data
            }
                .map { UIImage(data: $0) }                     // 3
                .receive(on: RunLoop.main)                     // 4
                .sink(
                    receiveCompletion: { (completion) in       // 5
                        if case let .failure(error) = completion {
                            promise(.failure(error))
                        }
                },
                    receiveValue: { promise(.success($0)) })    // 6
                .store(in: &self.cancellableSet)                // 7
        }
            .eraseToAnyPublisher()                              // 8
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    deinit {
           for cancell in cancellableSet {
               cancell.cancel()
           }
    }
     
   
    /*
        // Init Light
        init(url: URL?) {
                 self.url = url
                 $url
                 .flatMap { (url) -> AnyPublisher<UIImage?, Never> in
                                             self.fetchImage(for: url)
                 }
                 .assign(to: \.image, on: self)
                 .store(in: &self.cancellableSet)
             }

            private func fetchImage(for url: URL?) -> AnyPublisher<UIImage?, Never> {
              guard url != nil/*, image == nil */else {
                  return Just(nil).eraseToAnyPublisher()            // 1
              }
              return
                  URLSession.shared.dataTaskPublisher(for: url!)    // 2
                  .map { UIImage(data: $0.data) }                   // 3
                  .replaceError(with: nil)                          // 4
                  .receive(on: RunLoop.main)                        // 5
                  .eraseToAnyPublisher()                            // 6
          }
    */
}
