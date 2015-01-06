//
//  NSDictionary+KeyExists.m
//  Test
//
//  Created by Om Prakash on 3/17/10.
//  Copyright 2010 . All rights reserved.
//

#import "NSDictionary+KeyExists.h"


@implementation NSDictionary (KeyExists)

- (BOOL) keyExists:(NSString *) key
{
	return [self valueForKey:key] != nil;
}

- (BOOL) valueForKeyIsNull:(NSString *) key
{
	return ![self keyExists:key] || ((NSNull *)[self valueForKey:key] == [NSNull null]);
}
@end
