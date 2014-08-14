//
//  QueueCell.m
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import "QueueCell.h"

@implementation QueueCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setToSelectedState:(BOOL)setSelected
{
    if (setSelected) {
        [self.elementSelection setImage:[UIImage imageNamed:@"selected.png"]];
    } else {
        [self.elementSelection setImage:[UIImage imageNamed:@"unselected.png"]];
    }
}

@end
