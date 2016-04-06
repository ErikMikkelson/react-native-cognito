//
//  RCTCognito.m
//  RCTCognito
//
//  Created by Marcell Jusztin on 21/11/2015.
//  Copyright © 2015 Marcell Jusztin. All rights reserved.
//

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTCognito.h"

#import <AWSCognito/AWSCognito.h>
#import <AWSCore/AWSCore.h>

typedef AWSRegionType (^CaseBlock)();

@implementation RCTCognito

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

- (AWSRegionType)getRegionFromString:(NSString *)region {
    NSDictionary *regions = @{
                              @"eu-west-1" : ^{
                                  return AWSRegionEUWest1;
                              },
                              @"us-east-1" : ^{
                                  return AWSRegionUSEast1;
                              },
                              @"ap-northeast-1" : ^{
                                  return AWSRegionAPNortheast1;
                              },
                              };
    return ((CaseBlock)regions[region])();
}
AWSCognitoCredentialsProvider *credentialsProvider;
AWSServiceConfiguration *configuration;
NSString *identityPoolIdGlobal;
NSString *facebookToken;
RCT_EXPORT_METHOD(initCredentialsProvider: (NSString *)identityPoolId
                  : (NSString *)token
                  : (NSString *)region
                  ) {

    NSDictionary *logins =@{
                            @(AWSCognitoLoginProviderKeyFacebook) : token
                            };

    credentialsProvider =

    [[AWSCognitoCredentialsProvider alloc]
   /*  initWithRegionType:AWSRegionUSEast1 identityId:@"us-east-1:7d2ef4a9-6b0d-45e6-b0bd-68a147d337cd" accountId:@"614907439071" identityPoolId:identityPoolId unauthRoleArn:@"arn:aws:iam::614907439071:role/Cognito_NewCognitoAuth_Role"  authRoleArn:@"arn:aws:iam::614907439071:role/Cognito_NewCognitoUnauth_Role" logins:logins
     ];*/
     initWithRegionType:[self getRegionFromString:region]
     identityPoolId:identityPoolId
    ];

    credentialsProvider.logins = logins;

    facebookToken = token;
    identityPoolIdGlobal = identityPoolId;
     configuration = [[AWSServiceConfiguration alloc]
                                              initWithRegion:[self getRegionFromString:region]
                                              credentialsProvider:credentialsProvider];


   // [AWSServiceManager defaultServiceManager].defaultServiceConfiguration =
    //configuration;

}


RCT_REMAP_METHOD(getCognitoId,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{




    /*
    [[credentialsProvider refresh] continueWithBlock:^id(AWSTask * task) {
        NSLog(@"***** Credentials *******", credentialsProvider);
        resolve(credentialsProvider);
        return nil;

    }];
     */



     [[credentialsProvider getIdentityId] continueWithBlock:^id(AWSTask *task) {

         AWSCognitoIdentityGetOpenIdTokenInput *getTokenInput = [AWSCognitoIdentityGetOpenIdTokenInput alloc];

         getTokenInput.identityId = task.result;
         getTokenInput.logins = credentialsProvider.logins;



         AWSCognitoIdentity *identityObj = [AWSCognitoIdentity alloc];


         [[identityObj getOpenIdToken:getTokenInput] continueWithBlock:^id (AWSTask<AWSCognitoIdentityGetCredentialsForIdentityResponse *> *  task2) {
             NSLog(@"***** Credentials *******", task2.result.credentials);
             resolve(task2.result.credentials);
             return nil;

         }];


         /*


     AWSCognitoIdentityGetCredentialsForIdentityInput *getTokenInput = [AWSCognitoIdentityGetCredentialsForIdentityInput alloc];

     getTokenInput.identityId = task.result;
     getTokenInput.logins = credentialsProvider.logins;



     AWSCognitoIdentity *identityObj = [[AWSCognitoIdentity alloc]
                                        initWithConfiguration: configuration];
     [[identityObj getCredentialsForIdentity:getTokenInput] continueWithBlock:^id (AWSTask<AWSCognitoIdentityGetCredentialsForIdentityResponse *> *  task2) {
         NSLog(@"***** Credentials *******", task2.result.credentials);
         resolve(task2.result.credentials);
         return nil;

      }];
          */
         return nil;
    }];


    /*

    [[credentialsProvider getIdentityId] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            reject(@"Error", @"Failed to get CognitoId", task.error);
        }
        else {





            AWSCognitoCredentialsProvider *BasicCredentialsProvider =
            [[AWSCognitoCredentialsProvider alloc]

             initWithRegionType:configuration.regionType identityId:task.result accountId:@"614907439071" identityPoolId:identityPoolIdGlobal unauthRoleArn:@"arn:aws:iam::614907439071:role/Cognito_NewCognitoAuth_Role"  authRoleArn:@"arn:aws:iam::614907439071:role/Cognito_NewCognitoUnauth_Role" logins:credentialsProvider.logins
             ];


            [[BasicCredentialsProvider refresh] continueWithBlock:^id(AWSTask * task) {
                NSLog(@"***** Credentials *******", BasicCredentialsProvider);
                return nil;
                resolve(BasicCredentialsProvider);
            }];





        }
        return nil;
    }];
     */



    /*

    AWSCognitoIdentity *identity = [[AWSCognitoIdentity alloc]
                                    initWithConfiguration:BasicCredentialsProvider];


    AWSCognitoIdentityGetCredentialsForIdentityInput *input = [AWSCognitoIdentityGetCredentialsForIdentityInput alloc];

    input.identityId = credentialsProvider.identityId;


    input.logins = credentialsProvider.logins;



    [[identity getCredentialsForIdentity:input] continueWithBlock:^id (AWSTask<AWSCognitoIdentityGetCredentialsForIdentityResponse *> * task) {
        NSLog(@"****AWS Identity Credentials ", task.result.credentials);
        resolve(task.result.credentials);
        return nil;
    }];
    */


        /*


        AWSCognitoIdentityGetOpenIdTokenInput *getTokenInput = [AWSCognitoIdentityGetOpenIdTokenInput alloc];
    getTokenInput.identityId = credentialsProvider.identityId;
    getTokenInput.logins = credentialsProvider.logins;






    */
}


RCT_EXPORT_METHOD(syncData: (NSString *)datasetName
                  : (NSString *)key
                  : (NSString *)value
                  : (RCTResponseSenderBlock)callback) {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:datasetName];

    [dataset setString:value forKey:key];
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            callback(@[ @{@"code":[NSNumber numberWithLong:task.error.code], @"domain":task.error.domain, @"userInfo":task.error.userInfo, @"localizedDescription":task.error.localizedDescription} ]);
        } else {
            callback(@[ [NSNull null] ]);
        }
        return nil;
    }];
}

RCT_EXPORT_METHOD(subscribe: (NSString *)datasetName
                  : (RCTResponseSenderBlock)callback) {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:datasetName];

    [[dataset subscribe] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Unable to subscribe to dataset");
            callback(@[ [task.error localizedDescription] ]);
        } else {
            NSLog(@"Subscribed to dataset");
            callback(@[ [NSNull null] ]);
        }
        return nil;
    }];
}

@end
