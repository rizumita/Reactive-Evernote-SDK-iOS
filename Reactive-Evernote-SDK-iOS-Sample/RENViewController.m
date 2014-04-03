//
//  RENViewController.m
//  Reactive-Evernote-SDK-iOS-Sample
//
//  Created by 和泉田 領一 on 2013/04/23.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import "RENViewController.h"
#import "ReactiveCocoa.h"
#import "EvernoteSDK.h"
#import "RACEvernoteNoteStore.h"
#import "RACEvernoteSession.h"
#import "extobjc/RACEXTScope.h"

@interface RENViewController ()

@end

@implementation RENViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    @weakify(self);
    [[RACSignal combineLatest:@[self.consumerKeyTextField.rac_textSignal, self.consumerSecretTextField.rac_textSignal] reduce:^(NSString *consumerKey, NSString *consumerSecret) {
        return @(consumerKey.length > 0 && consumerSecret.length > 0);
    }] subscribeNext:^(NSNumber *boolNumber) {
        @strongify(self);
        self.logInButton.enabled = boolNumber.boolValue;
    }];

    [[self.logInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [RACEvernoteSession setSharedSessionHost:(self.sandboxSwitch.on ? BootstrapServerBaseURLStringSandbox : BootstrapServerBaseURLStringUS) consumerKey:self.consumerKeyTextField.text consumerSecret:self.consumerSecretTextField.text];
        [[[RACEvernoteSession rac_sharedSession] authenticateWithViewController:self] subscribeNext:^(id x) {

        }];
    }];

    [[self.logOutButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[RACEvernoteSession rac_sharedSession] logout];
    }];

    [[self.listNotebookButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[[RACEvernoteNoteStore noteStore] listNotebooks] subscribeNext:^(NSArray *notebooks) {
            NSLog(@"%@", notebooks);
        }                                                         error:^(NSError *error) {
            NSLog(@"error: %@", error);
        }                                                     completed:^{
            NSLog(@"completed");
        }];
    }];

    [[self.listTagsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[[RACEvernoteNoteStore noteStore] listTags] subscribeNext:^(NSArray *tags) {
            NSLog(@"%@", tags);
        }                                                    error:^(NSError *error) {
            NSLog(@"error: %@", error);
        }                                                completed:^{
            NSLog(@"completed");
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
