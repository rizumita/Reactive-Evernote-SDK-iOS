//
// Created by rizumita on 2013/04/23.
//


#import <Foundation/Foundation.h>
#import "EDAM.h"
#import "EvernoteSDK.h"
#import "ReactiveCocoa.h"

@interface RACENAPI : NSObject

@property (nonatomic, strong) EvernoteSession *session;
@property (weak, nonatomic, readonly) EDAMNoteStoreClient *noteStore;
@property (weak, nonatomic, readonly) EDAMUserStoreClient *userStore;
@property (weak, nonatomic, readonly) EDAMNoteStoreClient *businessNoteStore;

- (id)initWithSession:(EvernoteSession *)session;

// Make an NSError from a given NSException.
- (NSError *)errorFromNSException:(NSException *)exception;

// asynchronously invoke the given blocks,
- (RACSignal *)signalWithBoolBlock:(BOOL (^)())block;

- (RACSignal *)signalWithIdBlock:(id (^)())block;

- (RACSignal *)signalWithInt32Block:(int32_t (^)())block;

- (RACSignal *)signalWithVoidBlock:(void (^)())block;

@end