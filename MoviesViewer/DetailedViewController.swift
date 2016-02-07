//
//  DetailedViewController.swift
//  MoviesViewer
//
//  Created by Satyam Jaiswal on 1/31/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var detailsView: UIView!
    
    var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        titleLabel.text = movie!["title"] as? String
        overviewLabel.text = movie!["overview"] as? String
        overviewLabel.sizeToFit()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailsView.frame.origin.y + detailsView.frame.height)
        
        let lowerbaseUrl = "https://image.tmdb.org/t/p/w45"
        let higherbaseUrl = "https://image.tmdb.org/t/p/original"
        
        /*
        if let posterPath = movie!["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterView.setImageWithURL(imageUrl!)
        }
        */
        let posterUrl = movie!["poster_path"] as? String
        //let backdropUrl = movie!["backdrop_path"] as? String
        
        let highResPosterImageRequest = NSURLRequest(URL: NSURL(string: (higherbaseUrl + posterUrl!))!)
        let lowResPosterImageRequest = NSURLRequest(URL: NSURL(string: (lowerbaseUrl + posterUrl!))!)
        
        self.posterView.setImageWithURLRequest(
            lowResPosterImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.posterView.alpha = 0.0
                self.posterView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.posterView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterView.setImageWithURLRequest(
                            highResPosterImageRequest   ,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
