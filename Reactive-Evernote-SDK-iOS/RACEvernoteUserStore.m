//
// Created by rizumita on 2014/02/03.
//


#import "RACEvernoteUserStore.h"
#import "RACEvernoteSession.h"


@implementation RACEvernoteUserStore
{

}

+ (instancetype)userStore
{
    RACEvernoteUserStore *userStore = [[RACEvernoteUserStore alloc] initWithSession:[RACEvernoteSession sharedSession]];
    return userStore;
}

- (id)initWithSession:(RACEvernoteSession *)session
{
    self = [super initWithSession:session];
    if (self) {
    }
    return self;
}

#pragma mark - UserStore methods

- (RACSignal *)checkVersionWithClientName:(NSString *)clientName edamVersionMajor:(int16_t)edamVersionMajor
                         edamVersionMinor:(int16_t)edamVersionMinor
{
    return [self invokeAsyncBoolBlock:^BOOL{
        return [self.userStore checkVersion:clientName edamVersionMajor:edamVersionMajor edamVersionMinor:edamVersionMinor];
    } ];
}

- (RACSignal *)getBootstrapInfoWithLocale:(NSString *)locale
{
    return [self invokeAsyncIdBlock:^id {
        return [self.userStore getBootstrapInfo:locale];
    }];
}

- (RACSignal *)getUser
{
    return [self invokeAsyncIdBlock:^id {
        return [self.userStore getUser:[[RACEvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)getPublicUserInfoWithUsername:(NSString *)username
{
    return [self invokeAsyncIdBlock:^id {
        return [self.userStore getPublicUserInfo:username];
    }];
}

- (RACSignal *)getPremiumInfo
{
    return [self invokeAsyncIdBlock:^id {
        return [self.userStore getPremiumInfo:[[RACEvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)getNoteStoreUrl
{
    return [self invokeAsyncIdBlock:^id {
        return [self.userStore getNoteStoreUrl:[[RACEvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)authenticateToBusiness
{
    return [self invokeAsyncIdBlock:^id {
        return [self.userStore authenticateToBusiness:[[RACEvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)revokeLongSessionWithAuthenticationToken:(NSString *)authenticationToken
{
    return [self invokeAsyncVoidBlock:^void {
        [self.userStore revokeLongSession:authenticationToken];
    }];
}

@end