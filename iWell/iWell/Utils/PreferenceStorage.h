//
//  PreferenceStorage.h
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceStorage : NSObject {
	CFDictionaryRef queryBase;
	CFMutableDictionaryRef preferences;
}

- (void)setValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)valueForKey:(NSString *)key;
- (void)removeAllValues;

@end
