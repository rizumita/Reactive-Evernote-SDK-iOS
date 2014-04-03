//
// Created by rizumita on 2014/02/03.
//


#import "RACEvernoteSession.h"
#import "RACSignal.h"


@implementation RACEvernoteSession
{

}

- (id)init
{
    self = [super init];
    if (self) {
        self.scheduler = [RACScheduler scheduler];
    }
    return self;
}

+ (EvernoteSession *)sharedSession
{
    static RACEvernoteSession *sharedSession;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSession = [[RACEvernoteSession alloc] init];
    });
    return sharedSession;
}

+ (RACEvernoteSession *)rac_sharedSession
{
    return (RACEvernoteSession *)[self sharedSession];
}

- (RACSignal *)authenticateWithViewController:(UIViewController *)viewController
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [self authenticateWithViewController:viewController completionHandler:^(NSError *error) {
            if (error || !self.isAuthenticated) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:@YES];
                [subscriber sendCompleted];
            }
        }];

        return nil;
    }];
}

@end