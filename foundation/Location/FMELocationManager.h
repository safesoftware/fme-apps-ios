/*============================================================================= 
 
   Name     : FMELocationManager.h
 
   System   : Location
 
   Language : Objective-C 
 
   Purpose  : TBD
 
         Copyright (c) 2013 - 2014, Safe Software Inc. All rights reserved. 
 
   Redistribution and use of this sample code in source and binary forms, with  
   or without modification, are permitted provided that the following  
   conditions are met: 
   * Redistributions of source code must retain the above copyright notice,  
     this list of conditions and the following disclaimer. 
   * Redistributions in binary form must reproduce the above copyright notice,  
     this list of conditions and the following disclaimer in the documentation  
     and/or other materials provided with the distribution. 
 
   THIS SAMPLE CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  
   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR  
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR  
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,  
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,  
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;  
   OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,  
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  
   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SAMPLE CODE, EVEN IF  
   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
=============================================================================*/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FMELocationManager;

@protocol FMELocationManagerDelegate <NSObject>
- (void)fmeLocationManager:(FMELocationManager *)locationManager
       didUpdateToLocation:(CLLocation *)newLocation;
@end

//! This location manager handles callbacks from the CLLocationManager. This
//! class also provides a few options: high precision location tracking, 
//! time interval, and distance filter. Not using high precision is equivalent 
//! to monitoring significant location changes on CLLocationManager. The 
//! distance filter is also directly applied on CLLocationManager.
//! 
//! When high precision is disabled, the time interval and the distance
//! filter will be ignored. If high precision tracking is enabled, either
//! the time interval or the distance filter must be a positive number before
//! starting the location tracking. If both the time interval and the distance
//! filter are valid, both conditions will need to be satisfied before a new
//! location is returned to the delegate.
//!
//! If timeIntervalInSec, distanceFilterInMeter, or highPrecisionEnabled is
//! set to a different value, the location manager will be restarted.
//!
//! If the location manager does not retrieve a new location, the delegate
//! will not be notified even if the time interval has passed.
@interface FMELocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic)                   NSTimeInterval                   timeIntervalInSec;
@property (nonatomic)                   CLLocationDistance               distanceFilterInMeter; 
@property (nonatomic)                   BOOL                             highPrecisionEnabled;
@property (nonatomic, weak)             id<FMELocationManagerDelegate>   delegate;
@property (nonatomic, readonly)         BOOL                             significantLocationChangeMonitoringAvailable;
@property (nonatomic, readonly, retain) CLLocation                     * location;

//! This property is YES if the location tracking is running; NO, otherwise.
@property (nonatomic, readonly)         BOOL                             trackingLocation;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)requestLocation;

@end
