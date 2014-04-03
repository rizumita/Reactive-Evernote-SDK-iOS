//
// Created by rizumita on 2014/02/03.
//


#import "RACENAPI.h"
#import "RACEvernoteSession.h"


@interface RACENAPI ()

@property (nonatomic, strong) NSArray *errorDescriptions;

@end

@implementation RACENAPI
{

}

- (id)initWithSession:(RACEvernoteSession *)session
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
                @"Operation denied because access to the corresponding object is prohibited in response to a take-down notice.",
                @"Operation denied because the calling application has reached its hourly API call limit for this user."];
    }
    return self;
}

- (EDAMNoteStoreClient *)noteStore
{
    return [self.session noteStore];
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
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
        if ([exception respondsToSelector:@selector(errorCode)]) {
            // Evernote Thrift exception classes have an errorCode property
            errorCode = [(id)exception errorCode];
        } else if ([exception isKindOfClass:[TException class]]) {
            // treat any Thrift errors as a transport error
            // we could create separate error codes for the various TException subclasses
            errorCode = EvernoteSDKErrorCode_TRANSPORT_ERROR;
            if ([exception.description length] > 0) {
                userInfo[NSLocalizedDescriptionKey] = exception.description;
            }
        }
        if (errorCode >= EDAMErrorCode_UNKNOWN && errorCode <= EDAMErrorCode_RATE_LIMIT_REACHED) {
            // being defensive here
            if (self.errorDescriptions && self.errorDescriptions.count >= EDAMErrorCode_RATE_LIMIT_REACHED) {
                if (userInfo[NSLocalizedDescriptionKey] == nil) {
                    userInfo[NSLocalizedDescriptionKey] = self.errorDescriptions[errorCode - 1];
                }
                if ([exception isKindOfClass:[EDAMSystemException class]] == YES) {
                    EDAMSystemException *systemException = (EDAMSystemException *)exception;
                    if ([systemException rateLimitDurationIsSet]) {
                        userInfo[@"rateLimitDuration"] = @([systemException rateLimitDuration]);
                    }
                    if ([systemException messageIsSet]) {
                        userInfo[@"message"] = [systemException message];
                    }
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

- (RACSignal *)invokeAsyncBoolBlock:(BOOL(^)())block
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        __block BOOL retVal = NO;
        @try {
            if (block) {
                retVal = block();
                [subscriber sendNext:@(retVal)];
            }
            [subscriber sendCompleted];
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:error];
            [subscriber sendError:error];
        }

        return nil;
    }] subscribeOn:self.session.scheduler];
}

- (RACSignal *)invokeAsyncInt32Block:(int32_t(^)())block
{
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        __block int32_t retVal = -1;
        @try {
            if (block) {
                retVal = block();
                [subscriber sendNext:@(retVal)];
            }
            [subscriber sendCompleted];
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:error];
            [subscriber sendError:error];
        }

        return nil;
    }] subscribeOn:self.session.scheduler];
}

// use id instead of NSObject* so block type-checking is happy
- (RACSignal *)invokeAsyncIdBlock:(id(^)())block
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        id retVal = nil;
        @try {
            if (block) {
                retVal = block();
                [subscriber sendNext:retVal];
            }
            [subscriber sendCompleted];
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:error];
            [subscriber sendError:error];
        }

        return nil;
    }];
}

- (RACSignal *)invokeAsyncVoidBlock:(void (^)())block
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @try {
            if (block) {
                block();
                [subscriber sendNext:nil];
            }
            [subscriber sendCompleted];
        }@catch (NSException *exception){
            NSError *error = [self errorFromNSException:exception];
            [self processError:error];
            [subscriber sendError:error];
        }

        return nil;
    }];
}

- (void)processError:(NSError *)error
{
    if ([RACEvernoteSession isTokenExpiredWithError:error]) {
        [self.session logout];
    }
}

@end