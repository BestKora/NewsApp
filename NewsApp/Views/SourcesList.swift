//
//  ArticlesListView.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 23/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct SourcesList: View {
    var sources: [Source]
    
    var body: some View {
        List {
           ForEach(sources) {source in
            NavigationLink ( destination:
            DetailSourceView(source: source,
                             articlesViewModel:
                                 ArticlesViewModel (index: 3, text: source.id!))
                ){
                    VStack {
                        Text("\( source.name != nil ? source.name! : "")")
                        .font(.title)
                        Text("\( source.description != nil ? source.description! : "")")
                        .lineLimit(3)
                    } //VStack
               } // navigationLink
           } // foreach
        } // list
        .navigationBarTitle("Sources")
      } // body
}

let sampleSource1 = Source(id: "abc-news", name: "ABC News", description: "Your trusted source for breaking news, analysis, exclusive interviews, headlines, and videos at ABCNews.com.", country: "us", category: "general", url: "https://abcnews.go.com")

let sampleSource2 = Source(id: "cnbc", name: "CNBC", description:"Get latest business news on stock markets, financial & earnings on CNBC. View world markets streaming charts & video; check stock tickers and quotes." , country: "us", category: "business", url: "http://www.cnbc.com")

struct SourcesList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        SourcesList(sources: [sampleSource1, sampleSource2 ])
        }
    }
}

