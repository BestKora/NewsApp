//
//  TabedView.swift
//  NewsApp With SwiftUI Framework
//
//  Created by Алексей Воронов on 15.06.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
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
