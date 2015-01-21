/*============================================================================= 
 
   Name     : FMELocationManager.m
 
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

#import "FMELocationManager.h"

static const CLLocationDistance kMinDistanceFilter = 1.0f;

@interface FMELocationManager ()
@property (nonatomic, retain)   CLLocationManager * singleShotLocationManager;
@property (nonatomic, retain)   CLLocationManager * locationManager;
@property (nonatomic, retain)   NSTimer           * timer;
@property (nonatomic, retain)   CLLocation        * location;
@property (nonatomic, retain)   CLLocation        * nextLocation;
@property (nonatomic)           BOOL                timeout;
@property (nonatomic)           BOOL                trackingLocation;

// Once we start the single-shot location manager, multiple locations may be
// returned. We only want to report the location once so that we can use this
// boolean to prevent us from sending more than one location to the server for
// every location request.
@property (nonatomic)           BOOL                singleLocationRequested;
- (void)onTimeout;
- (void)updateToLocation:(CLLocation *)newLocation;
- (BOOL)hasTimerStarted;
- (BOOL)hasDistanceFilter;
- (void)updateLocationManager:(CLLocationManager*)locationManager withDistanceFilter:(CLLocationDistance)distanceFilter;

// This function invalidates the existing timer and restarts a new timer with
// the time interval if the location manager is tracking location.
- (void)updateTimerWithTimeInterval:(NSTimeInterval)timeInterval;
@end

@implementation FMELocationManager

@synthesize timeIntervalInSec         = timeIntervalInSec_;
@synthesize distanceFilterInMeter     = distanceFilterInMeter_;
@synthesize singleShotLocationManager = singleShotLocationManager_;
@synthesize locationManager           = locationManager_;
@synthesize timer                     = timer_;
@synthesize timeout                   = timeout_;
@synthesize highPrecisionEnabled      = highPrecisionEnabled_;
@synthesize location                  = location_;
@synthesize nextLocation              = nextLocation_;
@synthesize delegate                  = delegate_;
@synthesize trackingLocation          = trackingLocation_;
@synthesize singleLocationRequested   = singleLocationRequested_;

#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        timeIntervalInSec_               = 0;
        distanceFilterInMeter_           = kCLDistanceFilterNone;
        location_                        = nil;
        nextLocation_                    = nil;
        timer_                           = nil;
        timeout_                         = NO;
        highPrecisionEnabled_            = YES;
        singleShotLocationManager_       = nil;
        singleLocationRequested_         = NO;
        locationManager_                 = [[CLLocationManager alloc] init];
        locationManager_.delegate        = self;
        
        // From the testing that we have done, the location manager could
        // pause and couldn't resume when the device moves to a different
        // location. We should disable pausesLocationUpdatesAutomatically.
        locationManager_.pausesLocationUpdatesAutomatically = NO;
        
        // We also assume that we are handling automotive movement since our
        // distance filter intervals are multiples of 100 meters.
        locationManager_.activityType    = CLActivityTypeAutomotiveNavigation;
        
        // We do not need to use kCLLocationAccuracyBestForNavigation since it
        // also gather information from the compass for direction and other
        // navigation information. Our apps only require the best lat,long
        // location. kCLLocationAccuracyBest will be enough.
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        trackingLocation_                = NO;
    }
    
    return self;
}

#pragma mark - Public properties

- (BOOL)significantLocationChangeMonitoringAvailable
{
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

- (void)setTimeIntervalInSec:(NSTimeInterval)timeIntervalInSec
{
    [self updateTimerWithTimeInterval:timeIntervalInSec];
    timeIntervalInSec_ = timeIntervalInSec;
}

- (void)setDistanceFilterInMeter:(CLLocationDistance)distanceFilterInMeter
{
    [self updateLocationManager:self.locationManager withDistanceFilter:distanceFilterInMeter];
    distanceFilterInMeter_ = distanceFilterInMeter;
}

- (void)setHighPrecisionEnabled:(BOOL)highPrecisionEnabled
{
    BOOL trackingLocation = self.trackingLocation;
    if (trackingLocation) {
        [self stopLocationTracking];
    }
    
    highPrecisionEnabled_ = highPrecisionEnabled;
    
    if (trackingLocation) {
        [self startLocationTracking];
    }
}

#pragma mark - Private properties

- (CLLocationManager *)singleShotLocationManager
{
    if (!singleShotLocationManager_)
    {
        singleShotLocationManager_                 = [[CLLocationManager alloc] init];
        singleShotLocationManager_.delegate        = self;
        singleShotLocationManager_.pausesLocationUpdatesAutomatically = NO;
        singleShotLocationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        singleShotLocationManager_.distanceFilter  = kCLDistanceFilterNone;
    }
    
    return singleShotLocationManager_;
}

#pragma mark - Public functions

- (void)startLocationTracking
{
    self.trackingLocation = YES;
    
    // Make sure we have a minimum distance filter set on the location manager.
    [self updateLocationManager:self.locationManager withDistanceFilter:self.distanceFilterInMeter];

    if (!self.highPrecisionEnabled)
    {
        NSLog(@"LOCATION MANAGER: START MONITORING SIGNIFICANT LOCATION CHANGES");
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
        
        // Also request and report the current location once since the location
        // manager may not report a location until there is a change of the
        // cell tower.
        [self requestLocation];
    }
    else if (self.timeIntervalInSec > 0)
    {        
        [self updateTimerWithTimeInterval:self.timeIntervalInSec];
        
        // We have to start updating location for the timer to run since the
        // timer alone isn't able to keep the app from being inactive, which
        // stops the timer.
        NSLog(@"LOCATION MANAGER: START UPDATING LOCATION - TIMER AND MAYBE DISTANCE FILTER");
        [self.locationManager stopMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
    }
    else if ([self hasDistanceFilter])
    {
        // We have to start the location manager to track the distance
        NSLog(@"LOCATION MANAGER: START UPDATING LOCATION - DISTANCE FILTER ONLY");
        [self.locationManager stopMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
    }
    else 
    {
        // Do nothing, since we are not using high precision, and the time
        // interval and the distance filter are not valid.
    }
}

- (void)stopLocationTracking
{
    self.trackingLocation = NO;
    
    NSLog(@"LOCATION MANAGER: STOP MONITORING SIGNIFICANT LOCATION CHANGES");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    NSLog(@"LOCATION MANAGER: STOP UPDATING LOCATION");
    [self.locationManager stopUpdatingLocation];
    
    if ([self hasTimerStarted])
    {
        // Stop the timer
        // We must create a new timer next time since the timer object cannot
        // be reused once invalidated. Please refer to the NSTimer Class
        // Reference for details.
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)requestLocation
{
    self.singleLocationRequested = YES;
    [self.singleShotLocationManager startUpdatingLocation];
}

#pragma mark - Private functions

- (void)onTimeout
{
    NSLog(@"Timeout: %@", [NSDate date]);
    
    if (self.locationManager.location)
    {
        if ([self hasDistanceFilter])
        {
            // When the next location from the location manager is available,
            // we are sure that the device already passes the distance. We
            // can send the location now.
            if (self.nextLocation)
            {
                [self updateToLocation:self.nextLocation];
                self.nextLocation = nil;
            }
            else
            {
                // The location manager has not called back with a location. We
                // need to wait for a callback from the location manager. Note that
                // we want to send the location as soon as the location is available.
                self.timeout = YES;
            }            
        }
        else
        {
            // Always report the last location and time is out.
            [self updateToLocation:self.nextLocation];
        }
    }
    else
    {
        // There is no available location yet. Remember that the time is out
        // already. When there is a location update, we will send the location
        // immediately.
        self.timeout = YES;
    }
}

- (void)updateToLocation:(CLLocation *)newLocation
{
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(fmeLocationManager:didUpdateToLocation:)])
    {
        NSLog(@"Sending location: %.3f, %.3f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);        
        [self.delegate fmeLocationManager:self didUpdateToLocation:newLocation];
    }
    
    // Remember the new location
    self.location = newLocation;
}

- (BOOL)hasTimerStarted
{
    return self.timer != nil;
}

- (BOOL)hasDistanceFilter
{
    return (self.distanceFilterInMeter != kCLDistanceFilterNone &&
            self.distanceFilterInMeter != 0);
}

- (void)updateLocationManager:(CLLocationManager*)locationManager withDistanceFilter:(CLLocationDistance)distanceFilter
{
    if (distanceFilter != kCLDistanceFilterNone && distanceFilter != 0)
    {
        if (locationManager.distanceFilter != distanceFilter)
        {
            locationManager.distanceFilter = distanceFilter;   
        }
    }
    else
    {
        // We are forcing the location manager to use at least a 1-meter
        // distance filter so that the location manager won't update our
        // callback function every second. This should greatly reduce the
        // battery consumption.
        if (locationManager.distanceFilter != kMinDistanceFilter)
        {
            locationManager.distanceFilter = kMinDistanceFilter;
        }
    }   
}

- (void)updateTimerWithTimeInterval:(NSTimeInterval)timeInterval
{
    if (self.timer)
    {
        // If the timer is running with a different time interval, invalidate
        // the timer
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (timeInterval > 0 && self.trackingLocation)
    {
        // Start timer
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                      target:self
                                                    selector:@selector(onTimeout)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

#pragma mark - CLLocationManagerDelegate protocol implementation

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * newLocation = [locations objectAtIndex:locations.count - 1];
    if (!newLocation)
    {
        // This should not happen since the doc says there must be at least one
        // location in the array.
        return;
    }
    
    // Handle single-shot location request
    if (manager == self.singleShotLocationManager && self.singleLocationRequested)
    {
        // We are about to send a location. We can clear the flag now so that
        // the subsequent locations returned will not be reported to the server.
        self.singleLocationRequested = NO;
        
        // Handle single location request here
        [self updateToLocation:newLocation];
        [self.singleShotLocationManager stopUpdatingLocation];
        return;
    }

    // Handle Auto Report Location
    if (self.locationManager != manager)
    {
        return;
    }

    // If we have a previous location, validate the new location
    if (self.location && [self.location.timestamp compare:newLocation.timestamp] == NSOrderedDescending)
    {
        return; // The new location is older than our previous location. Forget it.
    }
     
    if (!self.highPrecisionEnabled)
    {
        // We are tracking coarse location so that we can ignore the timer and
        // the distance filter. We can update the location now.
        [self updateToLocation:newLocation];
    }
    else if ([self hasTimerStarted])
    {
        // If the timer is timeout already, we can update the location now.
        if (self.timeout)
        {
            [self updateToLocation:newLocation];
            
            // Reset the timer status
            self.timeout = NO;
            
            // Make sure the next location is nil since we have already update
            // the location.
            self.nextLocation = nil;
        }
        else 
        {
            // Remember the new location. If the timer is running, the next timeout
            // will use this location.
            self.nextLocation = newLocation;
        }       
    }
    else if (self.distanceFilterInMeter > 0)
    {
        // If we are here, we are not using coarse location tracking and the
        // timer is not running. We can update the location now since the
        // distance filter is valid.
        [self updateToLocation:newLocation];
    }
}

@end
