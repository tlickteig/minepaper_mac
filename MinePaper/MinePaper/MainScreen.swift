//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI
import Wallpaper
import Kingfisher
import AlertToast
import AsyncDownSamplingImage

struct MainScreen: View {
    
    @State var wallpapers = [WallpaperOption]()
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var isLoading = true
    @State private var size: CGSize = .init(width: 160, height: 90)


    var body: some View {
        
        VStack {
            NavigationSplitView(columnVisibility: $sideBarVisibility) {
                List(wallpapers, id: \.id) { image in
                    NavigationLink(destination: WallpaperSelectedScreen(selectedImage: image)) {
                        AsyncDownSamplingImage(
                          url: URL(string: "file://" + image.fullImagePath),
                          downsampleSize: size
                        ) { image in image
                            .resizable()
                            .scaledToFill()
                            .padding(1)
                            .cornerRadius(10)
                        } fail: { error in
                          Text("Error loading image")
                        }
                        .cornerRadius(10)
                        .frame(width: 150)
                    }
                }
                .task {
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            defer {
                                isLoading = false
                            }
                            
                            try Utilities.syncImagesWithServer()
                            wallpapers = try MainScreen.returnImagesList()
                        }
                        catch GeneralErrors.DataReadError {
                            DispatchQueue.main.async {
                                _ = Utilities.displayErrorMessage(message: "Error occurred loading data")
                            }
                        }
                        catch GeneralErrors.DataWriteError {
                            DispatchQueue.main.async {
                                _ = Utilities.displayErrorMessage(message: "Error occurred saving data")
                            }
                        }
                        catch NetworkError.GeneralError {
                            DispatchQueue.main.async {
                                _ = Utilities.displayErrorMessage(message: "A network error has occurred")
                            }
                        }
                        catch {
                            DispatchQueue.main.async {
                                _ = Utilities.displayErrorMessage(message: "An error has occurred")
                            }
                        }
                    }
                }
                .frame(width: 200, alignment: .center)
                
            } detail: {
                VStack {
                    ProgressView()
                    Text("")
                    Text("Downloading images...")
                }
                .opacity(isLoading ? 1 : 0)
                
                Text("Select an image to preview").opacity(isLoading ? 0 : 1)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
    
    static func returnImagesList() throws -> [WallpaperOption] {
        
        var output = [WallpaperOption]()
        let imageList = try Utilities.scanImagesDirectory()
        
        for image in imageList {
            output.append(WallpaperOption(imageName: image))
        }
        
        return output
    }
}

struct WallpaperSelectedScreen: View {
    
    private var image: WallpaperOption
    private var screens: [NSScreen] = NSScreen.screens
    
    @State private var selectedDisplay: NSScreen
    @State private var showingToast: Bool = false
    
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
                        if screen == NSScreen.main {
                            Text("\(screen.localizedName) (Primary)")
                        }
                        else {
                            Text(screen.localizedName)
                        }
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
                do {
                    try Utilities.setWallpaper(fileName: image.imageName, screen: selectedDisplay)
                    showingToast = true
                }
                catch GeneralErrors.DataReadError {
                    DispatchQueue.main.async {
                        _ = Utilities.displayErrorMessage(message: "Error occurred reading data")
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        _ = Utilities.displayErrorMessage(message: "An error has occurred")
                    }
                }
            }
            .frame(alignment: .bottom)
            .padding(.bottom, 10)
        }
        .onAppear {
            if screens.count > 0 {
                selectedDisplay = screens[0]
            }
        }
        .toast(isPresenting: $showingToast) {
            AlertToast(type: .regular, title: "Wallpaper set")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
