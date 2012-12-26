//
//  ADNHelper.m
//  AppDotNet
//
//  Created by Me on 12/16/12.
//  Copyright (c) 2012 Matt Rubin. All rights reserved.
//

#import "ADNHelper.h"

#import "NSDictionary+ADN.h"


@implementation ADNHelper

+ (NSDictionary*)dictionaryFromJSONData:(NSData *)data error:(NSError **)errorPointer
{
    NSError *error;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (!error) {
        if ([JSONObject isKindOfClass:[NSDictionary class]]) {
            return (NSDictionary*)JSONObject;
        } else {
            if (errorPointer)
                *errorPointer = [NSError errorWithDomain:@"ADNHelper" code:0 userInfo:[NSDictionary dictionaryWithObject:@"JSON object is not a dictionary" forKey:NSLocalizedDescriptionKey]];
            return nil;
        }
    } else {
        if (errorPointer)
            *errorPointer = error;
        return nil;
    }
}

+ (NSData*)JSONDataFromDictionary:(NSDictionary*)dictionary
{
    NSError *error;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0/*NSJSONWritingPrettyPrinted*/ error:&error];
    
    if (!error) {
        return JSONData;
    } else {
        NSLog(@"ERROR: %@", error);
        return nil;
    }
}


+ (id)responseContentFromEnvelope:(NSDictionary *)responseEnvelope error:(NSError **)error
{
    NSDictionary *meta = [responseEnvelope dictionaryForKey:KEY_META];
    NSInteger code = [meta integerForKey:KEY_CODE];
    
    if (code == 200) {
        return [responseEnvelope objectForKey:KEY_DATA];
    } else {
        NSString * errorMessage = [meta stringForKey:@"error_message"];
        if (error) {
            *error = [NSError errorWithDomain:@"ADN" code:code userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }

}

+ (NSDateFormatter*)dateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    return dateFormatter;
}

@end
