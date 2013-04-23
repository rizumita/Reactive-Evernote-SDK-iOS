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
#import "EXTScope.h"
#import "RACEvernoteNoteStore.h"
#import "EvernoteSession+RAC.h"

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
        [EvernoteSession setSharedSessionHost:(self.sandboxSwitch.on ? BootstrapServerBaseURLStringSandbox : BootstrapServerBaseURLStringUS) consumerKey:self.consumerKeyTextField.text consumerSecret:self.consumerSecretTextField.text];
        [[[EvernoteSession sharedSession] authenticateWithViewController:self] subscribeNext:^(id x) {

        }];
    }];

    [[self.logOutButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[EvernoteSession sharedSession] logout];
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

- (void)viewDidUnload
{
    [self setListNotebookButton:nil];
    [self setListTagsButton:nil];
    [self setLogOutButton:nil];
    [self setLogInButton:nil];
    [super viewDidUnload];
}

@end
