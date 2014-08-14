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
        self.elementName = [data objectForKey:@"elementName"];
        self.elementCode = [data objectForKey:@"elementCode"];
    }
    return self;
}

@end
