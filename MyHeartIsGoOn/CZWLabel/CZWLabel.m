//
//  LHLabel.m
//  autoService
//
//  Created by bangong on 16/5/9.
//  Copyright © 2016年 车质网. All rights reserved.
//

#import "CZWLabel.h"
#import <CoreText/CoreText.h>
#import "LHTextStorage.h"
#import "LHImageStorage.h"

NSString *const kLHTextRunAttributedName = @"kLHTextRunAttributedName";
static NSString* const kEllipsesCharacter = @"\u2026";

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
    
    return CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));
}


@interface CZWLabel()<UIGestureRecognizerDelegate>
{
    CTFrameRef _frameRef;
    NSMutableAttributedString *_coreTextAttributedText;
}
@property (nonatomic,strong) NSMutableParagraphStyle *parapgStyle;
@property (nonatomic, strong) NSDictionary  *runRectDictionary;  // runRect字典
@property (nonatomic, strong) NSDictionary  *linkRectDictionary; // linkRect字典
@property (nonatomic ,strong) NSDictionary  *drawRectDictionary;//

@end

@implementation CZWLabel

- (void)dealloc
{
    if (_frameRef) {
         CFRelease(_frameRef);
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return  self;
}

-(void)setUp{
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByCharWrapping;
    self.textAlignment = NSTextAlignmentLeft;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.textInsets = UIEdgeInsetsZero;
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
  // self.userInteractionEnabled =YES;  //用户交互的总开关
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

#pragma mark - sets
-(void)setText:(NSString *)text{
    [super setText:text];
  
    _attributeString = nil;
    [self addattributeName];
    _coreTextAttributedText = [self.attributeString mutableCopy];
    self.attributedText = self.attributeString;
}

- (void)setFont:(UIFont *)font{
    
    [_coreTextAttributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _coreTextAttributedText.length)];
    [super setFont:font];
}


#pragma mark -
-  (CTFrameRef)createFrameRefWithFramesetter:(CTFramesetterRef)framesetter textSize:(CGSize)textSize attribute:(NSAttributedString *)attribute
{
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(self.textInsets.left, self.textInsets.top, textSize.width, textSize.height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attribute.length), path, NULL);
    CFRelease(path);
    return frameRef;
}

- (void)saveTextStorageRectWithFrame:(CTFrameRef)frame
{
    
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    CGFloat viewWidth = self.bounds.size.width;
    
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
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
            LHTextStorage *storage = attributes[kLHTextRunAttributedName];
          
            
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
        _runRectDictionary = [runRectDictionary copy];
    }
    
    if (linkRectDictionary.count > 0) {
        _linkRectDictionary = [linkRectDictionary copy];
    }else {
        _linkRectDictionary = nil;
    }
}


#pragma mark getters

-(NSMutableParagraphStyle *)parapgStyle{
    if (_parapgStyle == nil) {
        _parapgStyle = [[NSMutableParagraphStyle alloc] init];
    }
    return _parapgStyle;
}

-(NSMutableAttributedString *)attributeString{
    if (_attributeString == nil) {
        _attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    return _attributeString;
}


#pragma mark - add
-(void)addattributeName{
    [_attributeString beginEditing];
    NSRange range = NSMakeRange(0, self.attributeString.length);
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:self.textColor range:range];
    [self.attributeString addAttribute:NSFontAttributeName value:self.font range:range];
    [self.attributeString addAttribute:NSKernAttributeName value:@(self.characterSpace) range:range];
    self.parapgStyle.lineSpacing =  self.linesSpacing;
    self.parapgStyle.paragraphSpacing = self.paragraphSpacing;
    self.parapgStyle.alignment = self.textAlignment;
    self.parapgStyle.firstLineHeadIndent = self.firstLineHeadIndent;
    self.parapgStyle.headIndent = self.headIndent;
    self.parapgStyle.tailIndent = self.tailIndent;
    self.parapgStyle.lineBreakMode = self.lineBreakMode;
    self.parapgStyle.paragraphSpacingBefore = self.paragraphSpacingBefore;
    
    [self.attributeString addAttribute:NSParagraphStyleAttributeName value:self.parapgStyle range:range];
    [_attributeString endEditing];

}

#pragma mark - views

-(CGSize)intrinsicContentSize{
    CGSize size = [super intrinsicContentSize];
    
    NSMutableAttributedString *matt = [_coreTextAttributedText mutableCopy];
    if (self.lineBreakMode == NSLineBreakByTruncatingTail) {
       
        NSMutableParagraphStyle *style = [self.parapgStyle mutableCopy];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.lineSpacing = self.linesSpacing+1.2;
        CTParagraphStyleRef ref = (__bridge CTParagraphStyleRef)style;
        
        
        [matt removeAttribute:(id)kCTParagraphStyleAttributeName range:NSMakeRange(0, matt.length)];
        [matt addAttribute:(id)kCTParagraphStyleAttributeName value:(id)ref range:NSMakeRange(0, matt.length)];
     
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)matt);
    if (_frameRef) {
        CFRelease(_frameRef);
    }
    size = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, matt, CGSizeMake(size.width,CGFLOAT_MAX), (NSUInteger)self.numberOfLines);
    _frameRef = [self createFrameRefWithFramesetter:framesetter textSize:size attribute:matt];
    [self saveTextStorageRectWithFrame:_frameRef];
    CFRelease(framesetter);

    return CGSizeMake(size.width+self.textInsets.left+self.textInsets.right, size.height+self.textInsets.top+self.textInsets.bottom);
}

#pragma mark = label

- (void)drawTextInRect:(CGRect)rect{
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    
    if (!_frameRef) {
        NSMutableAttributedString *matt = [_coreTextAttributedText mutableCopy];
        if (self.lineBreakMode == NSLineBreakByTruncatingTail) {
            
            NSMutableParagraphStyle *style = [self.parapgStyle mutableCopy];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.lineSpacing = self.linesSpacing+1.2;
            CTParagraphStyleRef ref = (__bridge CTParagraphStyleRef)style;
            
            
            [matt removeAttribute:(id)kCTParagraphStyleAttributeName range:NSMakeRange(0, matt.length)];
            [matt addAttribute:(id)kCTParagraphStyleAttributeName value:(id)ref range:NSMakeRange(0, matt.length)];
            
        }
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)matt);

        _frameRef = [self createFrameRefWithFramesetter:framesetter textSize:insetRect.size attribute:matt];
        [self saveTextStorageRectWithFrame:_frameRef];
        CFRelease(framesetter);

    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0,rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    

   // [super drawTextInRect:insetRect];
    // CTFrameDraw 将 frame 描述到设备上下文
    [self drawText:self.attributeString frame:_frameRef rect:insetRect context:context];
    // 画其他元素
    [self drawTextStorage:insetRect];
    
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

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
                    //[truncationString replaceCharactersInRange:NSMakeRange(lastLineRange.length-1, 1) withAttributedString:tokenString];
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


- (void)drawTextStorage:(CGRect)rect
{
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, LHTextStorage * obj, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:[LHImageStorage class]]) {
          
            CGRect frame = [key CGRectValue];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, frame, ((LHImageStorage *)obj).image.CGImage);

        }
    }];
    
}

-(void)addColor:(UIColor *)color range:(NSRange)range{
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:color range:range];
    self.attributedText = self.attributeString;
    
}

- (void)insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index{
    NSTextAttachment *achment = [[NSTextAttachment alloc] init];
    achment.image = image;
    achment.bounds = CGRectMake(0, 0, size.width, size.height);
    NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:achment];
    [self.attributeString insertAttributedString:att atIndex:index];
  
    LHImageStorage *storage = [[LHImageStorage alloc] init];
    storage.range = NSMakeRange(index, 1);
    storage.imageSize = size;
    storage.image = image;
    [_coreTextAttributedText insertAttributedString:[[NSAttributedString alloc] initWithString:@"5"] atIndex:index];
    [_coreTextAttributedText removeAttribute:kLHTextRunAttributedName range:NSMakeRange(index, 1)];
    [_coreTextAttributedText addAttribute:kLHTextRunAttributedName value:storage range:NSMakeRange(index, 1)];
    [storage drawImageAttributeString:_coreTextAttributedText];
    
     self.attributedText = self.attributeString;

}

- (void)addImage:(UIImage *)image size:(CGSize)size range:(NSRange)range{
    NSTextAttachment *achment = [[NSTextAttachment alloc] init];
    achment.image = image;
    achment.bounds = CGRectMake(0, 0, size.width, size.height);
    NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:achment];
    [self.attributeString replaceCharactersInRange:range withAttributedString:att];
  
    LHImageStorage *storage = [[LHImageStorage alloc] init];
    storage.range = range;
    storage.imageSize = size;
    storage.image = image;
    [storage drawImageAttributeString:_coreTextAttributedText];

    self.attributedText = self.attributeString;
}

- (void)addData:(id)data range:(NSRange)range{
  
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    LHTextStorage *storage = [[LHTextStorage alloc] init];
    storage.data = data;
    
    [_coreTextAttributedText addAttribute:kLHTextRunAttributedName value:storage range:range];
    [_coreTextAttributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    self.attributedText = self.attributeString;
}

- (NSRange)rangeOfString:(NSString *)string{
    return  [[self.attributedText string] rangeOfString:string];
}
#pragma mark - touchs

//接受触摸事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
   
    //获取UITouch对象
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    BOOL find = [self enumerateRunRect:_runRectDictionary ContainPoint:location viewHeight:self.frame.size.height successBlock:^(LHTextStorage *storage) {
//        self.drawSelectedBackgroundColor = YES;
//        self.drawSelectedRange = storage.range;
//        [self setNeedsDisplay];
        NSLog(@"%@",storage);
    }];
    if (!find) {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if (self.drawSelectedBackgroundColor == YES) {
//        self.drawSelectedBackgroundColor = NO;
//        [self setNeedsDisplay];
//        
//    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    [self enumerateRunRect:_runRectDictionary ContainPoint:location viewHeight:self.frame.size.height successBlock:^(LHTextStorage *storage) {
        
    }];
//    if ( self.drawSelectedBackgroundColor) {
//        self.drawSelectedBackgroundColor = NO;
//        [self setNeedsDisplay];
//    }
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

//- (NSString *)spaceReplaceString
//{
//    // 替换字符
//    unichar objectReplacementChar           = 0xFFFC;
//    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
//    return objectReplacementString;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
