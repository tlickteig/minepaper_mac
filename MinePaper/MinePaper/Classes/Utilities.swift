//
//  Utilities.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import Foundation

struct Utilities {
    
    static func downloadImageFromServer(fileName: String) {
        
        let url = URL(string: Constants.remoteImagesFolder + "/" + fileName)
        
        let task = URLSession.shared.dataTask() { (data, response, error)
            
            if let error = error {
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return
            }
        }
    }
}
