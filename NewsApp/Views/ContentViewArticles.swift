//
//  ContentView1.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 11/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentViewArticles: View {
    @ObservedObject var articlesViewModel = ArticlesViewModelErr ()
    
    var body: some View {
        VStack {
            Picker("", selection: $articlesViewModel.indexEndpoint){
                Text("topHeadLines").tag(0)
                Text("search").tag(1)
                Text("from category").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            if articlesViewModel.indexEndpoint == 1 {
               SearchView(searchTerm: $articlesViewModel.searchString)
            }
            if articlesViewModel.indexEndpoint == 2 {
                       Picker("", selection: $articlesViewModel.searchString){
                           Text("sports").tag("sports")
                           Text("health").tag("health")
                           Text("science").tag("science")
                           Text("business").tag("business")
                           Text("technology").tag("technology")
                       }
                       .onAppear(perform: {
                         self.articlesViewModel.searchString = "science"
                       })
                       .pickerStyle(SegmentedPickerStyle())
            }
               ArticlesList(articles: articlesViewModel.articles)
        } // VStack
        .alert(item: self.$articlesViewModel.articlesError) { error in
                    Alert(
                       title: Text("Network error"),
                       message: Text(error.localizedDescription).font(.subheadline),
                       dismissButton: .default(Text("OK"))
                     )
        } // alert
    } // body
}

struct ContentViewArticles_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewArticles()
    }
}
