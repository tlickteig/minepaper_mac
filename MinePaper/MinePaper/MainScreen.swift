//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI

struct MainScreen: View {
    let images = returnImagesList()
    
    var body: some View {
        
        /*NavigationView {
            List(images) { image in
                //AsyncImage(url: URL(string: "file://" + image.fullImagePath))
                    //.aspectRatio(contentMode: .fill)
                    //.frame(width: 5)
                Text("Hello World!")
                    .padding(.vertical, 2)
                Spacer()
            }
            .background(Color.blue)
            //.frame(width: 5)
        }
        .background(Color.red)
        .frame(width: 160)
        .listStyle(BorderedListStyle())*/
        
        
    }
    
    static func returnImagesList() -> [WallpaperOption] {
        
        var output = [WallpaperOption]()
        let imageList = try? Utilities.scanImagesDirectory()
        
        if imageList != nil {
            for image in imageList! {
                output.append(WallpaperOption(imageName: image))
            }
        }
        
        return output
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
