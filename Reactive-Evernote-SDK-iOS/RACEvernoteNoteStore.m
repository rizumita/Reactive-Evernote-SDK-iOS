//
// Created by rizumita on 2014/02/03.
//


#import <Evernote-SDK-iOS/EvernoteSDK.h>
#import "RACEvernoteNoteStore.h"
#import "RACEvernoteSession.h"


@interface RACEvernoteNoteStore ()

@property (nonatomic, assign) BOOL isBusiness;
@property (nonatomic, strong) EDAMLinkedNotebook *linkedNotebook;

@end

@implementation RACEvernoteNoteStore
{

}

+ (instancetype)noteStore
{
    RACEvernoteNoteStore *noteStore = [[RACEvernoteNoteStore alloc] initWithSession:[RACEvernoteSession sharedSession]];
    noteStore.isBusiness = NO;
    noteStore.linkedNotebook = nil;
    return noteStore;
}

+ (instancetype)businessNoteStore
{
    RACEvernoteNoteStore *noteStore = [[RACEvernoteNoteStore alloc] initWithSession:[RACEvernoteSession sharedSession]];
    noteStore.isBusiness = YES;
    noteStore.linkedNotebook = nil;
    return noteStore;
}

+ (instancetype)noteStoreForLinkedNotebook:(EDAMLinkedNotebook *)notebook
{
    RACEvernoteNoteStore *noteStore = [[RACEvernoteNoteStore alloc] initWithSession:[RACEvernoteSession sharedSession]];
    noteStore.isBusiness = NO;
    noteStore.linkedNotebook = notebook;
    return noteStore;
}

- (EDAMNoteStoreClient *)currentNoteStore
{
    if (self.linkedNotebook) {
        EDAMNoteStoreClient *noteStoreClient = [[RACEvernoteSession sharedSession] noteStoreWithNoteStoreURL:self.linkedNotebook.noteStoreUrl];
        return noteStoreClient;
    } else if (self.isBusiness) {
        return self.businessNoteStore;
    }
    return self.noteStore;
}

- (NSString *)authenticationToken
{
    RACEvernoteSession *sharedSession = (RACEvernoteSession *)[RACEvernoteSession sharedSession];
    if (self.linkedNotebook) {
        EDAMNoteStoreClient *noteStoreClient = [sharedSession noteStoreWithNoteStoreURL:self.linkedNotebook.noteStoreUrl];
        EDAMAuthenticationResult *authResult = [noteStoreClient authenticateToSharedNotebook:self.linkedNotebook.shareKey authenticationToken:sharedSession.authenticationToken];
        return authResult.authenticationToken;
    }
    else if (self.isBusiness) {
        return self.session.businessAuthenticationToken;
    }
    return self.session.authenticationToken;
}

- (id)initWithSession:(RACEvernoteSession *)session
{
    self = [super initWithSession:session];
    if (self) {
    }
    return self;
}

#pragma mark - NoteStore sync methods

- (RACSignal *)getSyncState
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSyncState:[self authenticationToken]];
    }];
}

- (RACSignal *)getSyncChunkAfterUSN:(int32_t)afterUSN maxEntries:(int32_t)maxEntries fullSyncOnly:(BOOL)fullSyncOnly
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSyncChunk:[self authenticationToken] afterUSN:afterUSN maxEntries:maxEntries fullSyncOnly:fullSyncOnly];
    }];
}

- (RACSignal *)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN maxEntries:(int32_t)maxEntries
                                     filter:(EDAMSyncChunkFilter *)filter
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getFilteredSyncChunk:[self authenticationToken] afterUSN:afterUSN maxEntries:maxEntries filter:filter];
    }];
}

- (RACSignal *)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getLinkedNotebookSyncState:[self authenticationToken] linkedNotebook:linkedNotebook];
    }];
}

#pragma mark - NoteStore notebook methods

- (RACSignal *)listNotebooks
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listNotebooks:[self authenticationToken]];
    }];
}

- (RACSignal *)getNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNotebook:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook afterUSN:(int32_t)afterUSN
                               maxEntries:(int32_t)maxEntries fullSyncOnly:(BOOL)fullSyncOnly
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getLinkedNotebookSyncChunk:[self authenticationToken] linkedNotebook:linkedNotebook afterUSN:afterUSN maxEntries:maxEntries fullSyncOnly:fullSyncOnly];
    }];
}

- (RACSignal *)getDefaultNotebook
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getDefaultNotebook:[self authenticationToken]];
    }];
}

- (RACSignal *)createNotebook:(EDAMNotebook *)notebook
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createNotebook:[self authenticationToken] notebook:notebook];
    }];
}

- (RACSignal *)updateNotebook:(EDAMNotebook *)notebook
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateNotebook:[self authenticationToken] notebook:notebook];
    }];
}

- (RACSignal *)expungeNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeNotebook:[self authenticationToken] guid:guid];
    }];
}

#pragma mark - NoteStore tags methods

- (RACSignal *)listTags
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listTags:[self authenticationToken]];
    }];
}

- (RACSignal *)listTagsByNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listTagsByNotebook:[self authenticationToken] notebookGuid:guid];
    }];
};

- (RACSignal *)getTagWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getTag:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)createTag:(EDAMTag *)tag
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createTag:[self authenticationToken] tag:tag];
    }];
}

- (RACSignal *)updateTag:(EDAMTag *)tag
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateTag:[self authenticationToken] tag:tag];
    }];
}

- (RACSignal *)untagAllWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncVoidBlock:^{
        [[self currentNoteStore] untagAll:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)expungeTagWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeTag:[self authenticationToken] guid:guid];
    }];
}

#pragma mark - NoteStore search methods

- (RACSignal *)listSearches
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listSearches:[self authenticationToken]];
    }];
}

- (RACSignal *)getSearchWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSearch:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)createSearch:(EDAMSavedSearch *)search
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createSearch:[self authenticationToken] search:search];
    }];
}

- (RACSignal *)updateSearch:(EDAMSavedSearch *)search
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateSearch:[self authenticationToken] search:search];
    }];
}

- (RACSignal *)expungeSearchWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeSearch:[self authenticationToken] guid:guid];
    }];
}

#pragma mark - NoteStore notes methods
- (RACSignal *)findRealtedWithQuery:(EDAMRelatedQuery *)query resultSpec:(EDAMRelatedResultSpec *)resultSpec
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findRelated:[self authenticationToken] query:query resultSpec:resultSpec];
    }];
}

- (RACSignal *)findNotesWithFilter:(EDAMNoteFilter *)filter offset:(int32_t)offset maxNotes:(int32_t)maxNotes
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findNotes:[self authenticationToken] filter:filter offset:offset maxNotes:maxNotes];
    }];
}

- (RACSignal *)findNoteOffsetWithFilter:(EDAMNoteFilter *)filter guid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] findNoteOffset:[self authenticationToken] filter:filter guid:guid];
    }];
}

- (RACSignal *)findNotesMetadataWithFilter:(EDAMNoteFilter *)filter offset:(int32_t)offset maxNotes:(int32_t)maxNotes
                                resultSpec:(EDAMNotesMetadataResultSpec *)resultSpec
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findNotesMetadata:[self authenticationToken] filter:filter offset:offset maxNotes:maxNotes resultSpec:resultSpec];
    }];
}

- (RACSignal *)findNoteCountsWithFilter:(EDAMNoteFilter *)filter withTrash:(BOOL)withTrash
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findNoteCounts:[self authenticationToken] filter:filter withTrash:withTrash];
    }];
}

- (RACSignal *)getNoteWithGuid:(EDAMGuid)guid withContent:(BOOL)withContent withResourcesData:(BOOL)withResourcesData
      withResourcesRecognition:(BOOL)withResourcesRecognition
    withResourcesAlternateData:(BOOL)withResourcesAlternateData
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNote:[self authenticationToken] guid:guid withContent:withContent withResourcesData:withResourcesData withResourcesRecognition:withResourcesRecognition withResourcesAlternateData:withResourcesAlternateData];
    }];
}

- (RACSignal *)getNoteApplicationDataWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteApplicationData:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getNoteApplicationDataEntryWithGuid:(EDAMGuid)guid key:(NSString *)key
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteApplicationDataEntry:[self authenticationToken] guid:guid key:key];
    }];
}

- (RACSignal *)setNoteApplicationDataEntryWithGuid:(EDAMGuid)guid key:(NSString *)key value:(NSString *)value
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] setNoteApplicationDataEntry:[self authenticationToken] guid:guid key:key value:value];
    }];
}

- (RACSignal *)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid key:(NSString *)key
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] unsetNoteApplicationDataEntry:[self authenticationToken] guid:guid key:key];
    }];
}

- (RACSignal *)getNoteContentWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteContent:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getNoteSearchTextWithGuid:(EDAMGuid)guid noteOnly:(BOOL)noteOnly
                     tokenizeForIndexing:(BOOL)tokenizeForIndexing
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteSearchText:[self authenticationToken] guid:guid noteOnly:noteOnly tokenizeForIndexing:tokenizeForIndexing];
    }];
}

- (RACSignal *)getResourceSearchTextWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceSearchText:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getNoteTagNamesWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteTagNames:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)createNote:(EDAMNote *)note
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createNote:[self authenticationToken] note:note];
    }];
}

- (RACSignal *)updateNote:(EDAMNote *)note
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] updateNote:[self authenticationToken] note:note];
    }];
}

- (RACSignal *)deleteNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] deleteNote:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)expungeNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeNote:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)expungeNotesWithGuids:(NSMutableArray *)guids
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeNotes:[self authenticationToken] noteGuids:guids];
    }];
}

- (RACSignal *)expungeInactiveNote
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeInactiveNotes:[self authenticationToken]];
    }];
}

- (RACSignal *)copyNoteWithGuid:(EDAMGuid)guid toNoteBookGuid:(EDAMGuid)toNotebookGuid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] copyNote:[self authenticationToken] noteGuid:guid toNotebookGuid:toNotebookGuid];
    }];
}

- (RACSignal *)listNoteVersionsWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listNoteVersions:[self authenticationToken] noteGuid:guid];
    }];
}

- (RACSignal *)getNoteVersionWithGuid:(EDAMGuid)guid updateSequenceNum:(int32_t)updateSequenceNum
                    withResourcesData:(BOOL)withResourcesData withResourcesRecognition:(BOOL)withResourcesRecognition
           withResourcesAlternateData:(BOOL)withResourcesAlternateData
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteVersion:[self authenticationToken] noteGuid:guid updateSequenceNum:updateSequenceNum withResourcesData:withResourcesData withResourcesRecognition:withResourcesRecognition withResourcesAlternateData:withResourcesAlternateData];
    }];
}

#pragma mark - NoteStore resource methods

- (RACSignal *)getResourceWithGuid:(EDAMGuid)guid withData:(BOOL)withData withRecognition:(BOOL)withRecognition
                    withAttributes:(BOOL)withAttributes withAlternateDate:(BOOL)withAlternateData
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResource:[self authenticationToken] guid:guid withData:withData withRecognition:withRecognition withAttributes:withAttributes withAlternateData:withAlternateData];
    }];
}

- (RACSignal *)getResourceApplicationDataWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceApplicationData:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getResourceApplicationDataEntryWithGuid:(EDAMGuid)guid key:(NSString *)key
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceApplicationDataEntry:[self authenticationToken] guid:guid key:key];
    }];
}

- (RACSignal *)setResourceApplicationDataEntryWithGuid:(EDAMGuid)guid key:(NSString *)key value:(NSString *)value
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] setResourceApplicationDataEntry:[self authenticationToken] guid:guid key:key value:value];
    }];
}

- (RACSignal *)unsetResourceApplicationDataEntryWithGuid:(EDAMGuid)guid key:(NSString *)key
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] unsetResourceApplicationDataEntry:[self authenticationToken] guid:guid key:key];
    }];
}

- (RACSignal *)updateResource:(EDAMResource *)resource
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateResource:[self authenticationToken] resource:resource];
    }];
}

- (RACSignal *)getResourceDataWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceData:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getResourceByHashWithGuid:(EDAMGuid)guid contentHash:(NSData *)contentHash withData:(BOOL)withData
                         withRecognition:(BOOL)withRecognition withAlternateData:(BOOL)withAlternateData
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceByHash:[self authenticationToken] noteGuid:guid contentHash:contentHash withData:withData withRecognition:withRecognition withAlternateData:withAlternateData];
    }];
}

- (RACSignal *)getResourceRecognitionWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceRecognition:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getResourceAlternateDataWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceAlternateData:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)getResourceAttributesWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceAttributes:[self authenticationToken] guid:guid];
    }];
}

#pragma mark - NoteStore shared notebook methods

- (RACSignal *)getPublicNotebookWithUserID:(EDAMUserID)userId publicUri:(NSString *)publicUri
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getPublicNotebook:userId publicUri:publicUri];
    }];
}

- (RACSignal *)createSharedNotebook:(EDAMSharedNotebook *)sharedNotebook
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createSharedNotebook:[self authenticationToken] sharedNotebook:sharedNotebook];
    }];
}

- (RACSignal *)sendMessageToSharedNotebookMembersWithGuid:(EDAMGuid)guid messageText:(NSString *)messageText
                                               recipients:(NSMutableArray *)recipients
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] sendMessageToSharedNotebookMembers:[self authenticationToken] notebookGuid:guid messageText:messageText recipients:recipients];
    }];
}

- (RACSignal *)listSharedNotebooks
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listSharedNotebooks:[self authenticationToken]];
    }];
}

- (RACSignal *)expungeSharedNotebooksWithIds:(NSMutableArray *)sharedNotebookIds
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeSharedNotebooks:[self authenticationToken] sharedNotebookIds:sharedNotebookIds];
    }];
}

- (RACSignal *)createLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createLinkedNotebook:[self authenticationToken] linkedNotebook:linkedNotebook];
    }];
}

- (RACSignal *)updateLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateLinkedNotebook:[self authenticationToken] linkedNotebook:linkedNotebook];
    }];
}

- (RACSignal *)listLinkedNotebooks
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listLinkedNotebooks:[self authenticationToken]];
    }];
}

- (RACSignal *)expungeLinkedNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeLinkedNotebook:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)authenticateToSharedNotebookWithShareKey:(NSString *)shareKey
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] authenticateToSharedNotebook:shareKey authenticationToken:[self authenticationToken]];
    }];
}

- (RACSignal *)getSharedNotebookByAuth
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSharedNotebookByAuth:[self authenticationToken]];
    }];
}

- (RACSignal *)emailNoteWithParameters:(EDAMNoteEmailParameters *)parameters
{
    return [self invokeAsyncVoidBlock:^{
        [[self currentNoteStore] emailNote:[self authenticationToken] parameters:parameters];
    }];
}

- (RACSignal *)shareNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] shareNote:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)stopSharingNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeAsyncVoidBlock:^{
        [[self currentNoteStore] stopSharingNote:[self authenticationToken] guid:guid];
    }];
}

- (RACSignal *)authenticateToSharedNoteWithGuid:(NSString *)guid noteKey:(NSString *)noteKey
                            authenticationToken:(NSString *)authenticationToken
{
    return [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] authenticateToSharedNote:guid noteKey:noteKey authenticationToken:authenticationToken];
    }];
}

- (RACSignal *)updateSharedNotebook:(EDAMSharedNotebook *)sharedNotebook
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateSharedNotebook:[self authenticationToken] sharedNotebook:sharedNotebook];
    }];
}

- (RACSignal *)setSharedNotebookRecipientSettingsWithSharedNotebookId:(int64_t)sharedNotebookId
                                                    recipientSettings:(EDAMSharedNotebookRecipientSettings *)recipientSettings
{
    return [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] setSharedNotebookRecipientSettings:[self authenticationToken] sharedNotebookId:sharedNotebookId recipientSettings:recipientSettings];
    }];
}

@end
