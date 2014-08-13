//
//  ViewController.m
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadHeader];
    [self initializeScrollQueue];
    [self initializeQueues];
}

- (void)loadHeader
{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];

    self.labelMainQueueTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    [self.labelMainQueueTitle setTextColor:[UIColor whiteColor]];
    [self.labelMainQueueTitle setFont:[UIFont boldSystemFontOfSize:15.0]];
    [self.labelMainQueueTitle setTextAlignment:NSTextAlignmentCenter];
    self.labelMainQueueTitle.text = @"STATE A";

    self.pageControlQueue = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 24, 200, 15)];
    [self.pageControlQueue setNumberOfPages:3];

    [viewHeader addSubview:self.labelMainQueueTitle];
    [viewHeader addSubview:self.pageControlQueue];
    self.navigationItem.titleView = viewHeader;
}

- (void)initializeScrollQueue
{
    NSInteger numberOfQueues = 3;
    CGSize    scrollSize     = self.scrollViewQueue.contentSize;
    scrollSize.width = self.view.frame.size.width * numberOfQueues;
    [self.scrollViewQueue setContentSize:scrollSize];
    [self.scrollViewQueue setPagingEnabled:YES];
}

- (void)initializeQueues
{
    NSInteger numberOfQueues = 3;
    self.arrayTableViewQueue = [[NSMutableArray alloc] init];
    for (int i = 0; i < numberOfQueues; i++) {
        UITableView *tableViewQueue = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*i,
                                                                                    0,
                                                                                    self.view.frame.size.width,
                                                                                    self.view.frame.size.height)];
        [tableViewQueue setBackgroundColor:[UIColor clearColor]];
        [tableViewQueue setSeparatorColor:[UIColor clearColor]];
        [tableViewQueue setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tableViewQueue setTag:i];
        [tableViewQueue setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
        [tableViewQueue setDelegate:self];
        [tableViewQueue setDataSource:self];
        [self.arrayTableViewQueue addObject:tableViewQueue];
        [self.scrollViewQueue addSubview:tableViewQueue];
    }
}

#pragma mark - Delegates

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0) {
        return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat   pageWidth      = self.scrollViewQueue.frame.size.width;
    CGFloat   fractionalPage = self.scrollViewQueue.contentOffset.x / pageWidth;
    NSInteger page           = lround(fractionalPage);
    self.pageControlQueue.currentPage = page;
}

@end
