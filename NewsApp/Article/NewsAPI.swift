//
//  MovieRepository.swift
//  MovieKit
//
//  Created by Alfian Losari on 11/24/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation
import Combine

enum Endpoint {
    case topHeadLines, sources
    case articlesFromCategory(_ category: String)
    case articlesFromSource(_ source: String)
    case search (searchFilter: String)
   
    
    var baseURL:URL {URL(string: "https://newsapi.org/v2/")!}
    
    func path() -> String {
        switch self {
        case .topHeadLines, .articlesFromCategory:
            return "top-headlines"
        case .search,.articlesFromSource:
            return "everything"
        case .sources:
            return "sources"
        }
    }
    
    var absoluteURL: URL? {
        let queryURL = baseURL.appendingPathComponent(self.path())
        let components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)
        guard var urlComponents = components else {
            return nil
        }
        switch self {
        case .topHeadLines:
            urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .articlesFromCategory(let category):
                       urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                                   URLQueryItem(name: "category", value: category),
                                                   URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                                  ]
        case .sources:
            urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "language", value: locale),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .articlesFromSource(let source):
            urlComponents.queryItems = [URLQueryItem(name: "sources", value: source),
                                        URLQueryItem(name: "language", value: locale),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .search (let searchFilter):
            urlComponents.queryItems = [URLQueryItem(name: "q", value: searchFilter),
                                        URLQueryItem(name: "language", value: locale),
                                        URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                      ]
        }
        return urlComponents.url
    }
    
    var locale: String {
        return  Locale.current.languageCode ?? "en"
    }
    
    var region: String {
        return  Locale.current.regionCode ?? "us"
    }
    
    init? (index: Int, text: String = "sports") {
        switch index {
        case 0: self = .topHeadLines
        case 1: self = .search(searchFilter: text)
        case 2: self = .articlesFromCategory(text)
        case 3: self = .articlesFromSource(text)
        case 4: self = .sources
        default: return nil
        }
    }
}

struct APIConstants {
    /// News  API key url: https://newsapi.org
    static let apiKey: String = "654f479b4cb34f4ea18db7eda6437ec2" //"API_KEY"
    
    static let jsonDecoder: JSONDecoder = {
     let jsonDecoder = JSONDecoder()
     jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
     jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
      return jsonDecoder
    }()
    
     static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

class NewsAPI {
    static let shared = NewsAPI()
    
    // Асинхронная выборка на основе URL
     func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
                   URLSession.shared.dataTaskPublisher(for: url)             // 1
                    .map { $0.data}                                          // 2
                    .decode(type: T.self, decoder: APIConstants.jsonDecoder) // 3
                    .receive(on: RunLoop.main)                               // 4
                    .eraseToAnyPublisher()                                   // 5
    }
    
  // Выборка статей
     func fetchArticles(from endpoint: Endpoint)
                                     -> AnyPublisher<[Article], Never> {
         guard let url = endpoint.absoluteURL else {
                     return Just([Article]()).eraseToAnyPublisher() // 0
         }
         return fetch(url)                                          // 1
             .map { (response: NewsResponse) -> [Article] in        // 2
                             response.articles }
                .replaceError(with: [Article]())                    // 3
                .eraseToAnyPublisher()                              // 4
     }
    
    // Выборка источников информации
    func fetchSources() -> AnyPublisher<[Source], Never> {
        guard let url = Endpoint.sources.absoluteURL else {
                    return Just([Source]()).eraseToAnyPublisher() // 0
        }
        return fetch(url)                                         // 1
            .map { (response: SourcesResponse) -> [Source] in     // 2
                            response.sources }
               .replaceError(with: [Source]())                    // 3
               .eraseToAnyPublisher()                             // 4
    }
    
    /*
     // Выборка статей без Generic "издателя"
    func fetchArticles(from endpoint: Endpoint) -> AnyPublisher<[Article], Never> {
        guard let url = endpoint.absoluteURL else {                       // 0
                    return Just([Article]()).eraseToAnyPublisher()
        }
           return
            URLSession.shared.dataTaskPublisher(for:url)                  // 1
            .map{$0.data}                                                 // 2
            .decode(type: NewsResponse.self,                              // 3
                    decoder: APIConstants .jsonDecoder)
            .map{$0.articles}                                             // 4
            .replaceError(with: [])                                       // 5
            .receive(on: RunLoop.main)                                    // 6
            .eraseToAnyPublisher()                                        // 7
    }
    
    // Выборка источников информации  без Generic "издателя"
    func fetchSources() -> AnyPublisher<[Source], Never> {
        guard let url = Endpoint.sources.absoluteURL else {                // 0
                       return Just([Source]()).eraseToAnyPublisher()
           }
              return
               URLSession.shared.dataTaskPublisher(for:url)               // 1
               .map{$0.data}                                              // 2
               .decode(type: SourcesResponse.self,                        // 3
                       decoder: APIConstants .jsonDecoder)
               .map{$0.sources}                                           // 4
               .replaceError(with: [])                                    // 5
               .receive(on: RunLoop.main)                                 // 6
               .eraseToAnyPublisher()                                     // 7
    }
 */
}

