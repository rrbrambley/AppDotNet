//
//  ADNOperation.m
//  AppDotNet
//
//  Created by Me on 2/8/13.
//  Copyright (c) 2013 Matt Rubin. All rights reserved.
//

#import "ADNOperation.h"


@interface ADNOperation () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;

@end


@implementation ADNOperation

+ (NSString *)description
{
    return nil;
}

+ (NSString *)method
{
    return @"GET";
}

+ (NSString *)endpoint
{
    return nil;
}

+ (ADNTokenType)tokenType
{
    return ADNTokenTypeNone;
}


#pragma mark - Operation

- (void)main
{
    NSURL *url = [NSURL URLWithString:[@"https://alpha-api.app.net/stream/0/" stringByAppendingString:[self.class endpoint]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = [self.class method];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    self.semaphore = dispatch_semaphore_create(0);
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)finish
{
    dispatch_semaphore_signal(self.semaphore);
}

- (void)handleResponseEnvelope:(ADNResponseEnvelope *)responseEnvelope
                         error:(NSError *)error
{
    if (self.responseHandler) {
        self.responseHandler(responseEnvelope, error);
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    self.responseData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NULL error:&error];
    
    ADNResponseEnvelope *responseEnvelope = nil;
    if (jsonObject)
        responseEnvelope = [ADNResponseEnvelope modelWithExternalRepresentation:jsonObject];
    
    [self handleResponseEnvelope:responseEnvelope error:error];
    [self finish];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self handleResponseEnvelope:nil error:error];
    [self finish];
}

@end