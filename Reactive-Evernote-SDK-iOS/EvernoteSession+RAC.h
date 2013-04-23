//
// Created by rizumita on 2013/04/23.
//


#import <Foundation/Foundation.h>
#import "EvernoteSession.h"
#import "ReactiveCocoa.h"

@interface EvernoteSession (RAC)

- (RACSignal *)authenticateWithViewController:(UIViewController *)viewController;

@end