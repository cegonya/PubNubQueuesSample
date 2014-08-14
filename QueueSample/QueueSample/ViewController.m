//
//  ViewController.m
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ElementObject.h"
#import "QueueCell.h"

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
    [self preloadCells];

    [self loadQueue:0];
}

- (void)loadHeader
{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];

    self.labelMainQueueTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    [self.labelMainQueueTitle setTextColor:[UIColor whiteColor]];
    [self.labelMainQueueTitle setFont:[UIFont boldSystemFontOfSize:17.0]];
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

    self.arrayElements = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] init],
                          [[NSMutableArray alloc] init],
                          [[NSMutableArray alloc] init],
                          nil];

    self.arraySelectedElements = [[NSMutableArray alloc] init];
}

- (void)preloadCells
{
    for (int i = 0; i < self.arrayTableViewQueue.count; i++) {
        UITableView *tableView = [self.arrayTableViewQueue objectAtIndex:i];
        [tableView registerNib:[UINib nibWithNibName:@"QueueCell" bundle:nil] forCellReuseIdentifier:@"QueueCell"];
    }
}

#pragma Actions

- (IBAction)performActionToCurrentSelection:(id)sender
{
    UIActionSheet *actionSheet;

    if (currentQueueNumber == 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                  delegate:nil
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Move To State B", @"Move To State C", nil];
    } else if (currentQueueNumber == 1) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                  delegate:nil
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Move To State A", @"Move To State C", nil];
    } else if (currentQueueNumber == 2) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                  delegate:nil
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Move To State A", @"Move To State B", nil];
    }

    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    NSLog(@"Current Selected Items : %@",self.arraySelectedElements);
}

#pragma - Private

- (void)loadQueue:(NSInteger)number
{
    NSArray   *arrayNamesOfQueues = @[@"STATE A", @"STATE B", @"STATE C"];
    NSInteger numberOfElements    = 0;

    currentQueueNumber            = number;
    self.labelMainQueueTitle.text = [arrayNamesOfQueues objectAtIndex:number];

    if (self.arrayElements && self.arrayElements.count > number) {
        numberOfElements = [[self.arrayElements objectAtIndex:number] count];
    }

    if (numberOfElements == 0) {
        switch (number) {
        case 0:
            [self requestElementsForState:@"A"];
            break;
        case 1:
            [self requestElementsForState:@"B"];
            break;
        case 2:
            [self requestElementsForState:@"C"];
            break;
        default:
            break;
        }
    } else {
        [self cleanSelectionOfElementsOfSpace:number];
    }
}

- (void)cleanSelectionOfElementsOfSpace:(NSInteger)position
{
    NSInteger   numberOfElements = 0;
    UITableView *tableView;

    if (self.arrayElements && self.arrayElements.count > position) {
        numberOfElements = [[self.arrayElements objectAtIndex:position] count];
        tableView        = [self.arrayTableViewQueue objectAtIndex:position];
    }

    for (int i = 0; i < numberOfElements; i++) {
        QueueCell *cell = (QueueCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i
                                                                                           inSection:0]];
        [cell setToSelectedState:FALSE];
    }
}

#pragma mark - Delegates

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfElements = 0;

    if (self.arrayElements && self.arrayElements.count > tableView.tag) {
        numberOfElements = [[self.arrayElements objectAtIndex:tableView.tag] count];
    }

    return numberOfElements;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueueCell     *cell   = [tableView dequeueReusableCellWithIdentifier:@"QueueCell"];
    ElementObject *object = [[self.arrayElements objectAtIndex:tableView.tag] objectAtIndex:indexPath.row];

    [cell loadInformationFromObject:object];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueueCell     *cell   = (QueueCell *)[tableView cellForRowAtIndexPath:indexPath];
    ElementObject *object = [[self.arrayElements objectAtIndex:tableView.tag] objectAtIndex:indexPath.row];

    [cell setToSelectedState:!cell.isSelected];
    [self.arraySelectedElements addObject:object];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat   pageWidth      = self.scrollViewQueue.frame.size.width;
    CGFloat   fractionalPage = self.scrollViewQueue.contentOffset.x / pageWidth;
    NSInteger page           = lround(fractionalPage);

    self.pageControlQueue.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat   pageWidth      = self.scrollViewQueue.frame.size.width;
    CGFloat   fractionalPage = self.scrollViewQueue.contentOffset.x / pageWidth;
    NSInteger page           = lround(fractionalPage);

    if (page != currentQueueNumber) {
        self.pageControlQueue.currentPage = page;
        [self.arraySelectedElements removeAllObjects];
        [self loadQueue:page];
    }
}

#pragma mark - Requests

- (void)requestElementsForState:(NSString *)stateID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://192.168.20.43:8080/service/getCurrentElementsForState"
      parameters:@{@"State":stateID}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         if ([stateID isEqualToString:@"A"]) {
             [self reloadElementsAtIndex:0 withData:[responseObject objectForKey:@"elements"]];
         } else if ([stateID isEqualToString:@"B"]) {
             [self reloadElementsAtIndex:1 withData:[responseObject objectForKey:@"elements"]];
         } else if ([stateID isEqualToString:@"C"]) {
             [self reloadElementsAtIndex:2 withData:[responseObject objectForKey:@"elements"]];
         }
     }   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)reloadElementsAtIndex:(NSInteger)position withData:(NSArray *)elements
{
    if (self.arrayElements && self.arrayElements.count > position) {
        [[self.arrayElements objectAtIndex:position] removeAllObjects];
    }

    for (int i = 0; i < elements.count; i++) {
        ElementObject *object = [[ElementObject alloc] initWithDataFrom:[elements objectAtIndex:i]];
        [object setElementState:position];
        [[self.arrayElements objectAtIndex:position] addObject:object];
    }

    [[self.arrayTableViewQueue objectAtIndex:position] reloadData];
}

@end
