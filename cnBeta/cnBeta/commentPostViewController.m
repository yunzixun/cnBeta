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

@interface commentPostViewController ()
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
                [JDStatusBarNotification showWithStatus:@"评论失败" dismissAfter:2];
                return;
            } else {
                NSDictionary *resultDic = responseObject;
                if ([resultDic[@"state"] isEqualToString:@"success"]) {
                    [JDStatusBarNotification showWithStatus:@"评论成功，请稍后刷新" dismissAfter:2];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
                } else {
                    [self refetchSecurityCode:nil];
                    [JDStatusBarNotification showWithStatus:resultDic[@"error"] dismissAfter:2];
                }
            }
        }];
    } else {
        [[HTTPRequester sharedHTTPRequester]replyCommentWithSid:self.sid andTid:self.tid content:content securityCode:code completion:^(id responseObject, NSError *error) {
            if (error) {
                [self refetchSecurityCode:nil];
                [JDStatusBarNotification showWithStatus:@"回复失败" dismissAfter:2];
                return;
            } else {
                NSDictionary *resultDic = responseObject;
                if ([resultDic[@"state"] isEqualToString:@"success"]) {
                    [JDStatusBarNotification showWithStatus:@"回复成功，请稍后刷新" dismissAfter:2];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
                } else {
                    [self refetchSecurityCode:nil];
                    [JDStatusBarNotification showWithStatus:resultDic[@"error"] dismissAfter:2];
                }
            }
        }];
    }
    
}

- (IBAction)codeText_DidEndOnExit:(UITextField *)sender {
    [sender resignFirstResponder];
    [self.postComment sendActionsForControlEvents:UIControlEventTouchUpInside];
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
