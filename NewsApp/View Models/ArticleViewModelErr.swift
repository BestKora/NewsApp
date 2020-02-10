//
//  ArticleViewModelErr.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 09/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Combine
import Foundation

final class ArticlesViewModelErr: ObservableObject {
     var newsAPI = NewsAPI.shared
    // input
    @Published var indexEndpoint: Int = 0
    @Published var searchString: String = "sports"
    // output
    @Published var articles = [Article]()
    @Published var articlesError: NewsError?
    
    private var validString:  AnyPublisher<String, Never> {
        $searchString
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    init(index:Int = 0, text: String = "sports") {
        self.indexEndpoint = index
        self.searchString = text
        
        Publishers.CombineLatest( $indexEndpoint, validString)
        .setFailureType(to: NewsError.self)
        .flatMap {  (indexEndpoint, search) ->
                               AnyPublisher<[Article], NewsError> in
            if 2...10 ~= search.count {
            self.articles = [Article]()
            return self.newsAPI.fetchArticlesErr(from:
                    Endpoint( index: indexEndpoint, text: search)!)
            } else {
                return Just([Article]())
                    .setFailureType(to: NewsError.self)
                    .eraseToAnyPublisher()
            }
        }
        .sink(
            receiveCompletion:  {[unowned self] (completion) in
            if case let .failure(error) = completion {
                self.articlesError = error
            }},
              receiveValue: { [unowned self] in
                self.articles = $0
        })
        .store(in: &self.cancellableSet)
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
}

   

