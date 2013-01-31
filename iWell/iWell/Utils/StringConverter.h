//
//  StringConverter.h
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

enum fontcode_t {
	FC_ANSI,
	FC_WIDE,
};

enum colorcode_t {
	CC_BLACK,
	CC_RED,
	CC_GREEN,
	CC_YELLOW,
	CC_BLUE,
	CC_MAGENTA,
	CC_CYAN,
	CC_WHITE,
	CC_BRIGHT_BLACK,
	CC_BRIGHT_RED,
	CC_BRIGHT_GREEN,
	CC_BRIGHT_YELLOW,
	CC_BRIGHT_BLUE,
	CC_BRIGHT_MAGENTA,
	CC_BRIGHT_CYAN,
	CC_BRIGHT_WHITE,
	CC_NONE,
	
	CC_FG_DEFAULT = CC_WHITE,
	CC_BG_DEFAULT = CC_NONE, 
};

struct run_info_t {
	enum fontcode_t fontcode;
	enum colorcode_t backcolorcode;
	BOOL blink;
	BOOL isfirstHalf;
};

@interface StringConverter : NSObject {
	CTFontRef refFont[2];
	CFStringRef fontname[2];
	CGFloat fontWidthFor12pt[2];
	CGFloat fontAscentFor12pt[2];
	CGFloat fontDescentFor12pt[2];
	CGFloat fontLeadingFor12pt[2];
	CGColorRef refColor[16];
	CFArrayRef run_none;
}

@property (retain, nonatomic) NSString *string;
@property (assign, nonatomic) CFMutableArrayRef runs;
@property (assign, nonatomic) CGContextRef context;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) NSUInteger charCountInLine;
@property (assign, nonatomic) NSUInteger lineCount;
@property (assign, atomic)    BOOL blink;
@property (assign, nonatomic) CFMutableArrayRef blinkings;

+ (id)converter;

- (CGSize)draw:(NSString *)string InContext:(CGContextRef)context InRect:(CGRect *)rect;

- (void)setFonts;
- (void)prepare;
- (CGSize)drawInRect:(CGRect *)rect;

@end
