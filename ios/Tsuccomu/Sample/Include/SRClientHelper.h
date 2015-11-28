//
//  SRClientHelper.h
//  SRClientHelper
//
//  Created by NTT IT on 2015.
//  Copyright(C) 2015 NTT IT CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRClientHelperDelegate <NSObject>
@optional
- (void)srcDidReady;
- (void)srcDidRecognize:(NSData*)data;
- (void)srcDidSentenceEnd;
- (void)srcDidComplete:(NSError*)error;
- (void)srcDidRecord:(NSData*)pcmData;
@end

@interface SRClientHelper : NSObject
@property (nonatomic, weak) id<SRClientHelperDelegate> delegate;
- (id)initWithDevice:(NSDictionary*)settings;
- (instancetype)init __attribute__((unavailable("init is not available")));
- (void)start;
- (void)stop;
- (void)cancel;
@end
