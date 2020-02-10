//
//  SourcesViewModelErr.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 09/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Combine
import Foundation

final class SourcesViewModelErr: ObservableObject {
     var newsAPI = NewsAPI.shared
    // input
    @Published var searchString: String = ""
    @Published var country: String = "us"
    // output
    @Published var sources = [Source]()
    @Published var sourcesError: NewsError?
    
    private var validString:  AnyPublisher<String, Never> {
        $searchString
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    init() {
          Publishers.CombineLatest( $country,  validString)
          .setFailureType(to: NewsError.self)
          .flatMap {  (country, search) ->
                                 AnyPublisher<[Source], NewsError> in
              return self.newsAPI.fetchSourcesErr(for: country)
             .map{search == "" ? $0 : $0.filter {
                    ($0.name?.lowercased().contains(search.lowercased()))!}}
            .eraseToAnyPublisher()
          }
          .sink(
              receiveCompletion:  {[unowned self] (completion) in
              if case let .failure(error) = completion {
                  self.sourcesError = error
              }},
                receiveValue: { [unowned self] in
                  self.sources = $0
          })
          .store(in: &self.cancellableSet)
      }
 /*
    init() {
        Publishers.CombineLatest( $country,  validString)
        .flatMap { (country,search) -> AnyPublisher<[Source], Never> in
            NewsAPI.shared.fetchSources(for: country)
            .map{search == "" ? $0 : $0.filter {
                    ($0.name?.lowercased().contains(search.lowercased()))!}}
            .eraseToAnyPublisher()
         }
        .assign(to: \.sources, on: self)
        .store(in: &self.cancellableSet)
    }
*/
    private var cancellableSet: Set<AnyCancellable> = []
 
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
}

