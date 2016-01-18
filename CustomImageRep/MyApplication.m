//
//  MyApplication.m
//  CustomImageRep
//
//  Created by Freddie Tilley on 18-01-16.
//  Copyright © 2016 Impending. All rights reserved.
//

#import "MyApplication.h"
#import "IMZorqImageRep.h"

@implementation MyApplication

+ (void)initialize
{
    [NSImageRep registerImageRepClass: [IMZorqImageRep class]];
}

@end
