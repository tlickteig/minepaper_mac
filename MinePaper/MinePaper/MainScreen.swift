//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI
import Wallpaper
import Kingfisher

struct MainScreen: View {
    
    let imageSync = try? Utilities.syncImagesWithServer()
    let images = returnImagesList()
    
    //let memoryCapacity = Foundation.URLCache.shared.memoryCapacity = 100_000_000
    //let diskCapacity = Foundation.URLCache.shared.diskCapacity = 1_000_000_000
    
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        
        VStack {
            NavigationSplitView(columnVisibility: $sideBarVisibility) {
                List(images) { image in
                    NavigationLink(destination: WallpaperSelectedScreen(selectedImage: image)) {
                        /*AsyncImage(url: URL(string: "file://" + image.fullImagePath)) { phase in
                            phase.image?
                                    .resizable()
                                    .scaledToFill()
                        }
                        .padding(1)
                        .cornerRadius(10)*/
                        //CachedAsyncImage(url: URL(string: "file://" + image.fullImagePath), urlCache: .)
                        //LazyImage(source: "file://" + image.fullImagePath)
                        KFImage(URL(string: "file://" + image.fullImagePath))
                            .resizable()
                            .scaledToFill()
                            .padding(1)
                            .cornerRadius(10)
                    }
                }
                .frame(width: 200, alignment: .center)
            } detail: {
                Text("Select an image to preview")
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
    
    init(selectedImage: WallpaperOption) {
        image = selectedImage
        selectedDisplay = screens[0]
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
            AsyncImage(url: URL(string: "file://" + image.fullImagePath)) { image in
                image.image?
                    .resizable()
                    .scaledToFill()
                    
            }
            .padding(1)
            .cornerRadius(10)
            .frame(width: 480, height: 270)
            
            Spacer()
            Button("Set Wallpaper") {
                try? Utilities.setWallpaper(fileName: image.imageName, screen: selectedDisplay)
            }
            .frame(alignment: .bottom)
            .padding(.bottom, 10)
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
