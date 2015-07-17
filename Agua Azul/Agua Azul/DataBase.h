//
//  DataBase.h
//  Agua Azul
//
//  Created by Everson Trindade on 12/22/14.
//  Copyright (c) 2014 TADS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>


@interface DataBase : UIViewController

@property (nonatomic) sqlite3 *myDatabase;
@property (strong, nonatomic) NSString *statusOfAddingToDB;
@property (strong, nonatomic) NSString *databasePath;
- (void) createDataBase;
- (void) saveData:(NSString*)nome addLat:(NSString*)latitude addLong:(NSString*)longitude addBaln:(NSString*)balneabilidade addCodPraia:(NSString*)codPraia;
- (void) deleteData;
- (NSMutableArray*) findData;
- (NSMutableArray*) findLatLong:(NSString*)nomePraia;

@end
