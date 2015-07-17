//
//  CustomAnnotation.m
//  Agua Azul
//
//  Created by Everson Trindade on 1/21/15.
//  Copyright (c) 2015 TADS. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

@synthesize coordinate,title,subtitle;

-(void) dealloc{
    self.title = nil;
    self.subtitle = nil;
    
}




@end
