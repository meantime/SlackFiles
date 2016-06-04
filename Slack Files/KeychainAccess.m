//
//  KeychainAccess.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "KeychainAccess.h"

@implementation KeychainAccess

+ (OSStatus)writeData:(NSData *)data withServiceName:(NSString *)serviceName error:(out NSError **)error
{
    char const          *dataAccountChars = "data-account";
    char const          *serviceNameChars = [serviceName UTF8String];
    SecKeychainItemRef  keychainItem;
    OSStatus            keychainResult = SecKeychainFindGenericPassword(NULL,
                                                                        (UInt32) strlen(serviceNameChars),
                                                                        serviceNameChars,
                                                                        0,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        &keychainItem);

    if (noErr == keychainResult)
    {
        //  Just update the existing keychain item
        SecKeychainAttribute    accountAttribute;

        accountAttribute.tag = kSecAccountItemAttr;
        accountAttribute.length = (UInt32) strlen(dataAccountChars);
        accountAttribute.data = (void *) dataAccountChars;

        SecKeychainAttributeList attributes;

        attributes.count = 1;
        attributes.attr = &accountAttribute;
        keychainResult = SecKeychainItemModifyAttributesAndData(keychainItem,
                                                                &attributes,
                                                                (UInt32) data.length,
                                                                data.bytes);

        CFRelease(keychainItem);
    }
    else
    {
        //  add a new item to the keychain
        {
            keychainResult = SecKeychainAddGenericPassword(NULL,
                                                           (UInt32) strlen(serviceNameChars),
                                                           serviceNameChars,
                                                           (UInt32) strlen(dataAccountChars),
                                                           dataAccountChars,
                                                           (UInt32) data.length,
                                                           data.bytes,
                                                           NULL);
        }
    }

    if (noErr != keychainResult)
    {
        if (error)
        {
            NSString    *errorString = (__bridge_transfer NSString *) SecCopyErrorMessageString(keychainResult, NULL);

            *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:keychainResult
                                     userInfo:@{ NSLocalizedDescriptionKey : errorString } ];
        }
    }

    return keychainResult;
}

+ (NSData *)readDataWithServiceName:(NSString *)serviceName error:(out NSError **)error
{
    OSStatus            keychainResult = noErr;
    SecKeychainItemRef  keychainItem;
    void                *keychainData;
    UInt32              dataLength;
    char const          *serviceNameChars = [serviceName UTF8String];
    NSData              *result = nil;

    keychainResult = SecKeychainFindGenericPassword(NULL,
                                                    (UInt32) strlen(serviceNameChars),
                                                    serviceNameChars,
                                                    0,
                                                    NULL,
                                                    &dataLength,
                                                    &keychainData,
                                                    &keychainItem);
    if (noErr == keychainResult)
    {
        result = [NSData dataWithBytes:keychainData length:dataLength];

        SecKeychainItemFreeContent(NULL, keychainData);
        CFRelease(keychainItem);
    }
    else
    {
        if (error)
        {
            NSString    *errorString = (__bridge_transfer NSString *) SecCopyErrorMessageString(keychainResult, NULL);

            *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:keychainResult
                                     userInfo:@{ NSLocalizedDescriptionKey : errorString } ];
        }
    }

    return result;
}

+ (OSStatus)removeItemWithServiceName:(NSString *)serviceName error:(out NSError **)error
{
    SecKeychainItemRef  keychainItem;
    char const          *serviceNameChars = [serviceName UTF8String];
    OSStatus            keychainResult = SecKeychainFindGenericPassword(NULL,
                                                                        (UInt32) strlen(serviceNameChars),
                                                                        serviceNameChars,
                                                                        0,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        &keychainItem);

    if (noErr == keychainResult)
    {
        SecKeychainItemDelete(keychainItem);
        CFRelease(keychainItem);
    }
    else
    {
        if (error)
        {
            NSString    *errorString = (__bridge_transfer NSString *) SecCopyErrorMessageString(keychainResult, NULL);

            *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:keychainResult
                                     userInfo:@{ NSLocalizedDescriptionKey : errorString } ];
        }
    }

    return keychainResult;
}

@end