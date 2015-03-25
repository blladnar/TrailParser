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
            
            var landmarksDictionary = [String,Double]();
            
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
                            
                            let landmark = Landmark(name:feature, distanceInMiles:mileage.doubleValue);
                            landmarks.append(landmark);
                            
                            println(row);
                        }
                        
                     //   println(node.contents)
                    }
                    
                }
            }
            
            var x = 0;
            
            var landmarkDicts = Array<Dictionary<String,AnyObject>>();
            
            for landmarkd in landmarks
            {
                var landmarkDictionary :Dictionary<String, AnyObject> = ["name":landmarkd.name, "distance":landmarkd.distance, "distanceInMiles":landmarkd.distanceInMiles];
                landmarkDicts.append(landmarkDictionary);

            }
            
            let trail = ["name" : self.nameField.stringValue, "logo" : self.logoField.stringValue, "landmarks" : landmarkDicts];
            
            var jsonData = NSJSONSerialization.dataWithJSONObject(trail, options: NSJSONWritingOptions.PrettyPrinted, error: nil);
            
            let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding);
            self.outputField.stringValue = jsonString!;
            
        }
    }

}

func toMeters(miles:Double) -> Double {
    return miles * 1609.34;
}

