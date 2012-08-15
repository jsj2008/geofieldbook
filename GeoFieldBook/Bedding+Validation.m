//
//  Bedding+Validation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Bedding+Validation.h"

@implementation Bedding (Validation)

- (NSArray *)validatesMandatoryPresenceOfRecordInfo:(NSDictionary *)recordInfo {
    //Create an array to hold the keys that correspond to missing or invalid mandatory information
    NSMutableArray *invalidInformationKeys=[super validatesMandatoryPresenceOfRecordInfo:recordInfo].mutableCopy;
    
    //Validates dip direction, if there is strike or dip, but there is no dip direction => Validations fail
    NSString *strike=[recordInfo objectForKey:RECORD_STRIKE];
    NSString *dip=[recordInfo objectForKey:RECORD_DIP];
    NSString *dipDirection=[recordInfo objectForKey:RECORD_DIP_DIRECTION];
    if ((strike.length || dip.length) && !dipDirection.length)
        [invalidInformationKeys addObject:RECORD_DIP_DIRECTION];    
    return invalidInformationKeys.copy;
}

@end
