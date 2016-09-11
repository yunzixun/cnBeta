//
//  commentPostViewController.m
//  cnBeta
//
//  Created by hudy on 16/7/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "commentPostViewController.h"
#import "HTTPRequester.h"
#import "JDStatusBarNotification.h"
#import "Constant.h"
#import "CRToast.h"
#import "WKProgressHUD.h"

@interface commentPostViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *contentBorder;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UITextField *codeText;
@property (weak, nonatomic) IBOutlet UIButton *securityCode;
@property (weak, nonatomic) IBOutlet UIButton *postComment;

@end

@implementation commentPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tid) {
        self.navigationItem.title = @"回复评论";
    } else {
        self.navigationItem.title = @"发表评论";
    }
    self.contentBorder.layer.borderColor = [UIColor blackColor].CGColor;
    self.contentBorder.layer.borderWidth = LayoutBordWidth;
    [self.contentText becomeFirstResponder];
    self.codeText.keyboardType = UIKeyboardTypeAlphabet;
    self.codeText.returnKeyType = UIReturnKeySend;
    self.codeText.delegate = self;
    [self refetchSecurityCode:nil];
   
}
- (IBAction)refetchSecurityCode:(UIButton *)sender {
    [self.securityCode setTitle:@"" forState:UIControlStateNormal];
    [self.securityCode setBackgroundImage:nil forState:UIControlStateNormal];
    
    HTTPRequester *request = [HTTPRequester sharedHTTPRequester];
    [request fetchSecurityCodeForSid:self.sid completion:^(id responseObject, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:responseObject];
            [self.securityCode setTitle:@"" forState:UIControlStateNormal];
            [self.securityCode setBackgroundImage:image forState:UIControlStateNormal];
        } else {
            [JDStatusBarNotification showWithStatus:@"验证码获取失败" dismissAfter:1.5];
            [self.securityCode setTitle:@"刷新" forState:UIControlStateNormal];
            [self.securityCode setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)postComment:(UIButton *)sender {
    NSString *content = [self.contentText text];
    //NSString *content = [[self.contentText text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([content length] == 0) {
        NSString *msg = @"评论不能为空";
        [JDStatusBarNotification showWithStatus:msg dismissAfter:2];
        return;
    }
    NSString *code = [self.codeText text];
    if (code.length == 0) {
        NSString *msg = @"请输入验证码";
        [JDStatusBarNotification showWithStatus:msg dismissAfter:2];
        return;
    }
    
    if (self.tid == nil) {
        [[HTTPRequester sharedHTTPRequester]postCommentToNewsWithSid:self.sid content:content securityCode:code completion:^(id responseObject, NSError *error) {
            if (error) {
                [self refetchSecurityCode:nil];
                [WKProgressHUD popMessage:@"评论失败" inView:self.view duration:1.5 animated:YES];
                //[JDStatusBarNotification showWithStatus:@"评论失败" dismissAfter:2];
                return;
            } else {
                NSDictionary *resultDic = responseObject;
                if ([resultDic[@"state"] isEqualToString:@"success"]) {
                    //[WKProgressHUD popMessage:@"评论成功，等待后台审核，请稍后刷新" inView:self.view duration:1.5 animated:YES];
                    [self showNotificationWithText:@"评论成功，等待后台审核，请稍后刷新"];
                    //[JDStatusBarNotification showWithStatus:@"评论成功，请稍后刷新" dismissAfter:2];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
                } else {
                    [self refetchSecurityCode:nil];
                    [WKProgressHUD popMessage:resultDic[@"error"] inView:self.view duration:1.5 animated:YES];
                    //[JDStatusBarNotification showWithStatus:resultDic[@"error"] dismissAfter:2];
                }
            }
        }];
    } else {
        [[HTTPRequester sharedHTTPRequester]replyCommentWithSid:self.sid andTid:self.tid content:content securityCode:code completion:^(id responseObject, NSError *error) {
            if (error) {
                [self refetchSecurityCode:nil];
                [WKProgressHUD popMessage:@"评论失败" inView:self.view duration:1.5 animated:YES];
                //[JDStatusBarNotification showWithStatus:@"回复失败" dismissAfter:2];
                return;
            } else {
                NSDictionary *resultDic = responseObject;
                if ([resultDic[@"state"] isEqualToString:@"success"]) {
                    [self showNotificationWithText:@"回复成功，等待后台审核，请稍后刷新"];
                    //[JDStatusBarNotification showWithStatus:@"回复成功，等待后台审核，请稍后刷新" dismissAfter:2];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
                } else {
                    [self refetchSecurityCode:nil];
                    [WKProgressHUD popMessage:resultDic[@"error"] inView:self.view duration:1.5 animated:YES];
                    //[JDStatusBarNotification showWithStatus:resultDic[@"error"] dismissAfter:2];
                }
            }
        }];
    }
    
}

- (void)showNotificationWithText:(NSString *)text
{
    NSDictionary *options = @{
                              kCRToastTextKey : text,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor greenColor],
                              kCRToastKeepNavigationBarBorderKey : @(CRToastTypeNavigationBar),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

- (IBAction)codeText_DidEndOnExit:(UITextField *)sender {
    [sender resignFirstResponder];
    //[self.postComment sendActionsForControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
    
    CGRect frame = textField.frame;
    
    CGFloat heights = self.view.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一步 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = frame.origin.y + 42- ( heights - 216.0-35.0);//键盘高度216
    
    
    if(offset > 0)
    
    {
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        float width = self.view.frame.size.width;
        
        float height = self.view.frame.size.height;
        
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.view.frame.origin.y < 0) {
        [self.view endEditing:YES];
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    
    if (self.view.frame.origin.y < 0) {
        [self.view endEditing:YES];
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.view.frame.origin.y < 0) {
        [self.view endEditing:YES];
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }
    [self.postComment sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
