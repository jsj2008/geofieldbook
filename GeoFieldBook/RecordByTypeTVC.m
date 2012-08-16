//
//  RecordByTypeTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordByTypeTVC.h"

@interface RecordByTypeTVC ()

@end

@implementation RecordByTypeTVC

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",self.folder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

@end
