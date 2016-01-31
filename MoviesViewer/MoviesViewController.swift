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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    
    @IBOutlet weak var networkErrorImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkErrorImageView.hidden = true
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        loadDataFromNetwork()
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        /*
        let netErr = UIImage(contentsOfFile: "networkerror")
        let networkErrorImageView = UIImageView(image: netErr)
        tableView.addSubview(networkErrorImageView)
        
        networkErrorImageView.frame.size.height = 50
        networkErrorImageView.frame.size.height = 200
        networkErrorImageView.frame.origin.x = 0
        networkErrorImageView.frame.origin.y = 0
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
        }
        else{
            return 0
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = movie["overview"] as? String
        cell.posterView.setImageWithURL(imageUrl!)
        
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func networkErrorOnTap(sender: AnyObject) {
        self.networkErrorImageView.hidden = true
        loadDataFromNetwork()
    }
    
    func loadDataFromNetwork() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
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

}
