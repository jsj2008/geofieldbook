//
//  CustomFolderCell.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomFolderCell.h"

@implementation CustomFolderCell

@synthesize title=_title;
@synthesize subtitle=_subtitle;
@synthesize visibility=_visibility;

@synthesize folder=_folder;

@synthesize delegate=_delegate;

- (void)setFolder:(Folder *)folder {
    _folder=folder;
    
    //Setup the title and subtitle of the cell
    self.title.text=folder.folderName;
    NSString *recordCounter=[folder.records count]>1 ? @"Records" : @"Record";
    self.subtitle.text=[NSString stringWithFormat:@"%d %@",[folder.records count],recordCounter];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Add gesture recognizer to the checkbox
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] 
                                   initWithTarget:self action:@selector(visibilityChanged:)];
    [self.visibility addGestureRecognizer:tgr];
    
    //Hide the visibility icon initially
    self.visibility.alpha=0;
}

- (void)visibilityChanged:(UITapGestureRecognizer *)tgr {
    //Toggle visibility
    self.visibility.highlighted=!self.visibility.highlighted;
        
    //Notify the delegate
    [self.delegate folderCell:self folder:self.folder visibilityChanged:self.visibility.highlighted];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated {
    //Set visibility
    self.visibility.highlighted=visible;
    
    //Show the visibility icon
    [self showVisibilityIconAnimated:animated];
}

- (void)showVisibilityIconAnimated:(BOOL)animated {
    //Only execute if alpha is 0
    if (!self.visibility.alpha) {
        //Animate if desired
        if (animated) {
            [UIView animateWithDuration:VISIBILITY_ANIMATION_DURATION animations:^{
                //move the title and subtitle
                self.title.transform=CGAffineTransformTranslate(self.title.transform, self.visibility.frame.size.width, 0);
                self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, self.visibility.frame.size.width, 0);
                
                //show visibility icon
                self.visibility.alpha=1;
            }];
        } else {
            //Show visibility icon
            self.visibility.alpha=1;
            
            //move the title and subtitle
            self.title.transform=CGAffineTransformTranslate(self.title.transform, self.visibility.frame.size.width, 0);
            self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, self.visibility.frame.size.width, 0);
        }
    }
}

- (void)hideVisibilityIconAnimated:(BOOL)animated {
    //Animate if desired
    if (animated) {
        [UIView animateWithDuration:VISIBILITY_ANIMATION_DURATION animations:^(){
            //Move the title and subtitle only if they are not in their original positions (before visibility icon is showed) 
            if (!CGAffineTransformIsIdentity(self.title.transform))
                self.title.transform=CGAffineTransformTranslate(self.title.transform, -self.visibility.frame.size.width, 0);
            if (!CGAffineTransformIsIdentity(self.subtitle.transform))
                self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, -self.visibility.frame.size.width, 0);
            
            //Hide visibility icon
            self.visibility.alpha=0;
        }];
    } else {
        //Hide visibility icon
        self.visibility.alpha=0;
        
        //Move the title and subtitle only if they are not in their original positions (before visibility icon is showed) 
        if (!CGAffineTransformIsIdentity(self.title.transform))
            self.title.transform=CGAffineTransformTranslate(self.title.transform, -self.visibility.frame.size.width, 0);
        if (!CGAffineTransformIsIdentity(self.subtitle.transform))
            self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, -self.visibility.frame.size.width, 0);
    }
}

@end
