//
//  ContentViewSources.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 23/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentViewSources: View {
    @ObservedObject var sourcesViewModel = SourcesViewModel ()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchView(searchTerm: self.$sourcesViewModel.searchString)
                SourcesList(sources: sourcesViewModel.sources)
            }// VStack
        } // Navigation
    } // body
}

struct ContentViewSources_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewSources()
    }
}
