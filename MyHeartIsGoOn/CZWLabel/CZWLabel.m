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

@interface CZWLabel()<UIGestureRecognizerDelegate>
{
    CTFrameRef _frameRef;
}
@property (nonatomic,strong) NSMutableParagraphStyle *parapgStyle;
@property (nonatomic, strong) NSDictionary  *runRectDictionary;  // runRect字典
@property (nonatomic, strong) NSDictionary  *linkRectDictionary; // linkRect字典
@property (nonatomic ,strong) NSDictionary  *drawRectDictionary;//

@end

@implementation CZWLabel

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
    self.attributedText = self.attributeString;
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
    
    NSAttributedString *att = self.attributedText;
    if (self.lineBreakMode == NSLineBreakByTruncatingTail) {
        NSMutableAttributedString *matt = [self.attributedText mutableCopy];
        NSMutableParagraphStyle *style = [self.parapgStyle mutableCopy];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        [matt removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, matt.length)];
        [matt addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, matt.length)];
        att = matt;
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)[att copy]);
    if (_frameRef) {
        CFRelease(_frameRef);
    }
    _frameRef = [self createFrameRefWithFramesetter:framesetter textSize:size];
    [self saveTextStorageRectWithFrame:_frameRef];
    CFRelease(framesetter);

    return CGSizeMake(size.width+self.textInsets.left+self.textInsets.right, size.height+self.textInsets.top+self.textInsets.bottom);
}

- (void)drawTextInRect:(CGRect)rect{
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    
   
    [super drawTextInRect:insetRect];
    
    [self drawTextStorage:insetRect];

}

- (void)drawTextStorage:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0,rect.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//  //  CTFrameDraw(_frameRef, context);
//    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, LHTextStorage * obj, BOOL * _Nonnull stop) {
//        if ([obj isMemberOfClass:[LHImageStorage class]]) {
//          
//            CGRect frame = [key CGRectValue];
//            CGContextDrawImage(context, frame, ((LHImageStorage *)obj).image.CGImage);
////
//        }
//    }];
    
//        CGContextTranslateCTM(context, 0, self.bounds.size.height);
//        CGContextScaleCTM(context, 1.0, -1.0);

}

-(void)addColor:(UIColor *)color range:(NSRange)range{
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:color range:range];
    self.attributedText = self.attributeString;
    
}

- (void)insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index{
    NSTextAttachment *achment = [[NSTextAttachment alloc] init];
   // achment.image = image;
    achment.bounds = CGRectMake(0, 0, size.width, size.height);
    NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:achment];
    [self.attributeString insertAttributedString:att atIndex:index];
    LHImageStorage *storage = [[LHImageStorage alloc] init];
    storage.range = NSMakeRange(index, 1);
    storage.imageSize = size;
    storage.image = image;
    [self.attributeString addAttribute:kLHTextRunAttributedName value:storage range:NSMakeRange(index, 1)];
    [storage drawImageAttributeString:self.attributeString];
     self.attributedText = self.attributeString;

}

- (void)addImage:(UIImage *)image size:(CGSize)size range:(NSRange)range{
    NSTextAttachment *achment = [[NSTextAttachment alloc] init];
    achment.image = image;
    achment.bounds = CGRectMake(0, 0, size.width, size.height);
    NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:achment];
    [self.attributeString replaceCharactersInRange:range withAttributedString:att];
    LHImageStorage *storage = [[LHImageStorage alloc] init];
    storage.range = NSMakeRange(range.location, 1);
    storage.imageSize = size;
    storage.image = image;
    [self.attributeString addAttribute:kLHTextRunAttributedName value:storage range:NSMakeRange(range.location, 1)];
    [storage drawImageAttributeString:self.attributeString];

    self.attributedText = self.attributeString;
    NSLog(@"%@",self.attributedText);
}

- (void)addData:(id)data range:(NSRange)range{
    [self.attributeString addAttribute:kLHTextRunAttributedName value:data range:range];
    [self.attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
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
