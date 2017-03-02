//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UITableViewController {
  
    //lazy var photos = NSDictionary(contentsOf:dataSourceURL!)!
    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        fetchPhotoDetails()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // #pragma mark - Table view data source
  
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //    let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        //    let rowKey = photos.allKeys[indexPath.row] as! String
        //    print(rowKey)
        //
        //    var image : UIImage?
        //    if let imageURL = URL(string:photos[rowKey] as! String),
        //    let imageData = try? Data(contentsOf: imageURL){
        //        //1
        //        let unfilteredImage = UIImage(data:imageData)
        //        //image = UIImage(data: imageData)
        //        //2
        //        image = self.applySepiaFilter(unfilteredImage!)
        //    }
        //
        //    // Configure the cell...
        //    cell.textLabel?.text = rowKey
        //    if image != nil {
        //      cell.imageView?.image = image!
        //    }
        //
        //    return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        
        //1
         indicator:
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        //2
        let photoDetails = photos[indexPath.row]
        
        //3
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        //4
        switch (photoDetails.state){
//        case .Filtered:
//            indicator.stopAnimating()
        case .Failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .New, .Downloaded:
            indicator.startAnimating()
            self.startDownloadForRecord(photoDetails: photoDetails,indexPath:indexPath as NSIndexPath)
        }
        
        return cell
  }
  
    func fetchPhotoDetails(){
        let urls = NSDictionary(contentsOf:dataSourceURL!)!
        for (key, value) in urls{
            let text = key as? String
            let url = URL(string: value as? String ?? "")
            if text != nil && url != nil {
                let photo = PhotoRecord(name:text!, url:url!)
                self.photos.append(photo)
            }
        }
        //tableView.reloadData()
    }
    
    func startDownloadForRecord(photoDetails: PhotoRecord, indexPath: NSIndexPath){
        //1
        if let downloadOperation = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        //2
        let downloader = ImageDownloader(photoRecord: photoDetails)
        //3
        //OperationQueue.addOperation(downloader)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            OperationQueue.main.addOperation {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath as IndexPath], with: .fade)
            }
//            DispatchQueue.main.async(execute: {
//                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
//                self.tableView.reloadRows(at: [indexPath as IndexPath], with: .fade)
//            })
        }
        //4
        pendingOperations.downloadsInProgress[indexPath] = downloader
        //5
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
}
