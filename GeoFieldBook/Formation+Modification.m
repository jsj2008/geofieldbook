//
//  Formation+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Modification.h"

#import "Formation_Folder.h"
#import "Formation+DictionaryKeys.h"

#import "TextInputFilter.h"

@implementation Formation (Modification)

- (BOOL)updateFormationWithFormationInfo:(NSDictionary *)formationInfo {
    //Get the formation name and color from the info dictionary
    NSString *formationName=[formationInfo objectForKey:GeoFormationName];
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    NSString *color=[formationInfo objectForKey:GeoFormationColor];

    //if the name is nil, return NO
    if (!formationName)
        return NO;
    
    //Filter formation name
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    
    //If the new name is different from the old name, check for name duplication
    if (![formationName isEqualToString:self.formationName]) {
        //Query the database to see if the any formation with the new name already exists
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@ && formationFolder.folderName=%@",formationName,self.formationFolder.folderName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
        
        //if there is one result, return NO
        if (results.count)
            return NO;
    }
    
    //Update the formation name
    self.formationName=formationName;
    self.color=color;
        
    return YES;
}

@end
