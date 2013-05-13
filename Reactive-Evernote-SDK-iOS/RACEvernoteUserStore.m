//
// Created by rizumita on 2013/04/23.
//


#import "RACEvernoteUserStore.h"
#import "RACSignal.h"
#import "EXTScope.h"
#import "EvernoteSession.h"


@implementation RACEvernoteUserStore
{

}

+ (instancetype)userStore
{
    RACEvernoteUserStore *userStore = [[RACEvernoteUserStore alloc] initWithSession:[EvernoteSession sharedSession]];
    return userStore;
}

- (id)initWithSession:(EvernoteSession *)session
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
    @weakify(self);
    return [self signalWithBoolBlock:^BOOL {
        @strongify(self);
        return [self.userStore checkVersion:clientName edamVersionMajor:edamVersionMajor edamVersionMinor:edamVersionMinor];
    }];
}

- (RACSignal *)getBootstrapInfoWithLocale:(NSString *)locale
{
    @weakify(self);
    return [self signalWithIdBlock:^id {
        @strongify(self);
        return [self.userStore getBootstrapInfo:locale];
    }];
}

- (RACSignal *)getUser
{
    @weakify(self);
    return [self signalWithIdBlock:^id {
        @strongify(self);
        return [self.userStore getUser:[[EvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)getPublicUserInfoWithUsername:(NSString *)username
{
    @weakify(self);
    return [self signalWithIdBlock:^id {
        @strongify(self);
        return [self.userStore getPublicUserInfo:username];
    }];
}

- (RACSignal *)getPremiumInfo
{
    @weakify(self);
    return [self signalWithIdBlock:^id {
        @strongify(self);
        return [self.userStore getPremiumInfo:[[EvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)getNoteStoreUrl
{
    @weakify(self);
    return [self signalWithIdBlock:^id {
        @strongify(self);
        return [self.userStore getNoteStoreUrl:[[EvernoteSession sharedSession] authenticationToken]];
    }];
}

- (RACSignal *)authenticateToBusiness
{
    @weakify(self);
    return [self signalWithIdBlock:^id {
        @strongify(self);
        return [self.userStore authenticateToBusiness:[[EvernoteSession sharedSession] authenticationToken]];
    }];
}

@end