//
//  Article.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 17/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import Foundation

struct NewsResponse: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let author: String?
    let urlToImage: String?
    let publishedAt: Date?
    let source: Source
    let url: String?
}

struct SourcesResponse: Codable {
    let status: String
    let sources: [Source]
}

struct Source: Codable,Identifiable {
    let id: String?
    let name: String?
    let description: String?
    let country: String?
    let category: String?
    let url: String?
}
