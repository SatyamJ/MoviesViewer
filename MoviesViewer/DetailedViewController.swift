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
    var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = movie!["title"] as? String
        overviewLabel.text = movie!["overview"] as? String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie!["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterView.setImageWithURL(imageUrl!)
        }
        
        // Do any additional setup after loading the view.
        /*
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie!["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            let imageRequest = NSURLRequest(URL: imageUrl!)
            
            posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.posterView.alpha = 0.0
                        self.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
                }
            )
        }*/
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
