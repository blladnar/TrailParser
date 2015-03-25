//
//  Landmark.swift
//  TrailParser
//
//  Created by Brown, Randall on 3/25/15.
//  Copyright (c) 2015 Brown, Randall. All rights reserved.
//
struct Landmark{
    var name : String;
    var distanceInMiles : Double = 0.0;
    var distance : Double
    {
        get
        {
            return distanceInMiles * 1609.34;
        }
    }
}
