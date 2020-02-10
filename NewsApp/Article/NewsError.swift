//
//  MovieStoreAPIError.swift
//  CombineFetchAPI
//
//

import Foundation

enum NewsError: Error, LocalizedError, Identifiable {
    var id: String { localizedDescription }
    case urlError(URLError)
    case responseError((Int, String))
    case decodingError(DecodingError)
    case genericError
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
            
        case .responseError(let status, let message):
            let range = (message.range(of: "message\":")?.upperBound
                     ?? message.startIndex)..<message.endIndex
            return "Bad response code: \(status) message : \(message[range])"
            
        case .decodingError(let error):
            var errorToReport = error.localizedDescription
            switch error {
            case .dataCorrupted(let context):
                let details = context.underlyingError?.localizedDescription
                           ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) - (\(details))"
            case .keyNotFound(let key, let context):
                let details = context.underlyingError?.localizedDescription
                           ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
            case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                let details = context.underlyingError?.localizedDescription
                           ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
            @unknown default:
                break
            }
            return  errorToReport
       
        case .genericError:
            return "An unknown error has been occured"
        }
    }
}

