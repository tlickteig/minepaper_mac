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
    private var screens: [Int]
    
    @State private var selectedDisplay: Int
    
    init(selectedImage: WallpaperOption) {
        image = selectedImage
        selectedDisplay = 0
        screens = [Int]()
        
        var index: Int = 0
        for (_) in Wallpaper.screenNames {
            screens.append(index)
            index += 1
        }
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Picker(selection: $selectedDisplay, label: Text("Select Display: ")) {
                    ForEach(screens, id: \.self) { screen in
                        Text("Screen \(screen + 1)")
                    }
                }
                .frame(width: 300, alignment: .top)
                .padding(.top, 10)
                Spacer()
            }
            Spacer()
            AsyncImage(url: URL(string: "file://" + image.fullImagePath), scale: 3)
                .padding(1)
                .cornerRadius(10)
                .aspectRatio(contentMode: .fill)
            Spacer()
            Button("Set Wallpaper") {
                
            }
            Spacer()
        }
        .onAppear {
            if screens.count > 0 {
                selectedDisplay = screens[0]
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
