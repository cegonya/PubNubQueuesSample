//
//  ViewController.h
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import <UIKit/UIKit.h>
#import "ElementObject.h"
#import "QueueCell.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
    NSInteger currentQueueNumber;
}

@property (weak, nonatomic) IBOutlet UIScrollView    *scrollViewQueue;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemAction;
@property (strong, nonatomic) NSMutableArray         *arrayTableViewQueue;
@property (strong, nonatomic) NSMutableArray         *arrayElements;
@property (strong, nonatomic) QueueCell              *queueCellSelected;
@property (strong, nonatomic) ElementObject          *elementObjectSelected;
@property (strong, nonatomic) UIPageControl          *pageControlQueue;
@property (strong, nonatomic) UILabel                *labelMainQueueTitle;

@end
