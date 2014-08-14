//
//  ViewController.h
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewQueue;
@property (strong, nonatomic) NSMutableArray      *arrayTableViewQueue;
@property (strong, nonatomic) UIPageControl       *pageControlQueue;
@property (strong, nonatomic) UILabel             *labelMainQueueTitle;

@property (strong, nonatomic) NSMutableArray *arrayElements;
@property (strong, nonatomic) NSMutableArray *arrayStateA;
@property (strong, nonatomic) NSMutableArray *arrayStateB;
@property (strong, nonatomic) NSMutableArray *arrayStateC;

@end
