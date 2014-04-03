//
// Created by rizumita on 2014/02/03.
//


#import <Foundation/Foundation.h>
#import "EvernoteSDK.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface RACEvernoteSession : EvernoteSession

@property (nonatomic, strong) RACScheduler *scheduler;

+ (RACEvernoteSession *)rac_sharedSession;

- (RACSignal *)authenticateWithViewController:(UIViewController *)viewController;
@end