//
//  ElementObject.m
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import "ElementObject.h"

@implementation ElementObject

- (id)initWithDataFrom:(NSDictionary *)data
{
    self = [super init];

    if (self) {
        self.elementName = [NSString stringWithFormat:@"%@",[data objectForKey:@"name"]];
        self.elementCode = [NSString stringWithFormat:@"%@",[data objectForKey:@"id"]];
    }
    return self;
}

@end
