//
//  iPadHomeViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 9/05/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit

class iPadHomeViewController: UIViewController {

    @IBOutlet weak var DatabaseBuildProgress: UIProgressView!
    @IBOutlet weak var DatabaseBuildingActivity: UIActivityIndicatorView!
    @IBOutlet weak var DatabaseBuildingLabel: UILabel!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnAnimalTopContstrait: NSLayoutConstraint!
    @IBOutlet weak var btnAnimals: UIButton!
    @IBOutlet weak var HomeBackgroundImage: UIImageView!
    var delegate:iPadHomeViewControllerDelegate! = nil
    weak var aboutWebViewController:MVWebWrapperViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseBuildingActivity.stopAnimating()
        
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            setHomePageLandscape()
        }
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).buildingDatabase){
            //Subscribe to finish Building Notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(databaseBuildFinished), name:NotificationType.DidRefreshDatabase, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(databasePercentComplete(_:)), name:NotificationType.DatabasePercentComplete, object: nil)
            self.hideButtons()
            
            DatabaseBuildingActivity.hidden = false;
            DatabaseBuildingActivity.startAnimating()
            DatabaseBuildProgress.hidden = false;
            DatabaseBuildingLabel.hidden = false;
        }else{
            //check gallery setup
            if !LocalDefaults.sharedInstance.hasGallery {
                btnGallery.hidden = true
            }
        }
        
    }
 
    func databaseBuildFinished(notification: NSNotification){
        //No longer need the notification - remove
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.showButtons()
        DatabaseBuildingActivity.stopAnimating()
        DatabaseBuildingActivity.hidden = true;
        DatabaseBuildProgress.hidden = true;
        DatabaseBuildingLabel.hidden = true;
        
        
    }
    
    func databasePercentComplete(notification:NSNotification){
        
        if let percentage = notification.userInfo?["percentage"] as? Float{
            
            if !DatabaseBuildProgress.hidden {
            
                DatabaseBuildProgress.progress = percentage
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "embedAboutViewController"{
            aboutWebViewController = segue.destinationViewController as? MVWebWrapperViewController
            
        }
        
    }
 

    @IBAction func showMasterList(sender: AnyObject) {
        delegate.showMaster()  
        
    }
    
    
    @IBAction func showAbout(sender: AnyObject) {

        homePageInactive()
        aboutWebViewController!.nudgeUpContent()

        delegate.aboutShown() //activates Home Button
    }
    
    func hideAbout(){
        

        self.view.layoutIfNeeded()
        self.btnAbout.alpha = 0;
        self.btnAnimals.alpha = 0;
        self.btnGallery.alpha = 0;
        self.HomeBackgroundImage.alpha = 0;
        self.showButtons()
        self.HomeBackgroundImage.hidden = false;
        UIView.animateWithDuration(1.0, animations:{
           self.aboutWebViewController!.returnToTop()
            self.btnAbout.alpha = 1;
            self.btnAnimals.alpha = 1;
            self.btnGallery.alpha = 1;
           
            } , completion: {finished in if(finished){
                    self.HomeBackgroundImage.alpha = 1;
                                // need to work on animation in and out.
                }
            
            })
    }
    
    func homePageActive(){
        
       // btnAbout.enabled = true;
        self.showButtons()

        self.HomeBackgroundImage.hidden = false
        
    }
    
    func homePageInactive(){
        self.hideButtons()

        self.HomeBackgroundImage.hidden = true
        
    }
    
    func setHomePageLandscape(){
        HomeBackgroundImage.image = UIImage(named:"home-landscape.png")
      //  btnAnimalTopContstrait.constant = -75
        
    }
    
    func setHomePagePortrait(){
        HomeBackgroundImage.image = UIImage(named:"home-portrait.png")
      //  btnAnimalTopContstrait.constant = -125
    }
    
    func hideButtons(){
        btnAbout.hidden = true;
        btnAnimals.hidden = true;
        btnGallery.hidden = true; 
    }
    
    func showButtons(){
        
        btnAbout.hidden = false;
        btnAnimals.hidden = false;
        //only show Gallery button if Gallery exists
        if LocalDefaults.sharedInstance.hasGallery{
            btnGallery.hidden = false;
        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
           setHomePageLandscape()
        } else {
           setHomePagePortrait()
        }
    }
    

    
    
}

    // delegate Protocol
    
    protocol iPadHomeViewControllerDelegate {
        func aboutHidden()
        func aboutShown()
        func showMaster()
    }


