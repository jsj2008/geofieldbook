//
//  SelectFormationFolderTVCDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SelectFormationFolderTVC;
@class Formation_Folder;

@protocol SelectFormationFolderTVCDelegate <NSObject>

- (void)formationFolderSelectTVC:(SelectFormationFolderTVC *)sender userDidSelectFormationFolder:(Formation_Folder *)formationFolder;

@end
