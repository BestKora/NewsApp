//
//  SourcesViewModel.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 23/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Combine
import Foundation

final class SourcesViewModel: ObservableObject {
    // input
    @Published var searchString: String = ""
    @Published var country: String = "us"
    // output
    @Published var sources = [Source]()
    
    private var validString:  AnyPublisher<String, Never> {
        $searchString
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
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
   
    private var cancellableSet: Set<AnyCancellable> = []
 
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
}

