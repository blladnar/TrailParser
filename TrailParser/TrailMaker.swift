//
//  TrailMaker.swift
//  TrailParser
//
//  Created by Brown, Randall on 3/25/15.
//  Copyright (c) 2015 Brown, Randall. All rights reserved.
//

import Foundation

class TrailMaker
{
    var name : String = ""
    var logo : String = ""
    
    private var landmarks = Array<Landmark>()
    
    init(name:String, logo:String)
    {
        self.name = name
        self.logo = logo
    }
    
    func addLandmarkNamed(name:String, distanceInMiles:Double)
    {
        addLandmark(Landmark(name: name, distanceInMiles: distanceInMiles))
    }
    
    func addLandmark(landmark:Landmark)
    {
        landmarks.append(landmark);
    }
    
    func trailJSON() -> String
    {
        var landmarkDicts = Array<Dictionary<String,AnyObject>>();
        
        for landmark in landmarks
        {
            var landmarkDictionary :Dictionary<String, AnyObject> = ["name":landmark.name, "distance":landmark.distance, "distanceInMiles":landmark.distanceInMiles];
            landmarkDicts.append(landmarkDictionary);
        }
        
        let trail = ["name" : name, "logo" : logo, "landmarks" : landmarkDicts];
        
        var jsonData = NSJSONSerialization.dataWithJSONObject(trail, options: NSJSONWritingOptions.PrettyPrinted, error: nil);
        
        let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding);
        
        return jsonString!;
    }
    
    func numberOfLandmarks() -> Int
    {
        return landmarks.count;
    }
    
    func trailMileage() -> Double
    {
        return landmarks.last!.distanceInMiles;
    }
    
}
