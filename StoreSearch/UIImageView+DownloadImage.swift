//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Norbert Czirjak on 2017. 11. 14..
//  Copyright © 2017. Norbert Czirjak. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        //1it will save the file to a tmp location
        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
            //this is the inside url which points to the tmp file location
            if error == nil, let url = url,
                //we will load the local file to a Data object
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                // we need to check the self is still exists, the user not changed the view
                // to a different one, where this image is not exists anymore
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                }
            }
        })
        //after the download the resume will run the urslsessiondownloadtask obj to the caller.
        downloadTask.resume()
        //aze returnolom mert igy az appnak van eselye cancel() nyomni a download taskra.
        return downloadTask
    }
}
