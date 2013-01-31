//
//  PreferenceStorage.m
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceStorage.h"

#import <Security/Security.h>

@implementation PreferenceStorage

- (id)init {
	CFStringRef keys[] = { kSecClass, kSecReturnAttributes, kSecReturnData };
	CFTypeRef values[] = { kSecClassInternetPassword, kCFBooleanTrue, kCFBooleanTrue };
	queryBase = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDataRef data = CFDataCreate(kCFAllocatorDefault, NULL, 0);
	preferences = CFDictionaryCreateMutable(kCFAllocatorDefault, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionaryAddValue(preferences, kSecAttrServer, CFSTR(""));
	CFDictionaryAddValue(preferences, kSecValueData, data);
	CFRelease(data);
	
	CFDictionaryRef result;
	OSStatus status = SecItemCopyMatching(queryBase, (CFTypeRef *)&result);
	if (status == errSecSuccess) {
		CFStringRef value = CFDictionaryGetValue(result, kSecAttrServer);
		if (value != NULL) {
			CFDictionarySetValue(preferences, kSecAttrServer, value);
		}
		data = CFDictionaryGetValue(result, kSecValueData);
		if (data != NULL) {
			CFDictionarySetValue(preferences, kSecValueData, data);
		}
	}
	
	return self;
}

- (void)finalize {
	CFRelease(queryBase);
	CFRelease(preferences);
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
	if ([key isEqualToString:@"address"]) {
		CFDictionarySetValue(preferences, kSecAttrServer, (__bridge CFStringRef)value);
	} else if ([key isEqualToString:@"token"]) {
		CFDictionarySetValue(preferences, kSecValueData, (__bridge CFDataRef)[value dataUsingEncoding:NSUTF8StringEncoding]);
	} else {
		return;
	}
	CFDictionaryRef result;
	OSStatus status = SecItemCopyMatching(queryBase, (CFTypeRef *)&result);
	if (status != errSecSuccess) {
		CFMutableDictionaryRef add = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 10, preferences);
		CFDictionaryAddValue(add, kSecClass, kSecClassInternetPassword);
		status = SecItemAdd(add, (CFTypeRef *)&result);
		CFRelease(add);
	} else {
		CFMutableDictionaryRef update = CFDictionaryCreateMutable(kCFAllocatorDefault, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		CFDictionaryAddValue(update, kSecClass, kSecClassInternetPassword);
		status = SecItemUpdate(update, preferences);
		CFRelease(update);
	}
}

- (NSString *)valueForKey:(NSString *)key {
	if ([key isEqualToString:@"address"]) {
		return (__bridge NSString *)CFDictionaryGetValue(preferences, kSecAttrServer);
	} else if ([key isEqualToString:@"token"]) {
		CFDataRef data = CFDictionaryGetValue(preferences, kSecValueData);
		return [[NSString alloc] initWithBytes:CFDataGetBytePtr(data) length:(NSUInteger)CFDataGetLength(data) encoding:NSUTF8StringEncoding];
	} else {
		return @"";
	}
}

- (void)removeAllValues {
	CFMutableDictionaryRef query = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 10, queryBase);
	CFDictionaryAddValue(query, kSecMatchLimit, kSecMatchLimitAll);
	
	SecItemDelete(query);
	CFRelease(query);
}

@end
