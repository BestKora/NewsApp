//
//  MovieRepository.swift
//  MovieKit
//
//  Created by Alfian Losari on 11/24/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation
import Combine

struct APIConstants {
    // News  API key url: https://newsapi.org
    static let apiKey: String = "dad56f872c6e425f8992c93c87060824"//"API_KEY"
    
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

enum Endpoint {
    case topHeadLines
    case articlesFromCategory(_ category: String)
    case articlesFromSource(_ source: String)
    case search (searchFilter: String)
    case sources (country: String)
    
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
        case .sources (let country):
            urlComponents.queryItems = [URLQueryItem(name: "country", value: country),
                                        URLQueryItem(name: "language", value: countryLang[country]),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .articlesFromSource (let source):
            urlComponents.queryItems = [URLQueryItem(name: "sources", value: source),
                                      /*  URLQueryItem(name: "language", value: locale),*/
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .search (let searchFilter):
            urlComponents.queryItems = [URLQueryItem(name: "q", value: searchFilter.lowercased()),
                                       /*URLQueryItem(name: "language", value: locale),*/
                                       /* URLQueryItem(name: "country", value: region),*/
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                      ]
        }
        return urlComponents.url
    }
    
    var locale: String {
        return  Locale.current.languageCode ?? "en"
    }
    
    var region: String {
        return  Locale.current.regionCode?.lowercased() ?? "us"
    }
    
    init? (index: Int, text: String = "sports") {
        switch index {
        case 0: self = .topHeadLines
        case 1: self = .search(searchFilter: text)
        case 2: self = .articlesFromCategory(text)
        case 3: self = .articlesFromSource(text)
        case 4: self = .sources (country: text)
        default: return nil
        }
    }
    
    var countryLang : [String: String]  {return [
      "ar": "es",  // argentina
      "au": "en",  // australia
      "br": "es",  // brazil
      "ca": "en",  // canada
      "cn": "cn",  // china
      "de": "de",  // germany
      "es": "es",  // spain
      "fr": "fr",  // france
      "gb": "en",  // unitedKingdom
      "hk": "cn",  // hongKong
      "ie": "en",  // ireland
      "in": "en",  // india
      "is": "en",  // iceland
      "il": "he",  // israil for sources - language
      "it": "it",  // italy
      "nl": "nl",  // netherlands
      "no": "no",  // norway
      "ru": "ru",  // russia
      "sa": "ar",  // saudiArabia
      "us": "en",  // unitedStates
      "za": "en"   // southAfrica
      ]
    }
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
    
    // Асинхронная выборка на основе URL с сообщениями об ошибках
    func fetchErr<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
               URLSession.shared.dataTaskPublisher(for: url)             // 1
               .tryMap { (data, response) -> Data in                     // 2
                   guard let httpResponse = response as? HTTPURLResponse,
                        200...299 ~= httpResponse.statusCode else {
                   throw NewsError.responseError(
                        ((response as? HTTPURLResponse)?.statusCode ?? 500,
                            String(data: data, encoding: .utf8) ?? ""))
                        }
                   return data
               }
                .decode(type: T.self, decoder: APIConstants.jsonDecoder)  // 3
                .receive(on: RunLoop.main)                                // 4
                .eraseToAnyPublisher()                                    // 5
    }
    
  // Асинхронная выборка статей
     func fetchArticles(from endpoint: Endpoint)
                                     -> AnyPublisher<[Article], Never> {
         guard let url = endpoint.absoluteURL else {
                     return Just([Article]()).eraseToAnyPublisher() // 0
         }
         return fetch(url)                                          // 1
             .map { (response: NewsResponse) -> [Article] in        // 2
                             return response.articles }
                .replaceError(with: [Article]())                    // 3
                .eraseToAnyPublisher()                              // 4
     }
    
    // Асинхронная выборка источников информации
    func fetchSources(for country: String)
                                       -> AnyPublisher<[Source], Never> {
        guard let url = Endpoint.sources(country: country).absoluteURL
            else {
                    return Just([Source]()).eraseToAnyPublisher() // 0
        }
        return fetch(url)                                         // 1
            .map { (response: SourcesResponse) -> [Source] in     // 2
                            response.sources }
               .replaceError(with: [Source]())                    // 3
               .eraseToAnyPublisher()                             // 4
    }
    
    
     // Асинхронная  выборка статей  с сообщением об ошибке
       func fetchArticlesErr(from endpoint: Endpoint) ->
                                           AnyPublisher<[Article], NewsError>{
           Future<[Article], NewsError> { [unowned self] promise in
    
               guard let url = endpoint.absoluteURL  else {
                   return promise(
                       .failure(.urlError(URLError(.unsupportedURL))))     // 0
               }
               self.fetchErr(url)                                          // 1
                 .tryMap { (result: NewsResponse) -> [Article] in          // 2
                         result.articles }
                  .sink(
                   receiveCompletion: { (completion) in                     // 3
                       if case let .failure(error) = completion {
                           switch error {
                           case let urlError as URLError:
                               promise(.failure(.urlError(urlError)))
                           case let decodingError as DecodingError:
                               promise(.failure(.decodingError(decodingError)))
                           case let apiError as NewsError:
                               promise(.failure(apiError))
                           default:
                               promise(.failure(.genericError))
                           }
                       }
                   },
                   receiveValue: { promise(.success($0)) })                  // 4
                .store(in: &self.subscriptions)                              // 5
           }
           .eraseToAnyPublisher()                                            // 6
       }
    
    // Асинхронная выборка источников  с сообщением об ошибке
    func fetchSourcesErr(for country: String) ->
                                        AnyPublisher<[Source], NewsError>{
        Future<[Source], NewsError> { [unowned self] promise in
            guard let url = Endpoint.sources(country: country).absoluteURL  else {
                return promise(
                    .failure(.urlError(URLError(.unsupportedURL))))           // 0
            }
            self.fetchErr(url)                                                // 1
              .tryMap { (result: SourcesResponse) -> [Source] in              // 2
                      result.sources }
               .sink(
                receiveCompletion: { (completion) in                          // 3
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as NewsError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.genericError))
                        }
                    }
                },
                receiveValue: { promise(.success($0)) })                     // 4
             .store(in: &self.subscriptions)                                 // 5
        }
        .eraseToAnyPublisher()                                               // 6
    }
    
       private var subscriptions = Set<AnyCancellable>()
    
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
     /*
      // Выборка статей с ошибкой без Generic "издателя"
           func fetchArticlesErr(from endpoint: Endpoint) ->
                                               AnyPublisher<[Article], NewsError>{
               return Future<[Article], NewsError> { [unowned self] promise in
                   guard let url = endpoint.absoluteURL  else {
                       return promise(.failure(.urlError(                          // 0
                                                    URLError(.unsupportedURL))))
                   }
                   
                    URLSession.shared.dataTaskPublisher(for: url)                  // 1
                       .tryMap { (data, response) -> Data in                       // 2
                           guard let httpResponse = response as? HTTPURLResponse,
                                200...299 ~= httpResponse.statusCode else {
                           throw NewsError.responseError(
                                ((response as? HTTPURLResponse)?.statusCode ?? 500,
                                    String(data: data, encoding: .utf8) ?? ""))
                                }
                           return data
                       }
                    .decode(type: NewsResponse.self,
                                                  decoder: APIConstants.jsonDecoder) // 3
                    .receive(on: RunLoop.main)                                       // 4
                      .sink(
                       receiveCompletion: { (completion) in                          // 5
                           if case let .failure(error) = completion {
                               switch error {
                               case let urlError as URLError:
                                   promise(.failure(.urlError(urlError)))
                               case let decodingError as DecodingError:
                                   promise(.failure(.decodingError(decodingError)))
                               case let apiError as NewsError:
                                   promise(.failure(apiError))
                               default:
                                   promise(.failure(.genericError))
                               }
                           }
                      },
                      receiveValue: { promise(.success($0.articles)) })             // 6
                    .store(in: &self.subscriptions)                                 // 7
               }
               .eraseToAnyPublisher()                                               // 8
           }
     */
 
    //"17dee2eb8eee461584226aceece35139"
    // "b054d201bf7c4ba8976e3b2ec44686ce"
    //"a7d312d111564be8af66634a50ba3e24"
    //"8e58842e74f2453bb5e6e3845b386a81"
    //"db358b36376b40528bac16f119610dd9"
    //"78373fa588974c0382c031230e906169"
    //"1a1c707884f343f6a5d1b2653eecb8d9"
    //"654f479b4cb34f4ea18db7eda6437ec2"
}
