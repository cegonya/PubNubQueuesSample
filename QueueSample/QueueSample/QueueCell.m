//
//  QueueCell.m
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import "QueueCell.h"

@implementation QueueCell

- (void)setToSelectedState:(BOOL)setSelected
{
    if (setSelected) {
        [self.elementSelection setImage:[UIImage imageNamed:@"selected.png"]];
        _isSelected = true;
    } else {
        [self.elementSelection setImage:[UIImage imageNamed:@"unselected.png"]];
        _isSelected = false;
    }
}

- (void)loadInformationFromObject:(ElementObject *)object
{
    self.elementName.text = [NSString stringWithFormat:@"%@ - %@",object.elementCode,object.elementName];
    [self setToSelectedState:false];
}

@end
