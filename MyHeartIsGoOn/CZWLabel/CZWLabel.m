//
//  LHLabel.m
//  autoService
//
//  Created by bangong on 16/5/9.
//  Copyright © 2016年 车质网. All rights reserved.
//

#import "CZWLabel.h"

@interface CZWLabel()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableParagraphStyle *parapgStyle;

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
  
    return CGSizeMake(size.width+self.textInsets.left+self.textInsets.right, size.height+self.textInsets.top+self.textInsets.bottom);
}

- (void)drawTextInRect:(CGRect)rect{
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    [super drawTextInRect:insetRect];
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
     self.attributedText = self.attributeString;
}

- (void)addImage:(UIImage *)image size:(CGSize)size range:(NSRange)range{
    NSTextAttachment *achment = [[NSTextAttachment alloc] init];
    achment.image = image;
    achment.bounds = CGRectMake(0, 0, size.width, size.height);
    NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:achment];
    [self.attributeString replaceCharactersInRange:range withAttributedString:att];
    self.attributedText = self.attributeString;
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
