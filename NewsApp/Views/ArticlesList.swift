//
//  ArticlesList.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 23/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ArticlesList: View {
    var articles: [Article]
    var body: some View {
        List {
           ForEach(articles) { article in
                   VStack {
                       Text("\(article.title)").font(.title)
                       Spacer()
                       HStack {
                       Text("\( article.source.name != nil ? article.source.name! : "")")
                           Spacer()
                        Text(APIConstants.formatter.string(from: article.publishedAt!))
                       }
                       .foregroundColor(Color.blue)
                       ArticleImage(imageLoader: ImageLoaderCache.shared.loaderFor(
                           article: article))
                   
                       Text("\( article.description != nil ? article.description! : "")")
                           .lineLimit(12)
                       Divider()
                   } //VStack
           } // foreach
       } // list
    }
}

let calendar = Calendar.current
let components1 = DateComponents(calendar: calendar, year: 2020, month: 1, day: 23)
let sampleArticle1 = Article (title: "Emoji reactions are sliding into Twitter’s DMs - The Verge", description: "Twitter’s direct messages now support emoji reactions. To use them, you can either tap the small “heart and plus icon” that appears to the right of messages you receive, or double tap a message on mobile.", author: "Jon Porter", urlToImage: "https://cdn.vox-cdn.com/thumbor/--0kTTyAQnE5e8LMunWwCIl-wEw=/0x173:2040x1241/fit-in/1200x630/cdn.vox-cdn.com/uploads/chorus_asset/file/10456871/mdoying_180117_2249_twitter_0303stills.jpg", publishedAt: calendar.date(from: components1)!, source: Source(id: "the-verge", name: "the-verge", description: "", country: "us", category: "general", url: "https://cdn.vox-cdn.com") )
struct ArticlesList_Previews: PreviewProvider {
    static var previews: some View {
        ArticlesList(articles: [sampleArticle1])
    }
}
