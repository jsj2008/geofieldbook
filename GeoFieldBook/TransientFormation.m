//
//  TransientFormation.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFormation.h"

#import "SettingManager.h"

@interface TransientFormation()

@property (nonatomic,strong) Formation *managedFormation;

@end

@implementation TransientFormation

@synthesize formationName=_formationName;
@synthesize formationSortNumber=_formationSortNumber;
@synthesize formationFolder=_formationFolder;
@synthesize formationColor = _formationColor;
@synthesize colorName = _colorName;

@synthesize managedFormation=_managedFormation;

- (Formation *)saveFormationToManagedObjectContext:(NSManagedObjectContext *)context
{
    //Make sure the formation folder is saved
    [self.formationFolder saveFormationFolderToManagedObjectContext:context completion:^(NSManagedObject *folder){}];
    
    //Query to see if the formation folder is already in the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@ && formationFolder.folderName=%@",self.formationName,self.formationFolder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (results.count)
        return results.lastObject;
    
    //Save to database otherwise
    [self saveToManagedObjectContext:context completion:^(NSManagedObject *formation){}];
    return self.managedFormation;
}

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    //Insert a new formation entity to the database
    Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
    formation.formationName=self.formationName;
    formation.formationSortNumber=self.formationSortNumber;
    formation.formationFolder=[self.formationFolder saveFormationFolderToManagedObjectContext:context completion:completionHandler];
    
    //Set the color name
    formation.colorName=self.colorName;
    
    self.managedFormation=formation;
}

@end
