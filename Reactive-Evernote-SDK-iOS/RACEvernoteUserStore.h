//
// Created by rizumita on 2014/02/03.
//


#import <Foundation/Foundation.h>
#import "RACENAPI.h"


@interface RACEvernoteUserStore : RACENAPI

///---------------------------------------------------------------------------------------
/// @name Creating a NoteStore
///---------------------------------------------------------------------------------------

/** Get an instance, using the shared EvernoteSession. */
+ (instancetype)userStore;

/** Construct an instance with the given session.

 @param session The Evernote session object
 */
- (id)initWithSession:(RACEvernoteSession *)session;

///---------------------------------------------------------------------------------------
/// @name UserStore methods
///---------------------------------------------------------------------------------------

/** This should be the first call made by a client to the EDAM service. It tells the service what protocol version is used by the client.

 The service will then return true if the client is capable of talking to the service, and false if the client's protocol version is incompatible with the service, so the client must upgrade. If a client receives a false value, it should report the incompatibility to the user and not continue with any more EDAM requests (UserStore or NoteStore).

 @param  clientName This string provides some information about the client for tracking/logging on the service. It should provide information about the client's software and platform. The structure should be: application/version; platform/version; [ device/version ] E.g. "Evernote Windows/3.0.1; Windows/XP SP3" or "Evernote Clipper/1.0.1; JME/2.0; Motorola RAZR/2.0;

 @param  edamVersionMajor This should be the major protocol version that was compiled by the client. This should be the current value of the EDAM_VERSION_MAJOR constant for the client.
 @param  edamVersionMinor This should be the major protocol version that was compiled by the client. This should be the current value of the EDAM_VERSION_MINOR constant for the client.

 */
- (RACSignal *)checkVersionWithClientName:(NSString *)clientName
                         edamVersionMajor:(int16_t)edamVersionMajor
                         edamVersionMinor:(int16_t)edamVersionMinor;

/** This provides bootstrap information to the client.

 Various bootstrap profiles and settings may be used by the client to configure itself.

 @param  locale The client's current locale, expressed in language[_country] format. E.g., "en_US". See ISO-639 and ISO-3166 for valid language and country codes.

 */
- (RACSignal *)getBootstrapInfoWithLocale:(NSString *)locale;

/** Returns the User corresponding to the provided authentication token, or throws an exception if this token is not valid.

 The level of detail provided in the returned User structure depends on the access level granted by the token, so a web service client may receive fewer fields than an integrated desktop client.

 */
- (RACSignal *)getUser;

/** Asks the UserStore about the publicly available location information for a particular username.

 @param username The username for the location information

 */
- (RACSignal *)getPublicUserInfoWithUsername:(NSString *)username;

/** Returns information regarding a user's Premium account corresponding to the provided authentication token, or throws an exception if this token is not valid.
 */
- (RACSignal *)getPremiumInfo;

/** Returns the URL that should be used to talk to the NoteStore for the account represented by the provided authenticationToken.

 This method isn't needed by most clients, who can retrieve the correct NoteStore URL from the AuthenticationResult returned from the authenticate or refreshAuthentication calls. This method is typically only needed to look up the correct URL for a long-lived session token (e.g. for an OAuth web service).

 */
- (RACSignal *)getNoteStoreUrl;

/** This is used to take an existing authentication token that grants access to an individual user account (returned from 'authenticate', 'authenticateLongSession' or an OAuth authorization) and obtain an additional authentication token that may be used to access business notebooks if the user is a member of an Evernote Business account.

 The resulting authentication token may be used to make NoteStore API calls against the business using the NoteStore URL returned in the result.

 */
- (RACSignal *)authenticateToBusiness;

/** Revoke an existing long lived authentication token. This can be used to revoke OAuth tokens or tokens created by calling authenticateLongSession, and allows a user to effectively log out of Evernote from the perspective of the application that holds the token. The authentication token that is passed is immediately revoked and may not be used to call any authenticated EDAM function.

 @param authenticationToken the authentication token to revoke.

 */
- (RACSignal *)revokeLongSessionWithAuthenticationToken:(NSString *)authenticationToken;

@end