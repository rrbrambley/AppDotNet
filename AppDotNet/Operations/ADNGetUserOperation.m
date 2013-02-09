//
//  ADNGetUserOperation.m
//  AppDotNet
//
//  Created by Me on 2/9/13.
//  Copyright (c) 2013 Matt Rubin. All rights reserved.
//

#import "ADNGetUserOperation.h"


@implementation ADNGetUserOperation

#pragma mark - Endpoint

+ (NSString *)description
{
    return @"Retrieve a User";
}

+ (NSString *)endpoint
{
    return @"users/{user_id}";
}

+ (NSDictionary *)propertyKeysByURITemplateKey {
    return @{@"user_id":@"userId"};
}

@end
