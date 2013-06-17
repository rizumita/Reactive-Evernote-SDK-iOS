//
// Created by rizumita on 2013/04/23.
//


#import "RACENAPI.h"

@interface RACENAPI ()

@property (nonatomic, strong) NSArray *errorDescriptions;

@end

@implementation RACENAPI
{

}

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super init];
    if (self) {
        self.session = session;
        self.errorDescriptions = @[@"No information available about the error",
                @"The format of the request data was incorrect",
                @"Not permitted to perform action",
                @"Unexpected problem with the service",
                @"A required parameter/field was absent",
                @"Operation denied due to data model limit",
                @"Operation denied due to user storage limit",
                @"Username and/or password incorrect",
                @"Authentication token expired",
                @"Change denied due to data model conflict",
                @"Content of submitted note was malformed",
                @"Service shard with account data is temporarily down",
                @"Operation denied due to data model limit, where something such as a string length was too short",
                @"Operation denied due to data model limit, where something such as a string length was too long",
                @"Operation denied due to data model limit, where there were too few of something.",
                @"Operation denied due to data model limit, where there were too many of something.",
                @"Operation denied because it is currently unsupported.",
                @"Operation denied because access to the corresponding object is prohibited in response to a take-down notice."];
    }
    return self;
}

- (EDAMNoteStoreClient *)noteStore
{
    if (_noteStore) return _noteStore;

    _noteStore = [self.session noteStore];
    return _noteStore;
}

- (EDAMUserStoreClient *)userStore
{
    return [self.session userStore];
}

- (EDAMNoteStoreClient *)businessNoteStore
{
    return [self.session businessNoteStore];
}

- (NSError *)errorFromNSException:(NSException *)exception
{
    if (exception) {
        int errorCode = EDAMErrorCode_UNKNOWN;
        if ([exception respondsToSelector:@selector(errorCode)]) {
            // Evernote Thrift exception classes have an errorCode property
            errorCode = [(id)exception errorCode];
        } else if ([exception isKindOfClass:[TException class]]) {
            // treat any Thrift errors as a transport error
            // we could create separate error codes for the various TException subclasses
            errorCode = EvernoteSDKErrorCode_TRANSPORT_ERROR;
        }

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
        if (errorCode >= EDAMErrorCode_UNKNOWN && errorCode <= EDAMErrorCode_UNSUPPORTED_OPERATION) {
            // being defensive here
            if (self.errorDescriptions && self.errorDescriptions.count >= EDAMErrorCode_UNSUPPORTED_OPERATION) {
                if (userInfo[NSLocalizedDescriptionKey] == nil) {
                    userInfo[NSLocalizedDescriptionKey] = self.errorDescriptions[errorCode - 1];
                }
            }
        }
        if ([exception respondsToSelector:@selector(parameter)]) {
            NSString *parameter = [(id)exception parameter];
            if (parameter) {
                [userInfo setValue:parameter forKey:@"parameter"];
            }
        }
        return [NSError errorWithDomain:EvernoteSDKErrorDomain code:errorCode userInfo:userInfo];
    }
    return nil;
}

- (RACSignal *)signalWithBoolBlock:(BOOL (^)())block
{
    RACScheduler *scheduler= [RACScheduler currentScheduler]?:[RACScheduler scheduler];
    return [RACSignal startWithScheduler:scheduler subjectBlock:^(RACSubject *subject) {
        dispatch_async(self.session.queue, ^(void) {
            __block BOOL retVal = NO;
            @try {
                if (block) {
                    retVal = block();
                }
                [subject sendNext:@(retVal)];
                [subject sendCompleted];
            }
            @catch (NSException *exception) {
                NSError *error = [self errorFromNSException:exception];
                [self processError:error subscriber:subject];
            }
        });
    }];
}

- (RACSignal *)signalWithInt32Block:(int32_t (^)())block
{
    RACScheduler *scheduler= [RACScheduler currentScheduler]?:[RACScheduler scheduler];
    return [RACSignal startWithScheduler:scheduler subjectBlock:^(RACSubject *subject) {
        dispatch_async(self.session.queue, ^(void) {
            __block int32_t retVal = -1;
            @try {
                if (block) {
                    retVal = block();
                }
                [subject sendNext:@(retVal)];
                [subject sendCompleted];
            }
            @catch (NSException *exception) {
                NSError *error = [self errorFromNSException:exception];
                [self processError:error subscriber:subject];
            }
        });
    }];
}

// use id instead of NSObject* so block type-checking is happy
- (RACSignal *)signalWithIdBlock:(id (^)())block
{
    RACScheduler *scheduler= [RACScheduler currentScheduler]?:[RACScheduler scheduler];
    return [RACSignal startWithScheduler:scheduler subjectBlock:^(RACSubject *subject) {
        dispatch_async(self.session.queue, ^(void) {
            id retVal = nil;
            @try {
                if (block) {
                    retVal = block();
                }
                [subject sendNext:retVal];
                [subject sendCompleted];
            }
            @catch (NSException *exception) {
                NSError *error = [self errorFromNSException:exception];
                [self processError:error subscriber:subject];
            }
        });
    }];
}

- (RACSignal *)signalWithVoidBlock:(void (^)())block
{
    RACScheduler *scheduler= [RACScheduler currentScheduler]?:[RACScheduler scheduler];
    return [RACSignal startWithScheduler:scheduler subjectBlock:^(RACSubject *subject) {
        dispatch_async(self.session.queue, ^(void) {
            @try {
                if (block) {
                    block();
                }
                [subject sendNext:nil];
                [subject sendCompleted];
            }
            @catch (NSException *exception) {
                NSError *error = [self errorFromNSException:exception];
                [self processError:error subscriber:subject];
            }
        });
    }];
}

- (void)processError:(NSError *)error subscriber:(id <RACSubscriber>)subscriber
{
    // See if we can trigger OAuth automatically
    BOOL didTriggerAuth = NO;
    if ([EvernoteSession isTokenExpiredWithError:error]) {
        [self.session logout];
        UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (!topVC.presentedViewController && topVC.isViewLoaded) {
            didTriggerAuth = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.session authenticateWithViewController:topVC completionHandler:^(NSError *authError) {
                    if (authError) {
                        [subscriber sendError:authError];
                    } else {
                        [subscriber sendError:[NSError errorWithDomain:EvernoteSDKErrorDomain code:-1 userInfo:nil]];
                    }
                }];
            });
        }

    }
    // If we were not able to trigger auth, send the error over to the client
    if (didTriggerAuth == NO) {
        [subscriber sendError:error];
    }
}

@end