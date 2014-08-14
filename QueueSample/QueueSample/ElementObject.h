//
//  ElementObject.h
//  QueueSample
//
//  Created by Santex on 8/13/14.
//
//

#import <Foundation/Foundation.h>

@interface ElementObject : NSObject

@property(strong, nonatomic) NSString *elementName;
@property(strong, nonatomic) NSString *elementCode;
@property(readwrite) NSInteger        elementState;

- (id)initWithDataFrom:(NSDictionary *)data;

@end
