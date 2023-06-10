//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI
import Wallpaper

struct MainScreen: View {
    
    let images = returnImagesList()
    var body: some View {
        
        VStack {
            NavigationView {
                List(images) { image in
                    NavigationLink(destination: WallpaperSelectedScreen(selectedImage: image)) {
                        ZStack {
                            HStack(alignment: .center) {
                                AsyncImage(url: URL(string: "file://" + image.fullImagePath), scale: 15)
                                    .padding(1)
                                    .cornerRadius(10)
                                    .aspectRatio(contentMode: .fill)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 1)
                            .padding(.top, 1)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            
            Spacer()
            HStack {
                Text("Hello World!")
            }
            Spacer()
        }
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

struct WallpaperSelectedScreen: View {
    
    private var image: WallpaperOption
    private var screens: [String]
    
    @State private var selectedDisplay: String
    
    init(selectedImage: WallpaperOption) {
        image = selectedImage
        selectedDisplay = ""
        screens = [String]()
        
        var index: Int = 0
        for (_) in Wallpaper.screenNames {
            index += 1
            screens.append("Screen \(index)")
        }
        
        if screens.count > 0 {
            selectedDisplay = screens[0]
        }
    }
    
    var body: some View {
        
        VStack {
            Picker(selection: $selectedDisplay, label: Text("Select Display: ")) {
                ForEach(screens, id: \.self) { screen in
                    Text(screen)
                }
            }
            AsyncImage(url: URL(string: "file://" + image.fullImagePath), scale: 3)
                .padding(1)
                .cornerRadius(10)
                .aspectRatio(contentMode: .fill)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
