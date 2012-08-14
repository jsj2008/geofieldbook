//
//  TransientContact.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientContact.h"

@implementation TransientContact

@synthesize lowerFormation=_lowerFormation;
@synthesize upperFormation=_upperFormation;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    //Create a contact record
    self.nsManagedRecord=[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
    
    //Call super to populate the common record info
    [super saveToManagedObjectContext:context completion:completionHandler];
    
    //Populate formations
    Contact *record=(Contact *)self.nsManagedRecord;
    Formation *lowerFormation=[self.lowerFormation saveFormationToManagedObjectContext:context];
    Formation *upperFormation=[self.upperFormation saveFormationToManagedObjectContext:context];
    record.lowerFormation=lowerFormation;
    record.upperFormation=upperFormation;
    record.lowerFormationName=lowerFormation.formationName;
    record.upperFormationName=upperFormation.formationName;
    record.folder.formationFolder=lowerFormation.formationFolder;
 
    //Call completion handler
    completionHandler(self.nsManagedRecord);
}

@end
