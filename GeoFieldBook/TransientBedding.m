//
//  TransientBedding.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientBedding.h"

@implementation TransientBedding

@synthesize formation=_formation;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    //Create a bedding record
    self.nsManagedRecord=[NSEntityDescription insertNewObjectForEntityForName:@"Bedding" inManagedObjectContext:context];
    
    //Call super to populate the common record info
    [super saveToManagedObjectContext:context completion:completionHandler];
    
    //Populate formation
    Bedding *record=(Bedding *)self.nsManagedRecord;
    Formation *formation=[self.formation saveFormationToManagedObjectContext:context];
    record.formation=formation;
    record.formationName=formation.formationName;
    
    //Call completion handler
    completionHandler(self.nsManagedRecord);
}


@end
