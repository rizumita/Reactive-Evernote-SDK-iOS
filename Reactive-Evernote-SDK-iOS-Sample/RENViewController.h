//
//  RENViewController.h
//  Reactive-Evernote-SDK-iOS-Sample
//
//  Created by 和泉田 領一 on 2013/04/23.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RENViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *consumerKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *consumerSecretTextField;
@property (weak, nonatomic) IBOutlet UISwitch *sandboxSwitch;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *listNotebookButton;
@property (weak, nonatomic) IBOutlet UIButton *listTagsButton;
@end
