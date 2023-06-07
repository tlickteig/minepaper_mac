//
//  Utilities.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import Foundation

struct Utilities {
    
    static func downloadImageFromServer(fileName: String) {
        
        let sephamore = DispatchSemaphore(value: 0)
        let fm = FileManager()
        
        let url = URL(string: Constants.remoteImagesFolder + "/" + fileName)
        let task = URLSession.shared.downloadTask(with: url!) { localURL, urlResponse, error in
            if let localURL = localURL {
                try? FileManager.default.moveItem(atPath: "/var/tmp/test.txt", toPath: "/Users/timothylickteig/test.txt")
                //try? FileManager().copyItem(atPath: localURL.absoluteString, toPath: "/var/tmp")
                print("Hello World!")
            }
            
            sephamore.signal()
        }

        // Start the download
        task.resume()
        sephamore.wait()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
