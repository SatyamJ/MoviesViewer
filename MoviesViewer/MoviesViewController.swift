//
//  MoviesViewController.swift
//  MoviesViewer
//
//  Created by Satyam Jaiswal on 1/24/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]?
    
    @IBOutlet weak var networkErrorImageView: UIImageView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkErrorImageView.hidden = true
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        filteredData = movies
        
        loadDataFromNetwork()
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = filteredData{
            return movies.count
        }
        else{
            return 0
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredData![indexPath.row]
        let title = movie["title"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = movie["overview"] as? String
        
        //cell.posterView.setImageWithURL(imageUrl!)
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
        
            let imageRequest = NSURLRequest(URL: imageUrl!)
        
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
            })
        }
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let detailViewController = segue.destinationViewController as! DetailedViewController
        detailViewController.movie = filteredData![indexPath!.row]
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    @IBAction func networkErrorOnTap(sender: AnyObject) {
        self.networkErrorImageView.hidden = true
        loadDataFromNetwork()
    }
    
    func loadDataFromNetwork() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        
        let myRequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    
                    self.networkErrorImageView.hidden = true
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    // ... Remainder of response handling code ...
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredData = self.movies
                            self.tableView.reloadData()
                    }
                }
                else{
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.networkErrorImageView.hidden = false
                }
                
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        loadDataFromNetwork()
        refreshControl.endRefreshing()
    }
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (dataItem["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadDataFromNetwork()
    }


}
