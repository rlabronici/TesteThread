//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Rodrigo Labronici on 28/02/17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case New, Downloaded,  Failed
}

class PhotoRecord {
    let name:String
    let url: URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
}

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
//    lazy var filtrationsInProgress = [NSIndexPath:Operation]()
//    lazy var filtrationQueue:OperationQueue = {
//        var queue = OperationQueue()
//        queue.name = "Image Filtration queue"
//        queue.maxConcurrentOperationCount = 1
//        return queue
//    }()
}

class ImageDownloader: Operation {
    //1
    let photoRecord: PhotoRecord
    
    //2
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        //5
        do{
            let imageData = try Data(contentsOf:self.photoRecord.url)
            //6
            if self.isCancelled {
                return
            }
            
            //7
            if imageData.count > 0 {
                self.photoRecord.image = UIImage(data:imageData as Data)
                self.photoRecord.state = .Downloaded
            }
            else
            {
                self.photoRecord.state = .Failed
                self.photoRecord.image = UIImage(named: "Failed")
            }
        } catch {
            print ("erro")
        }
        
        
    }
    
}
