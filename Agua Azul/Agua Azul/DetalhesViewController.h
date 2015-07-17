//
//  DetalhesViewController.h
//  Agua Azul
//
//  Created by Everson Trindade on 1/22/15.
//  Copyright (c) 2015 TADS. All rights reserved.
//

#import "ViewController.h"

@interface DetalhesViewController : UIViewController

//@property(strong, nonatomic) NSString *titleCV;

@property (strong, nonatomic) IBOutlet UILabel *nomePraia;
@property (strong, nonatomic) IBOutlet UILabel *tempPraia;
@property (strong, nonatomic) IBOutlet UILabel *humiPraia;
@property (strong, nonatomic) IBOutlet UILabel *seTePraia;
@property (strong, nonatomic) IBOutlet UIImageView *iconWeatherPraia;
@property (strong, nonatomic) IBOutlet UILabel *detailPraia;
@property (strong, nonatomic) IBOutlet UILabel *velVentoPraia;

@property (nonatomic) CLLocationCoordinate2D *coordinateMap;

@end
