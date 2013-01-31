//
//  StringConverter.m
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StringConverter.h"

#define GBK_HACK

@implementation StringConverter

@synthesize string = _string;
@synthesize runs = _runs;
@synthesize context = _context;
@synthesize width = _width;
@synthesize charCountInLine = _charCountInLine;
@synthesize lineCount = _lineCount;
@synthesize blink = _blink;
@synthesize blinkings = _blinkings;

+ (id)converter {
	static StringConverter *c = NULL;
	if (c == NULL) {
		c = [[StringConverter alloc] init];
	}
	return c;
}

- (id)init {
	CGFloat component[16][4] = {
		{0.0f, 0.0f, 0.0f, 1.f}, {0.8f, 0.0f, 0.0f, 1.f}, {0.0f, 0.8f, 0.0f, 1.f}, {0.8f, 0.8f, 0.0f, 1.f},
		{0.0f, 0.0f, 0.9f, 1.f}, {0.8f, 0.0f, 0.8f, 1.f}, {0.0f, 0.8f, 0.8f, 1.f}, {0.9f, 0.9f, 0.9f, 1.f},
		{0.5f, 0.5f, 0.5f, 1.f}, {1.0f, 0.0f, 0.0f, 1.f}, {0.0f, 1.0f, 0.0f, 1.f}, {1.0f, 1.0f, 0.0f, 1.f},
		{0.3f, 0.3f, 1.0f, 1.f}, {1.0f, 0.0f, 1.0f, 1.f}, {0.0f, 1.0f, 1.0f, 1.f}, {1.0f, 1.0f, 1.0f, 1.f},
	};
	for (int i = 0; i < 16; i++) {
		refColor[i] = CGColorCreate(CGColorSpaceCreateDeviceRGB(), component[i]);
	}
	
	CFStringRef ansiStr = CFSTR("m");
	CFStringRef wideStr = CFSTR("国");
	const CFStringRef key[1] = { kCTFontAttributeName };
	CFTypeRef value[1];
	CFDictionaryRef attrib;
	CFAttributedStringRef astr;
	CTLineRef line;
	CTRunRef run;
	
	// ANSI
	fontname[0] = CFSTR("Courier");
	refFont[0] = CTFontCreateWithName(fontname[0], 12, NULL);
	value[0] = refFont[0];
	attrib = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&value, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	astr = CFAttributedStringCreate(kCFAllocatorDefault, ansiStr, attrib);
	CFRelease(attrib);
	line = CTLineCreateWithAttributedString(astr);
	run = (CTRunRef)CFArrayGetValueAtIndex(CTLineGetGlyphRuns(line), 0);
	fontWidthFor12pt[0] = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), fontAscentFor12pt, fontDescentFor12pt, fontLeadingFor12pt);
	CFRelease(line);
	CFRelease(astr);
	
	// WIDE
	fontname[1] = CFSTR("STHeitiSC-Light");
	refFont[1] = CTFontCreateWithName(fontname[1], 12, NULL);
	value[0] = refFont[1];
	attrib = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&value, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	astr = CFAttributedStringCreate(kCFAllocatorDefault, wideStr, attrib);
	CFRelease(attrib);
	line = CTLineCreateWithAttributedString(astr);
	run = (CTRunRef)CFArrayGetValueAtIndex(CTLineGetGlyphRuns(line), 0);
	fontWidthFor12pt[1] = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), fontAscentFor12pt + 1, fontDescentFor12pt + 1, fontLeadingFor12pt + 1);
	CFRelease(line);
	CFRelease(astr);
	
	self.lineCount = 2000;
	self.runs = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
	self.blinkings = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
	
	run_none = CFArrayCreate(kCFAllocatorDefault, NULL, 0, &kCFTypeArrayCallBacks);
	return self;
}

- (CGSize)draw:(NSString *)string InContext:(CGContextRef)context InRect:(CGRect *)rect {
	if (self.context != context) {
		self.context = context;
	}
	if (self.width != rect->size.width) {
		self.width = rect->size.width;
		[self setFonts];
		// reset string to invalidate runs
		self.string = nil;
	}
	if (self.string != string) {
		self.string = string;
		[self prepare];
	}
	return [self drawInRect:rect];
}

- (void)setFonts {
	// ANSI
	CFRelease(refFont[0]);
	refFont[0] = CTFontCreateWithName(fontname[0], self.width / self.charCountInLine / fontWidthFor12pt[0] * 12, NULL);
	
	// WIDE
	CFRelease(refFont[1]);
	refFont[1] = CTFontCreateWithName(fontname[1], self.width / self.charCountInLine * 2 / fontWidthFor12pt[1] * 12, NULL);
}

- (void)prepare {
	enum mode_t {
		NORMAL,
		ESCAPE,
	};
	enum mode_t mode = NORMAL;
	enum fontcode_t fontcode = FC_ANSI;
	NSUInteger controls[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	NSUInteger cnt = 0;
	enum colorcode_t colorcode = CC_FG_DEFAULT;
	enum colorcode_t backcolorcode = CC_BG_DEFAULT;
	BOOL blink = NO;
#ifdef GBK_HACK
	BOOL need_hack = NO;
	enum colorcode_t hack_colorcode, hack_backcolorcode;
	BOOL hack_blink;
#endif
	NSUInteger x = 0, y = 0;
	const CFStringRef key[2] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
	CFTypeRef value[2];
	CFDictionaryRef attrib;
	CFStringRef str;
	CFAttributedStringRef astr;
	CTLineRef line;
	CTRunRef run;
	struct run_info_t runInfo;
	CFDataRef data;
	CFTypeRef info[2];
	CFArrayRef array;
	CFMutableArrayRef runs;
	
	CFArrayRemoveAllValues(self.runs);
	
	for (NSUInteger i = 0; i < [self.string length]; i++) {
		unichar ch = [self.string characterAtIndex:i];
		if (mode == ESCAPE) {
			switch (ch) {
				case '[':
					cnt = 0;
					break;
				case '0':case '1':case '2':case '3':case '4':
				case '5':case '6':case '7':case '8':case '9':
					// read digits
					controls[cnt] = controls[cnt] * 10 + (ch - '0');
					break;
				case ';':
					// push parameter
					cnt++;
					break;
				case 'm':
					// change color
				{
					cnt++;
					for (NSUInteger j = 0; j < cnt; j++) {
						NSUInteger code = controls[j];
						if (code == 0) {
							colorcode = CC_FG_DEFAULT;
							backcolorcode = CC_BG_DEFAULT;
							blink = NO;
						} else if (code == 1) {
							colorcode |= 8;
						} else if (code == 5) {
							blink = YES;
						} else if (code >= 30 && code <= 37) {
							colorcode = (colorcode & 8) | (enum colorcode_t)(code - 30);
						} else if (code >= 40 && code <= 47) {
							backcolorcode = (enum colorcode_t)(code - 40);
						}
#ifdef GBK_HACK
						else if (code == 50) {
							need_hack = YES;
							hack_colorcode = colorcode;
							hack_backcolorcode = backcolorcode;
							hack_blink = blink;
						}
#endif
						controls[j] = 0;
					}
					mode = NORMAL;
					break;
				}
				case 'A':
					//move up
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					if (y < code) {
						y = 0;
					} else {
						y -= code;
					}
					mode = NORMAL;
					break; 
				}
				case 'B':
					//move down
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					y += code;
					if (y > self.lineCount) {
						y = self.lineCount;
					}
					mode = NORMAL;
					break; 
				}
				case 'C':
					//move forward
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					x += code;
					if (x > self.charCountInLine) {
						x = self.charCountInLine;
					}
					mode = NORMAL;
					break; 
				}
				case 'D':
					//move back
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					if (x < code) {
						x = 0;
					} else {
						x -= code;
					}
					mode = NORMAL;
					break; 
				}
				case 'E':
					//move down to line start
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					y += code;
					if (y > self.lineCount) {
						y = self.lineCount;
					}
					x = 0;
					mode = NORMAL;
					break; 
				}
				case 'F':
					//move up to line start
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					if (y < code) {
						y = 0;
					} else {
						y -= code;
					}
					x = 0;
					mode = NORMAL;
					break; 
				}
				case 'G':
					//move to column
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code;
					for (NSUInteger j = 0; j < cnt; j++) {
						code = controls[j];
						controls[j] = 0;
					}
					if (code == 0) {
						code = 1;
					}
					x = code - 1;
					if (x > self.charCountInLine) {
						x = self.charCountInLine;
					}
					mode = NORMAL;
					break; 
				}
				case 'H':
					//move to position
				{
#ifdef GBK_HACK
					need_hack = NO;
#endif
					cnt++;
					NSUInteger code1 = 0, code2 = 0;
					for (NSUInteger j = 0; j < cnt; j++) {
						code1 = code2;
						code2 = controls[j];
						controls[j] = 0;
					}
					if (code1 == 0) {
						code1 = 1;
					}
					y = code1 - 1;
					if (y > self.lineCount) {
						y = self.lineCount;
					}
					if (code2 == 0) {
						code2 = 1;
					}
					x = code2 - 1;
					if (x > self.charCountInLine) {
						x = self.charCountInLine;
					}
					mode = NORMAL;
					break; 
				}
					
				default:
#ifdef GBK_HACK
					need_hack = NO;
#endif
					mode = NORMAL;
					break;
			}
		} else {
			if (ch < 0xff) {
				fontcode = FC_ANSI;
				if (ch == '\e') {
					mode = ESCAPE;
					continue;
				}
#ifdef GBK_HACK
				need_hack = NO;
#endif
				if (ch == '\r') {
					continue;
				}
				if (ch == '\n') {
					x = 0;
					y++;
					continue;
				}
			} else {
				fontcode = FC_WIDE;
			}
			if (x >= self.charCountInLine) {
				x = 0;
				y++;
			}
			if (y >= self.lineCount) continue;
			value[0] = refFont[fontcode];
			value[1] = refColor[colorcode];
#ifdef GBK_HACK
			if (need_hack) {
				value[1] = refColor[hack_colorcode];
			}
#endif
			attrib = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&value, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
			str = CFStringCreateWithSubstring(kCFAllocatorDefault, (__bridge CFStringRef)self.string, CFRangeMake((CFIndex)i, 1));
			astr = CFAttributedStringCreate(kCFAllocatorDefault, str, attrib);
			CFRelease(attrib);
			line = CTLineCreateWithAttributedString(astr);
			run = (CTRunRef)CFArrayGetValueAtIndex(CTLineGetGlyphRuns(line), 0);
			runInfo.fontcode = fontcode;
			runInfo.backcolorcode = backcolorcode;
			runInfo.blink = blink;
#ifdef GBK_HACK
			if (need_hack) {
				runInfo.backcolorcode = hack_backcolorcode;
				runInfo.blink = hack_blink;
			}
#endif
			runInfo.isfirstHalf = YES;
			data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&runInfo, sizeof(runInfo));
			info[0] = run;
			info[1] = data;
			array = CFArrayCreate(kCFAllocatorDefault, (const void **)&info, 2, &kCFTypeArrayCallBacks);
			CFRelease(data);
			while (CFArrayGetCount(self.runs) <= (CFIndex)y) {
				runs = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
				CFArrayAppendValue(self.runs, runs);
				CFRelease(runs);
			}
			runs = (CFMutableArrayRef)CFArrayGetValueAtIndex(self.runs, (CFIndex)y);
			while (CFArrayGetCount(runs) < (CFIndex)x) {
				CFArrayAppendValue(runs, run_none);
			}
			if (CFArrayGetCount(runs) == (CFIndex)x) {
				CFArrayAppendValue(runs, array);
			} else {
				CFArrayReplaceValues(runs, CFRangeMake((CFIndex)x, 1), (const void **)&array, 1);
			}
			CFRelease(array);
			x++;
			if (fontcode == FC_WIDE) {
				if (x >= self.charCountInLine) {
					x = 0;
					y++;
				}
				if (y >= self.lineCount) {
					CFRelease(line);
					CFRelease(astr);
					CFRelease(str);
					continue;
				}
#ifdef GBK_HACK
				if (need_hack) {
					value[1] = refColor[colorcode];
					CFRelease(line);
					CFRelease(astr);
					attrib = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&value, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
					astr = CFAttributedStringCreate(kCFAllocatorDefault, str, attrib);
					CFRelease(attrib);
					line = CTLineCreateWithAttributedString(astr);
					run = (CTRunRef)CFArrayGetValueAtIndex(CTLineGetGlyphRuns(line), 0);
					runInfo.backcolorcode = backcolorcode;
					runInfo.blink = blink;
				}
#endif
				runInfo.isfirstHalf = NO;
				data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&runInfo, sizeof(runInfo));
				info[0] = run;
				info[1] = data;
				array = CFArrayCreate(kCFAllocatorDefault, (const void **)&info, 2, &kCFTypeArrayCallBacks);
				CFRelease(data);
				if (CFArrayGetCount(self.runs) <= (CFIndex)y) {
					runs = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
					CFArrayAppendValue(self.runs, runs);
					CFRelease(runs);
					runs = (CFMutableArrayRef)CFArrayGetValueAtIndex(self.runs, (CFIndex)y);
				}
				if (CFArrayGetCount(runs) == (CFIndex)x) {
					CFArrayAppendValue(runs, array);
				} else {
					CFArrayReplaceValues(runs, CFRangeMake((CFIndex)x, 1), (const void **)&array, 1);
				}
				CFRelease(array);
				x++;
			}
			CFRelease(line);
			CFRelease(astr);
			CFRelease(str);
		}
	}
}

- (CGSize)drawInRect:(CGRect *)rect {
	CGSize size = rect->size;
	CFIndex x, y, count, start, end;
	CFArrayRef line;
	CGFloat ascent[2] = {
		fontAscentFor12pt[0] * self.width / self.charCountInLine / fontWidthFor12pt[0],
		fontAscentFor12pt[1] * self.width / self.charCountInLine * 2 / fontWidthFor12pt[1],
	};
	CGFloat descent[2] = {
		fontDescentFor12pt[0] * self.width / self.charCountInLine / fontWidthFor12pt[0],
		fontDescentFor12pt[1] * self.width / self.charCountInLine * 2 / fontWidthFor12pt[1],
	};
	CGFloat leading[2] = {
		fontLeadingFor12pt[0] * self.width / self.charCountInLine / fontWidthFor12pt[0],
		fontLeadingFor12pt[1] * self.width / self.charCountInLine * 2 / fontWidthFor12pt[1],
	};
	CGFloat magnitude = ascent[1] / ascent[0];
	CGFloat lineHeight, lineOffset;
	lineOffset = ascent[1];
	lineHeight = MAX(ascent[0] + descent[0] + leading[0], (ascent[0] + descent[1] + leading[1]) * magnitude);
	if (magnitude > 1) magnitude *= 0.9;
	CGAffineTransform transform[2] = {
		CGAffineTransformScale(CGAffineTransformIdentity, 1, -magnitude),
		CGAffineTransformScale(CGAffineTransformIdentity, 1, -1),
	};
	count = CFArrayGetCount(self.runs);
	start = (CFIndex)(rect->origin.y / lineHeight);
	if (start < 0) {
		start = 0;
	}
	end = (CFIndex)((rect->origin.y + rect->size.height) / lineHeight + 1);
	size.height = count * lineHeight;
	if (end > count) {
		end = count;
	}
	for (y = start; y < end; y++) {
		line = CFArrayGetValueAtIndex(self.runs, y);
		count = CFArrayGetCount(line);
		for (x = 0; x < count; x++) {
			CFArrayRef array = CFArrayGetValueAtIndex(line, x);
			if (array == run_none) continue;
			CTRunRef run = CFArrayGetValueAtIndex(array, 0);
			CFDataRef data = CFArrayGetValueAtIndex(array, 1);
			struct run_info_t runInfo;
			CFDataGetBytes(data, CFRangeMake(0, sizeof(runInfo)), (UInt8 *)&runInfo);
			CGContextSetTextMatrix(self.context, transform[runInfo.fontcode]);
			CGContextSetTextPosition(self.context, x * self.width / self.charCountInLine, y * lineHeight + lineOffset);
			CGRect charRect = CGRectMake(x * self.width / self.charCountInLine, y * lineHeight, self.width / self.charCountInLine, lineHeight);
			if (runInfo.backcolorcode != CC_NONE) {
				CGContextSetFillColorWithColor(self.context, refColor[runInfo.backcolorcode]);
				charRect = CGRectMake(x * self.width / self.charCountInLine, y * lineHeight, self.width / self.charCountInLine, lineHeight);
				CGContextFillRect(self.context, charRect);
			}
			if (self.blink && runInfo.blink) continue;
			CGContextBeginTransparencyLayerWithRect(self.context, charRect, NULL);
			if (!runInfo.isfirstHalf) {
				CGContextSetTextPosition(self.context, (x - 1) * self.width / self.charCountInLine, y * lineHeight + lineOffset);
			}
			CTRunDraw(run, self.context, CFRangeMake(0, 0));
			CGContextEndTransparencyLayer(self.context);
		}
	}
	return size;
}

@end
