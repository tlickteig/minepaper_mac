//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI

struct MainScreen: View {
    let images = returnImagesList()
    @State var selectedImageName: String? = ""
    
    var body: some View {
        
        NavigationView {
            List(images, selection: $selectedImageName) { image in
                AsyncImage(url: URL(string: "file://" + image.fullImagePath), scale: 10)
                    .padding(1)
            }
            
            Text("\(selectedImageName ?? "N/A")")
        }
        .listStyle(.sidebar)
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
