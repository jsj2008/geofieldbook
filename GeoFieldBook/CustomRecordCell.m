//
//  CustomRecordCell.m
//  GeoFieldBook
//
//  Created by excel 2011 on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomRecordCell.h"

@implementation CustomRecordCell

@synthesize name = _name;
@synthesize date = _date;
@synthesize time = _time;
@synthesize recordImageView = _recordImageView;
@synthesize type = _type;
@synthesize visibility = _visibility;
@synthesize spinner=_spinner;

@synthesize record=_record;
@synthesize delegate=_delegate;

@synthesize visible=_visible;

- (void)setVisible:(BOOL)visible animated:(BOOL)animated {
    //Set visibility
    self.visibility.highlighted=visible;
    self.visible=visible;
    
    //Show the visibility icon
    [self showVisibilityIconAnimated:animated];
}

- (void)setRecord:(Record *)record {
    _record=record;
    
    //show the name, date and time
    self.name.text=[NSString stringWithFormat:@"%@",record.name];
    self.type.text=[record.class description];
    self.date.text=[Record dateFromNSDate:record.date];
    self.time.text = [Record timeFromNSDate:record.date];
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
    self.visible=self.visibility.highlighted;
    
    //Notify the delegate
    [self.delegate recordCell:self record:self.record visibilityChanged:self.visibility.highlighted];
}

- (void)showVisibilityIconAnimated:(BOOL)animated {
    //Only execute if alpha is 0
    if (!self.visibility.alpha) {
        //Animate if desired
        if (animated) {
            [UIView animateWithDuration:VISIBILITY_ANIMATION_DURATION animations:^(){
                //move the other views
                for (UIView *view in self.contentView.subviews) {
                    if (view!=self.visibility)
                        view.transform=CGAffineTransformTranslate(view.transform, self.visibility.frame.size.width, 0);
                }
                
                //show visibility icon
                self.visibility.alpha=1;
            }];
        } else {
            //Show visibility icon
            self.visibility.alpha=1;
            
            //move the other views
            for (UIView *view in self.contentView.subviews) {
                if (view!=self.visibility)
                    view.transform=CGAffineTransformTranslate(view.transform, self.visibility.frame.size.width, 0);
            }
        }
    }
}

- (void)hideVisibilityIconAnimated:(BOOL)animated {
    //Animate if desired
    if (animated) {
        [UIView animateWithDuration:VISIBILITY_ANIMATION_DURATION animations:^(){
            //move the other views
            for (UIView *view in self.contentView.subviews) {
                if (view!=self.visibility && !CGAffineTransformIsIdentity(view.transform))
                    view.transform=CGAffineTransformTranslate(view.transform, -self.visibility.frame.size.width, 0);
            }
            
            //Hide visibility icon
            self.visibility.alpha=0;
        }];
    } else {
        //Hide visibility icon
        self.visibility.alpha=0;
        
        //move the other views
        for (UIView *view in self.contentView.subviews) {
            if (view!=self.visibility)
                view.transform=CGAffineTransformTranslate(view.transform, -self.visibility.frame.size.width, 0);
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.visibility.alpha) {
        //Notify the delegate if selected and not visible
        if (selected && !self.visible)
            [self visibilityChanged:nil];
        
        //Keep the visibility of the cell
        self.visibility.highlighted=self.visible;
    }
}

@end
