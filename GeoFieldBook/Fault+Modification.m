//
//  Fault+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Fault+Modification.h"
#import "Formation.h"
#import "Record+DictionaryKeys.h"
#import "Record+Modification.h"

@implementation Fault (Modification)

- (void)updateWithNewRecordInfo:(NSDictionary *)recordInfo {
    [super updateWithNewRecordInfo:recordInfo];

    //Update trend and plunge
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    self.trend=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_TREND]];
    self.plunge=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_PLUNGE]];
    
    //If the formation name is nil, nilly this record's formation
    NSString *formationName=[recordInfo objectForKey:RECORD_FORMATION];
    if (!formationName.length) {
        self.formation=nil;
        self.formationName=@"";
    }
    
    //Else, update the formation if it exists in database
    else {
        NSString *formationFolderName=[recordInfo objectForKey:RECORD_FORMATION_FOLDER];
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@ && formationFolder.folderName=%@",formationName,formationFolderName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
        if ([results count]) {
            Formation *formation=[results lastObject];
            self.formation=formation;
            self.formationName=formation.formationName;
        }
    }
}

@end
