//
//  LHLabel.m
//  autoService
//
//  Created by bangong on 16/5/9.
//  Copyright © 2016年 车质网. All rights reserved.
//

#import "LHLabel.h"
#import <CoreText/CoreText.h>

static NSString* const kEllipsesCharacter = @"\u2026";
NSString *const KLHTextRunAttributedName = @"KLHTextRunAttributedName";

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

static inline NSAttributedString * NSAttributedStringBySettingColorFromContext(NSAttributedString *attributedString, UIColor *color) {
    if (!color) {
        return attributedString;
    }
    
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTForegroundColorFromContextAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, __unused BOOL *stop) {
        BOOL usesColorFromContext = (BOOL)value;
        if (usesColorFromContext) {
            [mutableAttributedString setAttributes:[NSDictionary dictionaryWithObject:color forKey:(NSString *)kCTForegroundColorAttributeName] range:range];
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorFromContextAttributeName range:range];
        }
    }];
    return mutableAttributedString;
}

static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {

    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, CGFLOAT_MAX);

    if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, CGFLOAT_MAX));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
   
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CFRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
}

@interface LHLabel()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableParagraphStyle *parapgStyle;
@property (nonatomic,assign) CTFrameRef frameRef;
@property (nonatomic,strong) NSMutableArray <__kindof LHTextStorage *> *storageArray;

@property (nonatomic, strong) NSDictionary  *runRectDictionary;  // runRect字典
@property (nonatomic, strong) NSDictionary  *linkRectDictionary; // linkRect字典
@property (nonatomic ,strong) NSDictionary  *drawRectDictionary;//
@property (nonatomic, strong) NSAttributedString *fullAttributeString;//当换行为....时用于计算size

@property (nonatomic, assign) BOOL drawSelectedBackgroundColor;//画选中区域
@property (nonatomic, assign) NSRange drawSelectedRange;//当前选中区域

@end

@implementation LHLabel
@synthesize text = _text;

- (void)dealloc
{
    if (_frameRef) {
         CFRelease(_frameRef);
    }
   
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithClickBlock:(void(^)(LHTextStorage * storage))block{
    if (self = [super init]) {
         self.click  = block;
        [self setUp];
    }
    return self;
}

-(void)setUp{
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByCharWrapping;
    self.alignment = NSTextAlignmentLeft;
    self.textInsets = UIEdgeInsetsZero;
    self.font = [UIFont systemFontOfSize:17];
    self.textColor = [UIColor blackColor];
    self.text = [[NSString alloc] init];
    self.backgroundColor = [UIColor clearColor];
    self.parapgStyle = [[NSMutableParagraphStyle alloc] init];
    self.storageArray = [[NSMutableArray alloc] init];
    
   //添加手势
    [self attachTapHandler];

}
#pragma mark - 菜单
//设置可唤醒键盘
- (BOOL)canBecomeFirstResponder{
    return YES;
}
//"反馈"关心的功能，即放出你需要的功能，比如你要放出copy，你就返回YES，否则返回NO；
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action == @selector(copy:)){
        return YES;
    }
    return NO;
}

//针对于copy的实现
-(void)copy:(id)sender{
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}


-(void)attachTapHandler{
    self.userInteractionEnabled =YES;  //用户交互的总开关
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    touch.delegate = self;
    [self addGestureRecognizer:touch];
   // touch.numberOfTapsRequired =1;
}

//响应点击事件
-(void)handleTap:(UILongPressGestureRecognizer *) recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)objectRelease{
//    if (_frameRef) {
//        CFRelease(_frameRef);
//    }
    [self.storageArray removeAllObjects];
    self.runRectDictionary = nil;
    self.drawRectDictionary = nil;
    self.linkRectDictionary = nil;
}

#pragma mark - sets
-(void)setText:(NSString *)text{
    _text = [text copy];
    _attributeString = nil;
    [self objectRelease];
    [self addattributeName];
    [self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}
- (void)setTextInsets:(UIEdgeInsets)textInsets{
    _textInsets = UIEdgeInsetsMake(textInsets.bottom, textInsets.left, textInsets.top, textInsets.right);
}

- (void) setFont:(UIFont *)font{
    _font = font;
    
    if (_attributeString) {
        NSRange range = NSMakeRange(0, self.attributeString.length);
        [self.attributeString removeAttribute:NSFontAttributeName range:range];
        [self.attributeString addAttribute:NSFontAttributeName value:self.font range:range];
   
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

#pragma mark getters

-(NSMutableAttributedString *)attributeString{
    if (_attributeString == nil) {
        _attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    return _attributeString;
}


-(NSAttributedString *)fullAttributeString{
    if (!_fullAttributeString) {
        NSMutableParagraphStyle *staly = [self.parapgStyle mutableCopy];
        staly.lineBreakMode  = NSLineBreakByWordWrapping;
        NSMutableAttributedString *mutableAtt = [self.attributeString mutableCopy];
        [mutableAtt removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, mutableAtt.length)];
        [mutableAtt addAttribute:NSParagraphStyleAttributeName value:staly range:NSMakeRange(0, mutableAtt.length)];
        _fullAttributeString = [mutableAtt copy];
   
    }
    return _fullAttributeString;
}

#pragma mark - view
//- (CGSize)sizeThatFits:(CGSize)size
//{
//    return self.frame.size;
//}

-(void)sizeToFit{
    CGSize size = [self intrinsicContentSize];
    self.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (CGSize)intrinsicContentSize
{
    NSLog(@"f888d");
    return [self getSize];
}

-(CGSize)getSize{
    
    NSAttributedString *attribute = self.attributeString;
    if (self.lineBreakMode == NSLineBreakByTruncatingTail) {
        attribute = self.fullAttributeString;
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)NSAttributedStringBySettingColorFromContext(attribute, self.textColor));
    
    CGSize labelSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, attribute, CGSizeMake(self.preferredMaxLayoutWidth-self.textInsets.left- self.textInsets.right,MAXFLOAT), (NSUInteger)self.numberOfLines);
    if (_frameRef) {
        CFRelease(_frameRef);
    }
    _frameRef = [self createFrameRefWithFramesetter:framesetter textSize:labelSize];
    
    labelSize.width += self.textInsets.left + self.textInsets.right;
    labelSize.height += self.textInsets.top + self.textInsets.bottom;
    
    // 创建CTFrameRef
    
    [self saveTextStorageRectWithFrame:_frameRef];
    CFRelease(framesetter);
    
    return labelSize;
}

#pragma mark -
-  (CTFrameRef)createFrameRefWithFramesetter:(CTFramesetterRef)framesetter textSize:(CGSize)textSize
{
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(self.textInsets.left, self.textInsets.top, textSize.width, textSize.height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributeString length]), path, NULL);
    CFRelease(path);
    return frameRef;
}

//- (CGFloat)getHeightWithWidth:(CGFloat)width
//{
//    // 是否需要更新frame
//    return [self getHeightWithFramesetter:nil width:width];
//}
//

//- (CGFloat)getHeightWithFramesetter:(CTFramesetterRef)framesetter width:(CGFloat)width
//{
//    // 是否需要更新frame
//    if (framesetter == nil) {
//        
//        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributeString);
//    }else {
//        CFRetain(framesetter);
//    }
//    
//    // 获得建议的size
//    CGSize suggestedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, _attributeString, CGSizeMake(width,MAXFLOAT), _numberOfLines);
//
//    CFRelease(framesetter);
//    
//    return suggestedSize.height+1;
//}

- (void)saveTextStorageRectWithFrame:(CTFrameRef)frame
{
  
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    CGFloat viewWidth = self.bounds.size.width;
    
    NSInteger numberOfLines = _numberOfLines > 0 ? MIN(_numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    NSMutableDictionary *runRectDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *linkRectDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *drawRectDictionary = [NSMutableDictionary dictionary];
    // 获取每行有多少run
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 获得每行的run
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            // run的属性字典
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
           LHTextStorage *storage = attributes[KLHTextRunAttributedName];
          
            
            if (storage) {
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                if (viewWidth > 0 && runWidth > viewWidth) {
                    runWidth  = viewWidth;
                }
                CGRect runRect = CGRectMake(self.textInsets.left+lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), self.textInsets.top+lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
            
               [linkRectDictionary setObject:storage forKey:[NSValue valueWithCGRect:runRect]];
                
               [runRectDictionary setObject:storage forKey:[NSValue valueWithCGRect:runRect]];
            }
        }
    }
    
    if (drawRectDictionary.count > 0) {
        _drawRectDictionary = [drawRectDictionary copy];
    }else {
        _drawRectDictionary = nil;
    }
    
    if (runRectDictionary.count > 0) {
        // 添加响应点击rect
        [self addRunRectDictionary:[runRectDictionary copy]];
    }
    
    if (linkRectDictionary.count > 0) {
        _linkRectDictionary = [linkRectDictionary copy];
    }else {
        _linkRectDictionary = nil;
    }
}

// 添加响应点击rect
- (void)addRunRectDictionary:(NSDictionary *)runRectDictionary
{
//    if (runRectDictionary.count < _runRectDictionary.count) {
//        NSMutableArray *drawStorageArray = [[_runRectDictionary allValues]mutableCopy];
//        // 剔除已经画出来的
//        [drawStorageArray removeObjectsInArray:[runRectDictionary allValues]];
//    }
    _runRectDictionary = runRectDictionary;
}

#pragma mark - touchs

//接受触摸事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  
    //获取UITouch对象
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
   BOOL find = [self enumerateRunRect:_runRectDictionary ContainPoint:location viewHeight:self.frame.size.height successBlock:^(LHTextStorage *storage) {
       self.drawSelectedBackgroundColor = YES;
       self.drawSelectedRange = storage.range;
       [self setNeedsDisplay];
   }];
    if (!find) {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.drawSelectedBackgroundColor == YES) {
        self.drawSelectedBackgroundColor = NO;
        [self setNeedsDisplay];

    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    [self enumerateRunRect:_runRectDictionary ContainPoint:location viewHeight:self.frame.size.height successBlock:^(LHTextStorage *storage) {
      
        if (self.click) {
            self.click(storage);
        }
    }];
    if ( self.drawSelectedBackgroundColor) {
        self.drawSelectedBackgroundColor = NO;
        [self setNeedsDisplay];
    }
}

- (BOOL)enumerateRunRect:(NSDictionary *)runRectDic ContainPoint:(CGPoint)point viewHeight:(CGFloat)viewHeight successBlock:(void (^)(LHTextStorage *storage))successBlock
{
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0,viewHeight), 1.f, -1.f);
    
    
    __block BOOL find = NO;
    // 遍历run位置字典
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, LHTextStorage * textStorage, BOOL *stop) {
        
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            
            find = YES;
            *stop = YES;
          
            if (successBlock) {
                successBlock(textStorage);
            }
        }
    }];
    return find;
}

-  (CTFrameRef)createFrameRefWithFramesetter:(CTFramesetterRef)framesetter textWidth:(CGFloat)textWidth att:(NSMutableAttributedString *)_attString
{
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, textWidth, CGFLOAT_MAX));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    CFRelease(path);
    return frameRef;
}

#pragma mark -  drawRect
-(void)drawRect:(CGRect)rect{
  
   CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    //[self.attributeString drawInRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    if (!_frameRef) {
        NSAttributedString *attribute = [self.attributeString copy];
        if (self.lineBreakMode == NSLineBreakByTruncatingTail) {
            attribute = self.fullAttributeString;
        }
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)NSAttributedStringBySettingColorFromContext(attribute, self.textColor));
        _frameRef = [self createFrameRefWithFramesetter:framesetter textSize:insetRect.size];
        CFRelease(framesetter);
        //
        [self saveTextStorageRectWithFrame:_frameRef];
    }
    
   //绘画选择区域背景
    if (self.drawSelectedBackgroundColor) {
         [self drawSelectionAreaFrame:_frameRef InRange:self.drawSelectedRange bgColor:[UIColor orangeColor]];
    }
    // CTFrameDraw 将 frame 描述到设备上下文
    [self drawText:self.attributeString frame:_frameRef rect:insetRect context:context];

    // 画其他元素
    [self drawTextStorage:rect];
}

// 绘画选择区域
- (void)drawSelectionAreaFrame:(CTFrameRef)frameRef InRange:(NSRange)selectRange bgColor:(UIColor *)bgColor{
    
    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    
    if (selectionStartPosition < 0 || selectRange.length <= 0 || selectionEndPosition > self.attributeString.length) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    if (!lines) {
        return;
    }
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0,0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        linePoint.x += self.textInsets.left;
        linePoint.y += self.textInsets.top;
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        // 1. start和end在一个line,则直接弄完break
        if ([self isPosition:selectionStartPosition inRange:range] && [self isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
            break;
        }
        
        // 2. start和end不在一个line
        // 2.1 如果start在line中，则填充Start后面部分区域
        if ([self isPosition:selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
        } // 2.2 如果 start在line前，end在line后，则填充整个区域
        else if (selectionStartPosition < range.location && selectionEndPosition >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, width, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
        } // 2.3 如果start在line前，end在line中，则填充end前面的区域,break
        else if (selectionStartPosition < range.location && [self isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
        }
    }
}

- (BOOL)isPosition:(NSInteger)position inRange:(CFRange)range {
    return (position >= range.location && position < range.location + range.length);
}

- (void)fillSelectionAreaInRect:(CGRect)rect bgColor:(UIColor *)bgColor {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
}


// this code quote M80AttributedLabel
- (void)drawText: (NSAttributedString *)attributedString
           frame:(CTFrameRef)frame
            rect: (CGRect)rect
         context: (CGContextRef)context
{

    if (self.numberOfLines > 0)
    {
        CFArrayRef lines = CTFrameGetLines(frame);
        NSInteger numberOfLines = MIN(self.numberOfLines, CFArrayGetCount(lines));
        
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
        
        BOOL truncateLastLine = (self.lineBreakMode == NSLineBreakByTruncatingTail);
     
        for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
        {
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CGContextSetTextPosition(context, lineOrigin.x+self.textInsets.left, lineOrigin.y+self.textInsets.top);
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            BOOL shouldDrawLine = YES;
            if (lineIndex == numberOfLines - 1 && truncateLastLine)
            {
                // Does the last line need truncation?
                
                CFRange lastLineRange = CTLineGetStringRange(line);
                
                if (lastLineRange.location + lastLineRange.length < attributedString.length)
                {
                    CTLineTruncationType truncationType = kCTLineTruncationEnd;
                    NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                    
                    NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
                    NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:kEllipsesCharacter attributes:tokenAttributes];
                    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                    
                    NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                    
                    if (lastLineRange.length > 0)
                    {
                        // Remove last token
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                   // [truncationString replaceCharactersInRange:NSMakeRange(lastLineRange.length-1, 1) withAttributedString:tokenString];
                    [truncationString appendAttributedString:tokenString];
                    
                    
                    CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                    CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                    if (!truncatedLine)
                    {
                        // If the line is not as wide as the truncationToken, truncatedLine is NULL
                        truncatedLine = CFRetain(truncationToken);
                    }
                    CFRelease(truncationLine);
                    CFRelease(truncationToken);
                    CTLineDraw(truncatedLine, context);
                    CFRelease(truncatedLine);
                    
                    shouldDrawLine = NO;
                }
            }
            if(shouldDrawLine)
            {
                CTLineDraw(line, context);
            }
        }
    }
    else
    {
        CTFrameDraw(frame,context);
    }
}


#pragma mark - drawTextStorage

- (void)drawTextStorage:(CGRect)rect
{
  
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, LHTextStorage * obj, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:[LHImageStorage class]]) {
            CGRect frame = [key CGRectValue];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, frame, ((LHImageStorage *)obj).image.CGImage);
        }else if ([obj isMemberOfClass:[LHDrawView class]]){
             CGRect frame = [key CGRectValue];
            frame.origin.y = rect.size.height-frame.origin.y-frame.size.height;
            LHDrawView *drawView = (LHDrawView *)obj;
            if ( drawView.view.superview) {
                [drawView.view removeFromSuperview];
            }
            drawView.view.frame = frame;
            [self addSubview: drawView.view];
            
        }
    }];
}


#pragma mark - add
-(void)addattributeName{
    NSRange range = NSMakeRange(0, self.attributeString.length);
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:self.textColor range:range];
    [self.attributeString addAttribute:NSFontAttributeName value:self.font range:range];
    [self.attributeString addAttribute:NSKernAttributeName value:@(self.characterSpace) range:range];
    self.parapgStyle.lineSpacing =  self.lineSpacing;
    self.parapgStyle.paragraphSpacing = self.paragraphSpacing;
    self.parapgStyle.alignment = self.alignment;
    self.parapgStyle.firstLineHeadIndent = self.firstLineHeadIndent;
    self.parapgStyle.headIndent = self.headIndent;
    self.parapgStyle.tailIndent = self.tailIndent;
    self.parapgStyle.lineBreakMode = self.lineBreakMode;
    self.parapgStyle.paragraphSpacingBefore = self.paragraphSpacingBefore;
    
    [self.attributeString addAttribute:NSParagraphStyleAttributeName value:self.parapgStyle range:range];

}


- (void)addLinkData:(id)data range:(NSRange)range{
    LHLinkStorage *LinkStorage = [[LHLinkStorage alloc] init];
    LinkStorage.range = range;
    LinkStorage.data = data;
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
    [self addStorage:LinkStorage];
}

- (void)addLinkData:(id)data rangeOfString:(NSString *)string{
    NSRange range = [[self.attributeString string] rangeOfString:string];
    if (range.length == 0) {
        return;
    }
    LHLinkStorage *LinkStorage = [[LHLinkStorage alloc] init];
    LinkStorage.range = range;
    LinkStorage.data = data;
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
    [self addStorage:LinkStorage];
}


- (void)addImage:(UIImage *)image data:(id)data size:(CGSize)size range:(NSRange)range{
    
      
    LHImageStorage *imageStorage = [[LHImageStorage alloc] init];
    imageStorage.range = range;
    imageStorage.data = data;
    imageStorage.imageSize = size;
    imageStorage.image = image;

    [self addStorage:imageStorage];
}

-(void)addImage:(UIImage *)image data:(id)data size:(CGSize)size rangeOfString:(NSString *)string{
    
    NSRange range = [[self.attributeString string] rangeOfString:string];
    if (range.length == 0) {
        return;
    }
    LHImageStorage *imageStorage = [[LHImageStorage alloc] init];
    imageStorage.range = range;
    imageStorage.data = data;
    imageStorage.imageSize = size;
    imageStorage.image = image;
    [imageStorage drawImageAttributeString:self.attributeString];
    
    [self addStorage:imageStorage];
}


- (void)addView:(UIView *)view size:(CGSize)size rangeOfString:(NSString *)string{
    NSRange range = [[self.attributeString string] rangeOfString:string];
    if (range.length == 0) {
        return;
    }
    LHDrawView *drawView = [[LHDrawView alloc] init];
    drawView.range = range;
    drawView.size = size;
    drawView.view = view;
    
    [drawView drawViewAttributeString:self.attributeString];
    
    [self addStorage:drawView];
}


-(void)addStorage:(LHTextStorage *)storage{
 
    [_storageArray addObject:storage];
    [self.attributeString addAttribute:KLHTextRunAttributedName value:storage range:storage.range];
    [self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];

}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
          
    BOOL find = [self enumerateRunRect:_runRectDictionary ContainPoint:point viewHeight:self.viewForFirstBaselineLayout.frame.size.height successBlock:nil];

    return !find;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
