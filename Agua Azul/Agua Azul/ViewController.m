//
//  ViewController.m
//  Agua Azul
//
//  Created by Everson Trindade on 12/12/14.
//  Copyright (c) 2014 TADS. All rights reserved.
//

#import "Reachability.h"
#import "ViewController.h"
#import "DataBase.h"
#import "CustomAnnotation.h"
#import "DetalhesViewController.h"

@interface ViewController ()

@end

#define SERVICEURL @"http://54.149.41.128/AguaAzulWS/praia/listar"


@implementation ViewController


@synthesize databasePath, myDatabase, statusOfAddingToDB;
@synthesize praiasLista, praiasLista2;
@synthesize mapView, locationManager, annotation, annotationArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self action];
}

- (IBAction)refreshMap:(id)sender {
    [self action];
}

- (IBAction)sobre:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Projeto Água Azul!"
                                                    message:@"Balneabilidade é a qualidade das águas destinadas à recreação de contato primário, sendo este entendido como um contato direto e prolongado com a água (natação, mergulho, esqui-aquático, etc), onde a possibilidade de ingerir quantidades significativas de água é também expressiva. O estudo da balneabilidade de uma praia compreende a medida das condições sanitárias, objetivando a sua classificação em Própria e Imprópria para o banho, em conformidade com as especificações da resolução Conama nº. 274/2000."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"\ue00d OK!",nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"logo.png"]];
    
    [alert addSubview:imageView];
    [alert show];
}

-(void)action{
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Perguntar antes
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.delegate = self;
    [self.mapView setMapType:MKMapTypeHybrid];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    
    int x = [self checkForNetwork];
    if(x == 1){
        NSLog(@"There's no internet connection at all. Display error message now.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR!"
                                                        message:@"There's no internet connection at all!"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK",nil];
        [alert show];
        //[self mapWithAnnotation];
        
    }else{
        [self fetchJSON];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchJSON
{
    praiasLista = [[NSMutableArray alloc] init];
    
    //show the user that the app is working
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    //execute this block of code in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //fetch data from the URL
        NSData* kivaData = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:SERVICEURL]
                            ];
        
        //if data was fetched - try to parse it and turn it into an NSDictionary
        NSDictionary* json = nil;
        
        if (kivaData) {
            json = [NSJSONSerialization JSONObjectWithData:kivaData options:kNilOptions error:nil];
            
            //NSLog(@" %@", json);
        }
        
        //update the UI - you have to do that on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //code executed on the main queue
            [self updateMapWithDictionary: json];
        });
        
    });
    
}

//Receive and work with json data
- (void)updateMapWithDictionary:(NSDictionary*)json {
    
    int contador = (unsigned int)[[json objectForKey: @"praiaMobile"] count];
   
    DataBase *db =[[DataBase alloc] init];
    [db createDataBase];
    
    praiasLista2 = [[NSMutableArray alloc] init];
    praiasLista2 = [db findLatLong:@"Pitangui"];
    
    @try {
        //cheap way to fall on the catch block, if there was no data fetched at all
        NSAssert(json, @"No JSON object fetched.");
        
        
        int cont = 0;

        
        while (cont < contador) {
            
            NSString *codPraia = [NSString stringWithFormat:@"%@", json[@"praiaMobile"][cont][@"codPraia"], nil];
            //NSLog(@"Cod Praia: %@", codPraia);
            
            NSString *nome = [NSString stringWithFormat: @"%@", json[@"praiaMobile"][cont][@"nome"], nil];
            //NSLog(@"Nome: %@", nome);
            
            NSString *latitude = [NSString stringWithFormat: @"%@", json[@"praiaMobile"][cont][@"latitude"], nil];
            //NSLog(@"Latitude: %@", latitude);
            
            NSString *longitude = [NSString stringWithFormat: @"%@", json[@"praiaMobile"][cont][@"longitude"], nil];
            //NSLog(@"Longitude: %@", longitude);
            
            NSString *balneabilidade = [NSString stringWithFormat:@"%@", json[@"praiaMobile"][cont][@"condicaoBalneabilidade"], nil];
            //NSLog(@"Balneabiidade: %@", balneabilidade);
            
            [db saveData:nome addLat:latitude addLong:longitude addBaln:balneabilidade addCodPraia:codPraia];
            
            cont++;
        }
        
        praiasLista = [db findData];
        [self mapWithAnnotation];
        
    }
    @catch (NSException *exception) {
        //some of the required keys were missing
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not parse the JSON feed."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
        NSLog(@"Exception: %@", exception);
    }
    
    
    
    //turn off the network indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

//Show annotation in the mapView
- (void)mapWithAnnotation{
    
    
    MKCoordinateRegion myRegion;
    CLLocationCoordinate2D myCoordinate;
    myCoordinate.latitude  = self.locationManager.location.coordinate.latitude;
    myCoordinate.longitude = self.locationManager.location.coordinate.longitude;
    MKCoordinateSpan mySpan;
    mySpan.latitudeDelta= 0.5;
    mySpan.longitudeDelta = 0.5;
    myRegion.center = myCoordinate;
    myRegion.span = mySpan;
    
    [mapView setRegion:myRegion animated:YES];

    //NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    annotationArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *row in praiasLista) {
        NSString *latitude = [row objectForKey:@"lat"];
        double latitudeDouble = [latitude doubleValue];
        
        NSString *longitude = [row objectForKey:@"lon"];
        double longitudeDouble = [longitude doubleValue];
        
        NSString *nome = [row objectForKey:@"nome"];
        //NSString *codigo = [row objectForKey:@"codigo"];
        NSString *balneabilidade = [row objectForKey:@"baln"];
        
        /*
        annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(latitudeDouble, longitudeDouble);
        
        
        annotation.title = nome;
        
        if ([balneabilidade  isEqual: @"true"]) {
            annotation.subtitle = @"Praia Própria para Banho";
        }else{
            annotation.subtitle = @"Praia Imprópria para Banho";
            }
        */
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        region.center.latitude = latitudeDouble;
        region.center.longitude = longitudeDouble;
        
        CustomAnnotation *CA = [[CustomAnnotation alloc] init];
        
        CA.title = nome;
        CA.coordinate = region.center;
        if ([balneabilidade  isEqual: @"true"]) {
            CA.subtitle = @"Praia Própria para Banho";
        }else{
            CA.subtitle = @"Praia Imprópria para Banho";
        }
        //[annotationArray addObject:annotation];
        [annotationArray addObject:CA];
        
        
    }
    
   
    // Add to map
    [self.mapView addAnnotations:annotationArray];
    
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (annotation == self.mapView.userLocation) {
        return nil;
    }else{
    
        MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
        MyPin.canShowCallout = YES;
        MyPin.animatesDrop = YES;
        MyPin.selected = YES;
        MyPin.userInteractionEnabled = YES;
        
        /*
        if ([] isEqualToString:@"Praia Própria para Banho"]) {
            MyPin.pinColor = MKPinAnnotationColorGreen;
        }if ([self.annotation.subtitle isEqualToString:@"Praia Imprópria para Banho"]){
            MyPin.pinColor = MKPinAnnotationColorRed;
        }else{
            MyPin.pinColor = MKPinAnnotationColorPurple;
        }
        */
        
        if ([annotation.subtitle isEqualToString:@"Praia Própria para Banho"]) {
            MyPin.pinColor = MKPinAnnotationColorGreen;
        }else if ([annotation.subtitle isEqualToString:@"Praia Imprópria para Banho"]){
            MyPin.pinColor = MKPinAnnotationColorRed;
        }else{
            MyPin.pinColor = MKPinAnnotationColorPurple;
        }
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        MyPin.rightCalloutAccessoryView = rightButton;
        MyPin.rightCalloutAccessoryView.tag = 1;
    
        UIImageView *carView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"driving.png"]];
    
        UIButton *blueView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44+30)];
        blueView.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
        [blueView addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    
        carView.frame = CGRectMake(7, 16, carView.image.size.width, carView.image.size.height);
        [blueView addSubview:carView];
    
        MyPin.leftCalloutAccessoryView = blueView;
        MyPin.leftCalloutAccessoryView.tag = 2;
        
        
        return MyPin;
    }
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if (control.tag == 1) {
        DetalhesViewController *detailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
        detailsViewController.title = view.annotation.title;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
        detailsViewController.coordinateMap = &(coordinate);
        
        [self presentViewController:detailsViewController animated:YES completion:nil];
        
    }else if ([control tag] == 2){
        CLLocationCoordinate2D coordinateMap = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
        int mode;
        
        //create MKMapItem out of coordinates
        MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinateMap addressDictionary:nil];
        
        MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
        [destination setName:view.annotation.title];
        
        if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
        {
            if(mode == 1)
            {
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];
            }
            if(mode == 2)
            {
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
            }
            if(mode == 3)
            {
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeKey}];
            }
            
        } else{
            NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        }

    }
    
}

-(int)checkForNetwork
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
        {
            return 1;
        }break;
            
        case ReachableViaWWAN:
        {
            NSLog(@"We have a 3G connection");
        }break;
            
        case ReachableViaWiFi:
        {
            NSLog(@"We have WiFi.");
        }break;
            
        default:
            break;
    }
    return 0;
}



-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        self.mapView.showsUserLocation = YES;
    }
}


@end
