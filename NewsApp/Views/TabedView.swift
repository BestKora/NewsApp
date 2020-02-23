//
//  TabedView.swift
//  NewsApp With SwiftUI Framework
//
//  Created by Tatiana Kornilova on 02/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct TabedView : View {
    var body: some View {
        TabView {
            ContentViewArticles()
                .tabItem {
                    Image (systemName: "doc.on.doc.fill")
                    Text("Articles")
            }
            ContentViewSources()
                .tabItem {
                    Image (systemName: "slider.horizontal.3")
                     Text("Sources")
            }
        }
        .accentColor(.blue)
    }
}

struct TabvedView_Previews: PreviewProvider {
    static var previews: some View {
        TabedView()
    }
}
