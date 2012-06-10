//
//  NetCore.h
//  iWell
//
//  Created by Wu Weiyi on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetCoreDelegate <NSObject>

- (void)recv:(NSData *)data Error:(NSError *)error Index:(NSNumber *)index;

@end

@interface NetCore : NSObject <NSURLConnectionDelegate> {
	
}

@property (retain, nonatomic) id<NetCoreDelegate> delegate;

- (id)initWithDelegate:(id<NetCoreDelegate>)delegate;

- (NSNumber *)get:(NSURL *)url Data:(NSDictionary *)data;
- (NSNumber *)post:(NSURL *)url Data:(NSDictionary *)data;
- (NSNumber *)open:(NSURL *)url Data:(NSDictionary *)data;

@end
