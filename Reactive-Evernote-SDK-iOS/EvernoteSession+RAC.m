//
// Created by rizumita on 2013/04/23.
//


#import "EvernoteSession+RAC.h"
#import "EXTScope.h"


@implementation EvernoteSession (RAC)

- (RACSignal *)authenticateWithViewController:(UIViewController *)viewController
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self);
        [self authenticateWithViewController:viewController completionHandler:^(NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:@(self.isAuthenticated)];
                [subscriber sendCompleted];
            }
        }];

        return [RACDisposable disposableWithBlock:^{}];
    }];
}

@end