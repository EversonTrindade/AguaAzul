//
//  ViewController.h
//  Agua Azul
//
//  Created by Everson Trindade on 12/12/14.
//  Copyright (c) 2014 TADS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomAnnotation.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) sqlite3 *myDatabase;
@property (strong, nonatomic) NSString *statusOfAddingToDB;
@property (strong, nonatomic) NSString *databasePath;

@property (nonatomic, retain) NSMutableArray *praiasLista;
@property (nonatomic, retain) NSMutableArray *praiasLista2;


- (void)action;
- (void)fetchJSON;
- (void)updateMapWithDictionary:(NSDictionary*)json;
- (void)mapWithAnnotation;


@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *annotation;
@property (strong, nonatomic) NSMutableArray *annotationArray;

- (IBAction)refreshMap:(id)sender;
- (IBAction)sobre:(id)sender;

@end

