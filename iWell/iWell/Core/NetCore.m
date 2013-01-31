//
//  NetCore.m
//  iWell
//
//  Created by Wu Weiyi on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetCore.h"

enum http_method_t {
	HTTP_GET,
	HTTP_POST,
	HTTP_EXTERNAL,
	HTTP_METHOD_MAX,
};

static NSString *methodString[] = { @"GET", @"POST" };

@interface Connection : NSURLConnection
@property (strong, nonatomic) NSNumber *index;
@end

@implementation Connection
@synthesize index;
@end

@interface NetCore ()
@property (strong, nonatomic) NSMutableDictionary *recvData;
@property (strong, nonatomic) NSRunLoop *loop;
@property (assign, nonatomic) NSUInteger nextid;

- (NSNumber *)request:(NSURL *)url Data:(NSDictionary *)data Method:(enum http_method_t)methode;
- (NSString *)encode:(NSString *)value;
- (void)run;
@end

@implementation NetCore

@synthesize delegate = _delegate;
@synthesize recvData = _recvData;
@synthesize loop;
@synthesize nextid;

#pragma mark - Public Methods

- (id)initWithDelegate:(id<NetCoreDelegate>)delegate
{
	self.recvData = [NSMutableDictionary dictionary];
	self.nextid = 1;
	self.delegate = delegate;
	[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
	return self;
}

- (NSNumber *)get:(NSURL *)url Data:(NSDictionary *)data
{
	return [self request:url Data:data Method:HTTP_GET];
}

- (NSNumber *)post:(NSURL *)url Data:(NSDictionary *)data
{
	return [self request:url Data:data Method:HTTP_POST];
}

- (NSNumber *)open:(NSURL *)url Data:(NSDictionary *)data
{
	return [self request:url Data:data Method:HTTP_EXTERNAL];
}

#pragma mark - Private Methods

- (NSNumber *)request:(NSURL *)url Data:(NSDictionary *)data Method:(enum http_method_t)method
{
	if (method >= HTTP_METHOD_MAX) {
		return nil;
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:methodString[method]];
	NSMutableString *dataString = [[NSMutableString alloc] init];
	NSEnumerator *e = [data keyEnumerator];
	if (data != nil) {
		for (NSString *key in e) {
			NSString *value = [NSString stringWithFormat:@"%@", [data valueForKey:key]];
			[dataString appendFormat:@"%@=%@&", [self encode:key], [self encode:value]];
		}
	}
	[dataString deleteCharactersInRange:NSMakeRange([dataString length] - 1, 1)];
	
	if (method == HTTP_GET) {
		if ([dataString length] > 0) {
			[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [url absoluteString], dataString]]];
		}
	} else if (method == HTTP_POST) {
		NSData *postData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
		[request setValue:[NSString stringWithFormat:@"%u", [postData length]] forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];
	} else if (method == HTTP_EXTERNAL) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [url absoluteString], dataString]]];
		return nil;
	}
	
	Connection *connection = [[Connection alloc] initWithRequest:request delegate:self startImmediately:NO];
	if (connection != nil) {
		connection.index = [NSNumber numberWithUnsignedInteger:self.nextid];
		self.nextid = self.nextid + 1;
		[connection scheduleInRunLoop:loop forMode:NSDefaultRunLoopMode];
		[connection start];
		NSMutableData *recvData = [NSMutableData data];
		[self.recvData setObject:recvData forKey:connection.index];
		return connection.index;
	}
	return nil;
}

- (NSString *)encode:(NSString *)value
{
	return [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)run
{
	@autoreleasepool {
		loop = [NSRunLoop currentRunLoop];
		NSPort *port = [NSPort port];
		[loop addPort:port forMode:NSDefaultRunLoopMode];
		[loop run];
	}
}

#pragma mark - Delegate Methods

- (void)connection:(Connection *)connection didReceiveData:(NSData *)data
{
	NSMutableData *recvData = [self.recvData objectForKey:connection.index];
	[recvData appendData:data];
}

- (void)connection:(Connection *)connection didReceiveResponse:(NSURLResponse *)response
{
	long long len = [response expectedContentLength];
	NSURL *url = [response URL];
	NSMutableData *recvData = [self.recvData objectForKey:connection.index];
	[recvData setLength:0];
	//	[receiver recv:[NSString stringWithFormat:@"Receive response %@", [[response URL] absoluteString]]];
}

- (void)connection:(Connection *)connection didFailWithError:(NSError *)error
{
	[self.recvData removeObjectForKey:connection.index];
	[self.delegate recv:nil Error:error Index:connection.index];
}

- (void)connectionDidFinishLoading:(Connection *)connection {
	NSMutableData *recvData = [self.recvData objectForKey:connection.index];
	[self.delegate recv:recvData Error:nil Index:connection.index];
	[self.recvData removeObjectForKey:connection.index];
}

- (void)connection:(Connection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	//	[receiver recv:@"Challenging"];
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
