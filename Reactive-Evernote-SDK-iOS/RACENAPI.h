//
// Created by rizumita on 2014/02/03.
//


#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <evernote-sdk-ios/EvernoteSDK.h>


@class RACEvernoteSession;


@interface RACENAPI : NSObject

@property (nonatomic, strong) RACEvernoteSession *session;
@property (weak, nonatomic, readonly) EDAMNoteStoreClient *noteStore;
@property (weak, nonatomic, readonly) EDAMUserStoreClient *userStore;
@property (weak, nonatomic, readonly) EDAMNoteStoreClient *businessNoteStore;

- (id)initWithSession:(RACEvernoteSession *)session;

// Make an NSError from a given NSException.
- (NSError *)errorFromNSException:(NSException *)exception;

// asynchronously invoke the given blocks,
// calling back to success/failure on the main threa.
- (RACSignal *)invokeAsyncBoolBlock:(BOOL(^)())block;

- (RACSignal *)invokeAsyncInt32Block:(int32_t(^)())block;

- (RACSignal *)invokeAsyncIdBlock:(id(^)())block;

- (RACSignal *)invokeAsyncVoidBlock:(void (^)())block;
@end
