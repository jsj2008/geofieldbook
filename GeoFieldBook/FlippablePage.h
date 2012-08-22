//
//  FlippablePage.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlippablePage <NSObject>

- (BOOL)swipeToFlip;
- (BOOL)tapToFlip;
- (BOOL)panToFlip;

@end
