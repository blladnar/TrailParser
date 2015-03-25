//
//  AppDelegate.swift
//  TrailParser
//
//  Created by Brown, Randall on 3/18/15.
//  Copyright (c) 2015 Brown, Randall. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var logoField: NSTextField!
    @IBOutlet weak var outputField: NSTextField!

    @IBOutlet weak var makerTrailNameField: NSTextField!
    @IBOutlet weak var makerTrailLogoField: NSTextField!
    @IBOutlet weak var makerLandmarkNameField: NSTextField!
    @IBOutlet weak var makerLandmarDistanceField: NSTextField!
    @IBOutlet weak var makerTrailNumLandmarksLabel: NSTextField!
    @IBOutlet weak var makerTrailDistanceLabel: NSTextField!
    @IBOutlet weak var makerTrailOutput: NSTextField!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        urlField.stringValue = "http://www.summitpost.org/appalachian-trail-mileage-chart/593282"
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func parseWebsite(sender: AnyObject) {
        
        let url = NSURL(string: urlField.stringValue);
        let request = NSURLRequest(URL: url!)
        
        var landmarks = Array<Landmark>();
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            let html = NSString(data:data, encoding:NSUTF8StringEncoding) as String;
            
            var err : NSError?
            var parser = HTMLParser(html: html, error: &err)
            
            var trailMaker = TrailMaker(name: self.nameField.stringValue, logo: self.logoField.stringValue);
            
            var bodyNode = parser.body
            
            if let inputNodes = bodyNode?.findChildTags("table")
            {
                for node in inputNodes
                {
                    if(node.getAttributeNamed("bordercolor") == "brown")
                    {
                        
                        let tableRows = node.findChildTags("tr");
                        
                        for row in tableRows
                        {
                            let tableData = row.findChildTags("td");
                            let mileageStuff = tableData[0].findChildTags("font");
                            if(mileageStuff.count > 0)
                            {
                                continue;
                            }
                            
                            let mileage = tableData[0].contents as NSString;
                            
                            var feature = "" as NSString;
                            
                            let featureLinks = tableData[1].findChildTags("a");
                            if(featureLinks.count == 0)
                            {
                                feature = tableData[1].contents;
                            }
                            else
                            {
                                feature = featureLinks[0].contents;
                            }

                            let row = String(format:"%f %@", mileage.doubleValue, feature.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()));
                            
                            trailMaker.addLandmarkNamed(feature, distanceInMiles: mileage.doubleValue);
                        }
                    }
                    
                }
            }
            self.outputField.stringValue = trailMaker.trailJSON();
        }
    }
    
    var makerLandmarks = Array<Landmark>();
    @IBAction func makerAddLandmark(sender: AnyObject)
    {
        var distance = self.makerLandmarDistanceField.stringValue as NSString;
        
        makerLandmarks.append(Landmark(name: self.makerLandmarkNameField.stringValue, distanceInMiles: distance.doubleValue));
        
        makerLandmarDistanceField.stringValue = "";
        makerLandmarkNameField.stringValue = "";
        
        makerLandmarkNameField.becomeFirstResponder();
    }
    
    @IBAction func makerCreateTrail(sender: AnyObject)
    {
        var maker = TrailMaker(name: self.makerTrailNameField.stringValue, logo: self.makerTrailLogoField.stringValue);
        for landmark in makerLandmarks
        {
            maker.addLandmark(landmark);
        }
        
        
        self.makerTrailOutput.stringValue = maker.trailJSON();
        self.makerTrailDistanceLabel.stringValue = "Total Mileage \(maker.trailMileage())"
        self.makerTrailNumLandmarksLabel.stringValue = "Number of landmarks \(maker.numberOfLandmarks())";

    }

}

