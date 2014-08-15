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
#import "CRToast.h"

static NSString *kChannelIdentifier_CrazyColors = @"crazycolors-channel";

static NSString *kURLGetCurrentElementForState = @"http://192.168.21.61:8080/PubNubPoc/queueService/getCurrentElementForState/stateCode";
static NSString *kURLMoveElementToState        = @"http://192.168.21.61:8080/PubNubPoc/queueService/moveElementToState/elementCode/stateCode";

@interface ViewController (){
    PNChannel *channel;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setUpPubNub];
    [self setUpNotifications];

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

- (void)setUpPubNub
{
    channel = [PNChannel channelWithName:kChannelIdentifier_CrazyColors
                   shouldObservePresence:YES];
    [PubNub subscribeOnChannel:channel];
    [PubNub enablePresenceObservationForChannel:channel];
}

- (void)setUpNotifications
{
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:
     ^(PNMessage *message)
     {
         NSDictionary *elementHasChangedContent = [message.message objectForKey:@"ElementHasChanged"];
         if (elementHasChangedContent) {
             NSString *elementMessage = [NSString stringWithFormat:@"ELEMENT %@ HAS CHANGED!",
                                         [elementHasChangedContent objectForKey:@"elementId"]];
             //NSInteger queueFrom = [[elementHasChangedContent objectForKey:@"previousStateId"] integerValue];
             NSInteger queueTo = [[elementHasChangedContent objectForKey:@"newStateId"] integerValue];
             
             [self showNotificationWithMessage:elementMessage];
             [self requestElementsForState:queueTo-1];
         }
     }];
}

#pragma Actions

- (IBAction)performActionToCurrentSelection:(id)sender
{
    UIActionSheet *actionSheet;

    if (currentQueueNumber == 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Move To State B", @"Move To State C", nil];
    } else if (currentQueueNumber == 1) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Move To State A", @"Move To State C", nil];
    } else if (currentQueueNumber == 2) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Move To State A", @"Move To State B", nil];
    }

    actionSheet.tag = currentQueueNumber;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];

    NSLog(@"Current Selected Items : %@", self.arraySelectedElements);
}

#pragma - Private

- (void)showNotificationWithMessage:(NSString *)message
{
    NSDictionary *options = @{
        kCRToastTextKey : message,
        kCRToastSubtitleTextKey : @"Updating...",
        kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
        kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
        kCRToastSubtitleTextAlignmentKey : @(NSTextAlignmentLeft),
        kCRToastBackgroundColorKey : [UIColor colorWithRed:255.0/255.0
                                                     green:64.0/255.0
                                                      blue:64.0/255.0
                                                     alpha:1.0],
        kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeSpring),
        kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
        kCRToastImageKey : [UIImage imageNamed:@"alert_icon.png"],
        kCRToastTimeIntervalKey : @(4.0)
    };

    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
         NSLog(@"Completed");
     }];
}

- (void)loadQueue:(NSInteger)number
{
    NSArray   *arrayNamesOfQueues = @[@"STATE A", @"STATE B", @"STATE C"];
    NSInteger numberOfElements    = 0;

    self.labelMainQueueTitle.text = [arrayNamesOfQueues objectAtIndex:currentQueueNumber];

    if (self.arrayElements && self.arrayElements.count > number) {
        numberOfElements = [[self.arrayElements objectAtIndex:number] count];
    }

    if (numberOfElements == 0) {
        [self requestElementsForState:number];
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
        currentQueueNumber                = page;
        self.pageControlQueue.currentPage = page;
        [self.arraySelectedElements removeAllObjects];
        [self loadQueue:page];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger integerQueueTo = 0;
    
    if (currentQueueNumber == 0) {
        integerQueueTo = (buttonIndex == 0) ? 2 : 3;
    } else if (currentQueueNumber == 1) {
        integerQueueTo = (buttonIndex == 0) ? 1 : 3;
    } else if (currentQueueNumber == 2) {
        integerQueueTo = (buttonIndex == 0) ? 1 : 2;
    }
    
    if (integerQueueTo != 0) {
        [self requestChangeOfElement:[[self.arraySelectedElements objectAtIndex:0] elementCode]
                             toState:integerQueueTo];
    }
}

#pragma mark - Requests

- (void)requestElementsForState:(NSInteger)stateID
{
    AFHTTPRequestOperationManager *manager       = [AFHTTPRequestOperationManager manager];
    NSString                      *stringStateID = [NSString stringWithFormat:@"%d", stateID+1];
    NSString                      *stringURL     = [kURLGetCurrentElementForState stringByReplacingOccurrencesOfString:@"stateCode"
                                                                                                            withString:stringStateID];
    [manager GET:stringURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         [self reloadElementsAtIndex:stateID withData:[[responseObject objectForKey:@"State"] objectForKey:@"elements"]];
     }   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)requestChangeOfElement:(NSString *)elementID toState:(NSInteger)stateID
{
    AFHTTPRequestOperationManager *manager       = [AFHTTPRequestOperationManager manager];
    NSString                      *stringStateID = [NSString stringWithFormat:@"%d", stateID];
    NSString                      *stringURL;

    stringURL = [kURLMoveElementToState stringByReplacingOccurrencesOfString:@"stateCode"
                                                                  withString:stringStateID];
    stringURL = [stringURL stringByReplacingOccurrencesOfString:@"elementCode"
                                                                  withString:elementID];

    [manager GET:stringURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
             
             NSMutableArray *arrayCurrentElements = [self.arrayElements objectAtIndex:currentQueueNumber];
             [arrayCurrentElements removeObject:[self.arraySelectedElements objectAtIndex:0]];
             [[self.arrayTableViewQueue objectAtIndex:currentQueueNumber] reloadData];
             
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
