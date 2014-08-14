//
//  QueueCell.h
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import <UIKit/UIKit.h>
#import "ElementObject.h"

@interface QueueCell : UITableViewCell

@property (readonly) BOOL                          isSelected;
@property (strong, nonatomic) IBOutlet UILabel     *elementName;
@property (strong, nonatomic) IBOutlet UIImageView *elementSelection;

- (void)setToSelectedState:(BOOL)setSelected;
- (void)loadInformationFromObject:(ElementObject *)object;

@end
