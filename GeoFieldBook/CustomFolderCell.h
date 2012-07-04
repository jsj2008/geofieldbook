//
//  CustomFolderCell.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomFolderCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subTitie;
@property (nonatomic,weak) IBOutlet UIView *checkBox;
@property (nonatomic,weak) IBOutlet UIImageView *image;

@end
