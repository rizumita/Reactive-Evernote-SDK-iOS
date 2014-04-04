Reactive-Evernote-SDK-iOS
=========================

Evernote SDK iOS with ReactiveCocoa

Sample
===============
```OBjective-C
[RACEvernoteSession setSharedSessionHost:BootstrapServerBaseURLStringUS consumerKey:consumerKey consumerSecret:consumerSecret];
[[[RACEvernoteSession rac_sharedSession] authenticateWithViewController:self] subscribeNext:^(id x) {
    [[[RACEvernoteNoteStore noteStore] listNotebooks] subscribeNext:^(NSArray *notebooks) {
        NSLog(@"%@", notebooks);
    }                                                         error:^(NSError *error) {
        NSLog(@"error: %@", error);
    }                                                     completed:^{
        NSLog(@"completed");
    }];
}];
```

License
===============
Reactive-Evernote-SDK-iOS is available under the MIT license. See the LICENSE file for more info.
