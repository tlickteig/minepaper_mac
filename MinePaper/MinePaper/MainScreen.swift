//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI
import Wallpaper

struct MainScreen: View {
    
    let imageSync = try? Utilities.syncImagesWithServer()
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
                    .frame(width: 135)
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
    private var screens: [NSScreen] = NSScreen.screens
    
    @State private var selectedDisplay: NSScreen
    @State private var imageOpacity: Double
    
    init(selectedImage: WallpaperOption) {
        image = selectedImage
        selectedDisplay = screens[0]
        imageOpacity = 0
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Picker(selection: $selectedDisplay, label: Text("Select Display: ")) {
                    ForEach(screens, id: \.self) { screen in
                        Text(screen.localizedName)
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
                .opacity(imageOpacity)
                .onAppear() {
                    imageOpacity = 100
                }
            Spacer()
            Button("Set Wallpaper") {
                
                let fullImagePath = "file://" + image.fullImagePath
                var screensTemp = [NSScreen]()
                screensTemp.append(selectedDisplay)
                try? Wallpaper.set(URL(string: fullImagePath)!, screen: .nsScreens(screensTemp))
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
