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
	HTTP_METHOD_MAX,
};

static NSString *methodString[] = { @"GET", @"POST" };

@interface Connection : NSURLConnection
@property (assign, nonatomic) NSUInteger index;
@end

@implementation Connection
@synthesize index;
@end

@interface NetCore ()
@property (strong, nonatomic) NSMutableDictionary *recvData;
@property (strong, nonatomic) NSRunLoop *loop;
@property (assign, nonatomic) NSUInteger nextid;

- (NSUInteger)request:(NSURL *)url Data:(NSDictionary *)data Method:(enum http_method_t)methode;
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

- (NSUInteger)get:(NSURL *)url Data:(NSDictionary *)data
{
	return [self request:url Data:data Method:HTTP_GET];
}

- (NSUInteger)post:(NSURL *)url Data:(NSDictionary *)data
{
	return [self request:url Data:data Method:HTTP_POST];
}

#pragma mark - Private Methods

- (NSUInteger)request:(NSURL *)url Data:(NSDictionary *)data Method:(enum http_method_t)method
{
	if (method >= HTTP_METHOD_MAX) {
		return 0;
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:methodString[method]];
	NSMutableString *dataString = [[NSMutableString alloc] init];
	NSEnumerator *e = [data keyEnumerator];
	if (data != nil) {
		for (NSString *key in e) {
			NSString *value = [data objectForKey:key];
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
	}
	
	Connection *connection = [[Connection alloc] initWithRequest:request delegate:self startImmediately:NO];
	if (connection != nil) {
		connection.index = self.nextid;
		self.nextid = self.nextid + 1;
		[connection scheduleInRunLoop:loop forMode:NSDefaultRunLoopMode];
		[connection start];
		NSNumber *index = [NSNumber numberWithInteger:connection.index];
		NSMutableData *data = [NSMutableData data];
		[self.recvData setObject:data forKey:index];
		return connection.index;
	}
	return 0;
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
	NSNumber *index = [NSNumber numberWithInteger:connection.index];
	NSMutableData *recvData = [self.recvData objectForKey:index];
	[recvData appendData:data];
}

- (void)connection:(Connection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//	[receiver recv:[NSString stringWithFormat:@"Receive response %@", [[response URL] absoluteString]]];
}

- (void)connection:(Connection *)connection didFailWithError:(NSError *)error
{
	NSNumber *index = [NSNumber numberWithInteger:connection.index];
	[self.recvData removeObjectForKey:index];
	[self.delegate recv:nil Error:error Index:connection.index];
}

- (void)connectionDidFinishLoading:(Connection *)connection {
	NSNumber *index = [NSNumber numberWithInteger:connection.index];
	NSMutableData *recvData = [self.recvData objectForKey:index];
	[self.delegate recv:recvData Error:nil Index:connection.index];
	[self.recvData removeObjectForKey:index];
}

- (void)connection:(Connection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	//	[receiver recv:@"Challenging"];
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
