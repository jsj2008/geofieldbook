//
//  Folder+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder+Modification.h"

@implementation Folder (Modification)

- (BOOL)changeFolderNameTo:(NSString *)newName {
    //Query the database to see if the any folder with the new name already exists
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",newName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is one result, return NO
    if ([results count])
        return NO;
    
    self.folderName=newName;
    return YES;
}

@end