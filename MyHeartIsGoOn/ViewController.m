//
//  ViewController.m
//  MyHeartIsGoOn
//
//  Created by bangong on 16/5/16.
//  Copyright © 2016年 auto. All rights reserved.
//

#import "ViewController.h"
#import "LHLabel.h"
#import "CZWLabel.h"
//#import "LHTextStorage.h"
#import <CoreText/CoreText.h>
#import "MyHeartIsGoOn-swift.h"

@interface MyCwll : UITableViewCell

@property (nonatomic,strong) CZWLabel *contentLabel;
@end

@implementation MyCwll

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _contentLabel = [[CZWLabel alloc] init];
        _contentLabel.textInsets = UIEdgeInsetsMake(30, 30, 30, 30);
        _contentLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_contentLabel];
        
        [_contentLabel makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsZero);
        }];
    }
    
    
    return self;
}

@end


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CZWLabel *systemLabel;
    LHLabel *label;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//         [self presentViewController:[[OOViewController alloc] init] animated:YES completion:nil];
//    });
//   
//    return;
//    CFDictionaryRef descriptorOptions = (__bridge CFDictionaryRef)@{(id)kCTFontDownloadableAttribute : @(YES)};
//    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)descriptorOptions);
//    CFArrayRef fontDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(descriptor, NULL);
//    NSArray *arr = (__bridge_transfer  NSArray *)fontDescriptors;
//    NSLog(@"%@",arr);
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.estimatedRowHeight = 100;
//    [self.view addSubview:self.tableView];
//    
//    OOViewController *vc = [[OOViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//    
//    return;
//
//    _dataArray = [UIFont familyNames];
//    [self.tableView reloadData];
    
//    if (![LHTextStorage isFontDownloaded:@"DFWaWaSC-W5"]) {
//        [LHTextStorage setup:@"DFWaWaSC-W5"];
//    }
    label = [[LHLabel alloc] init];
    label.preferredMaxLayoutWidth = 300;
    //  label.textInsets = UIEdgeInsetsMake(40, 10, 10, 80);
    label.paragraphSpacing = 10;
   // label.lineSpacing = 20;
     label.backgroundColor = [UIColor lightGrayColor];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.view addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(CGPointZero);
        make.height.equalTo(40);
    }];
  
    systemLabel = [[CZWLabel alloc] initWithFrame:CGRectMake(60, 60, 300, 500)];
     systemLabel.linesSpacing = 3;
    systemLabel.characterSpace = 3;
    systemLabel.firstLineHeadIndent = 20;
  //  systemLabel.numberOfLines = 5;
    [self.view addSubview:systemLabel];
    [systemLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(60);
        make.width.equalTo(300);
    }];
    systemLabel.backgroundColor = [UIColor lightGrayColor];
    systemLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    systemLabel.text = @"李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然safd阿斯顿发生的方式是否俺是个打工的方式给第三个电饭锅阿大使馆的风格的水电费是功夫大使馆的风格的是否跟得上的风格李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然safd阿斯顿发生的方式是否俺是个打工的方式给第三个电饭锅阿大使馆的风格的水电费是功夫大使馆的风格的是否跟得上的风格李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然safd阿斯顿发生sdaf的sdf方式是fda否俺是个打工的方式给第三个电饭锅阿大使馆的风格的水电费是功夫大使馆的风格的63598777";
    
    NSRange range = [systemLabel rangeOfString:@"慕白"];
   
    [systemLabel insertImage:[UIImage imageNamed:@"钱"] size:CGSizeMake(80, 80) index:range.location];
    range = [systemLabel rangeOfString:@"63598777"];
    [systemLabel addData:[[LHLinkStorage alloc] init] range:range];

    range = [systemLabel rangeOfString:@"safd阿斯顿发生sdaf的sdf方式是fda否俺是"];
    [systemLabel addData:[[LHLinkStorage alloc] init] range:range];
     range = [systemLabel rangeOfString:@"http://12365auto.com"];
    [systemLabel addImage:[UIImage imageNamed:@"钱"] size:CGSizeMake(60, 60) range:range];
       range = [systemLabel rangeOfString:@"的是否跟得上的风格李慕白====http://12365auto.com"];
    [systemLabel addImage:[UIImage imageNamed:@"钱"] size:CGSizeMake(60, 60) range:range];
  
       /*
     UIFontDescriptorFamilyAttribute：设置字体家族名
     UIFontDescriptorNameAttribute  ：设置字体的字体名
     UIFontDescriptorSizeAttribute  ：设置字体尺寸
     UIFontDescriptorMatrixAttribute：设置字体形变
     */
//    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
//                                                 @{UIFontDescriptorFamilyAttribute: @"DFWaWaSC",
//                                                   UIFontDescriptorNameAttribute:@"DFWaWaSC-W5",
//                                                   UIFontDescriptorSizeAttribute: @20.0,
//                                                   /*UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(M_1_PI)
//                                                                                    ]*/}];
//    systemLabel.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
//     NSLog(@"%@", [UIFont fontWithName:@"DFWaWaSC-W5" size:15]);
//    
//    label.text = @"李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然";
//    [label addLinkData:@{@"李慕白":@"李慕白"} rangeOfString:@"李慕白"];
//    
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    btn.backgroundColor = [UIColor grayColor];
//   // [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
//    [label addView:btn size:CGSizeMake(40, 20) rangeOfString:@"只是"];
//    [label addLinkData:@{@"李慕12365auto.com":@"李12365auto.com白"} rangeOfString:@"惘然"];
//    [label addImage:[UIImage imageNamed:@"钱"] data:@{} size: CGSizeMake(30, 30) rangeOfString:@"肝胆两昆仑"];
    
    [self asynchronouslySetFontName:@"STXingkai-SC-Bold"];
    
  
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    MyCwll *cell = [tableView dequeueReusableCellWithIdentifier:@"iconCell"];
    if (!cell) {
        cell = [[MyCwll alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"iconCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
    }
    cell.contentLabel.text = @"李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然safd阿斯顿发生的方式是否俺是个打工的方式给第三个电饭锅阿大使馆的风格的水电费是功夫大使馆的风格的是否跟得上的风格李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然safd阿斯顿发生的方式是否俺是个打工的方式给第三个电饭锅阿大使馆的风格的水电费是功夫大使馆的风格的是否跟得上的风格李慕白====http://12365auto.com天下去留肝胆两昆仑；刺青客店成追忆只是当时已惘然safd阿斯顿发生sdaf的sdf方式是fda否俺是个打工的方式给第三个电饭锅阿大使馆的风格的水电费是功夫大使馆的风格的63598777";
    if ([UIFont fontWithName:@"STXingkai-SC-Bold" size:19]) {
         cell.contentLabel.font = [UIFont fontWithName:@"STXingkai-SC-Bold" size:19];
    }
   
    NSRange range = [cell.contentLabel rangeOfString:@"慕白"];
    
    [cell.contentLabel insertImage:[UIImage imageNamed:@"钱"] size:CGSizeMake(80, 80) index:range.location];
    range = [cell.contentLabel rangeOfString:@"63598777"];
    [cell.contentLabel addData:[[LHLinkStorage alloc] init] range:range];
    
    range = [cell.contentLabel rangeOfString:@"safd阿斯顿发生sdaf的sdf方式是fda否俺是"];
    [cell.contentLabel addData:[[LHLinkStorage alloc] init] range:range];
    range = [cell.contentLabel rangeOfString:@"http://12365auto.com"];
    [cell.contentLabel addImage:[UIImage imageNamed:@"钱"] size:CGSizeMake(60, 60) range:range];
    range = [cell.contentLabel rangeOfString:@"的是否跟得上的风格李慕白====http://12365auto.com"];
    [cell.contentLabel addImage:[UIImage imageNamed:@"钱"] size:CGSizeMake(60, 60) range:range];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)asynchronouslySetFontName:(NSString *)fontName
{
 
    UIFont* aFont = [UIFont fontWithName:fontName size:24];
    // If the font is already downloaded
    if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
        // Go ahead and display the sample text.
        systemLabel.font = [UIFont fontWithName:fontName size:24];
        label.font = [[UIFont fontWithName:fontName size:24] copy];
        return;
    }
    
    // Create a dictionary with the font's PostScript name.
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    
    // Create a new font descriptor reference from the attributes dictionary.
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    
    // Start processing the font descriptor..
    // This function returns immediately, but can potentially take long time to process.
    // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
    // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)descs, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        
        //NSLog( @"state %d - %@", state, progressParameter);
        
        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Show an activity indicator
                NSLog(@"Begin Matching");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Remove the activity indicator
                
                // Display the sample text for the newly downloaded font
                //systemLabel.text = @"欢迎查看我的博客";
                systemLabel.font = [UIFont fontWithName:fontName size:24];
                [systemLabel sizeToFit];
            
                 label.font = [UIFont fontWithName:fontName size:24];

                // Log the font URL in the console
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
               // NSLog(@"%@", (__bridge NSURL*)(fontURL));
                CFRelease(fontURL);
                CFRelease(fontRef);
                
                if (!errorDuringDownload) {
                    NSLog(@"%@ downloaded", fontName);
                }
            });
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Show a progress bar
                
                NSLog(@"Begin Downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Remove the progress bar
                
                NSLog(@"Finish downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Use the progress bar to indicate the progress of the downloading
                NSLog(@"Downloading %.0f%% complete", progressValue);
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            // An error has occurred.
            // Get the error message
            NSString *_errorMessage = nil;
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            if (error != nil) {
                _errorMessage = [error description];
            } else {
                _errorMessage = @"ERROR MESSAGE IS NOT AVAILABLE!";
            }
            // Set our flag
            errorDuringDownload = YES;
            
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Download error: %@", _errorMessage);
            });
        }
        return (bool)YES;
    });   
}
@end
