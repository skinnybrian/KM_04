//
//  ViewController.m
//  sample
//
//  Created by NTT IT on 2015.
//  Copyright(C) 2015 NTT IT CORPORATION. All rights reserved.
//

#import "ViewController.h"
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>

@interface ViewController ()
<SRClientHelperDelegate>
@end

@implementation ViewController
{
    SPEECHREC_BUTTON_MODE _latestLevel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[_buttonMic imageView] setClipsToBounds:NO];
    [[_buttonMic imageView] setContentMode:UIViewContentModeCenter];
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_NONE];
//    _mode = SPEECHREC_RECOG_MODE_NONE;
//    _latestLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
}

- (IBAction)onButtonMic:(id)sender {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if(_mode==SPEECHREC_RECOG_MODE_NONE){
    [self start];
            [self hoge];
//        }else{
//            [self stop];
//        }
//    });
}


-(void)hoge{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
//            _mode = SPEECHREC_RECOG_MODE_NONE;
//            _latestLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
           if(_mode==SPEECHREC_RECOG_MODE_NONE){
               [self start];
           }
           [self hoge];
           
        });
    });
}

#pragma mark Delegate method from SRClientHelper

- (void)srcDidRecognize:(NSData*)data
{
    id decodedObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableString* serializedString = nil;
    if([decodedObj isMemberOfClass:[SRNbest class]]){
        SRNbest* nbestObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if([self isResultXml]){
            if([NSMutableString stringWithString:[nbestObj serialize]]){
                serializedString = [NSMutableString stringWithString:[nbestObj serialize]];
            }else{
                serializedString = [NSMutableString stringWithString:@"(結果なし)"];
            }
        }else{
            serializedString = [[NSMutableString alloc]init];
            if(![nbestObj sentenceArray]||[[nbestObj sentenceArray]count]<1){
                [serializedString appendString:@"(結果なし)"];
                
            }else{
                for(NSString* sentenceString in [nbestObj getNbestStringArray:YES]){
                    if([serializedString length]>0){
                        [serializedString appendString:@"\r"];
                    }
                    [serializedString appendString:sentenceString];
                }
            }
        }
    }
    NSLog(@"%@",serializedString);
    //[self showAlert:serializedString title:@"認識結果"];
}

- (void)srcDidReady
{
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_READY];
}

- (void)srcDidSentenceEnd
{
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_RECOGNIZE];
}

- (void)srcDidComplete:(NSError*)error
{
    if(error){
        NSString* description = [error localizedDescription];
        NSString* reason = [error localizedFailureReason];
        //[self showAlert:reason title:description];
    }
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_NONE];
    if(_srcHelper){
        [_srcHelper setDelegate:nil];
        _srcHelper = nil;
    }
}

- (void)srcDidRecord:(NSData*)pcmData
{
    double level = [self decibelFromData:pcmData];
    [self performSelectorOnMainThread:@selector(updatePressureLevel:) withObject:[NSNumber numberWithDouble:level] waitUntilDone:NO];
}

#pragma mark Private method

- (void)start {
    if(_settings){
        _settings = nil;
    }
    _settings = [NSMutableDictionary dictionary];
    // get setting from settings.bundle
    [self loadSetting:@"api_key" type:SPEECHREC_SETTING_TYPE_STRING];
    [self loadSetting:@"sbm_mode" type:SPEECHREC_SETTING_TYPE_INTEGER];
    [self loadSetting:@"result_xml" type:SPEECHREC_SETTING_TYPE_BOOL];
    if(!_srcHelper){
        _srcHelper = [[SRClientHelper alloc] initWithDevice:_settings];
        if(!_srcHelper){
            [self showAlert:@"初期化失敗" title:@"エラー"];
            [self swapButtonImage:SPEECHREC_BUTTON_MODE_NONE];
            return;
        }else{
            _srcHelper.delegate = (id)self;
        }
    }
    [_srcHelper start];
}

- (void)stop
{
    if(_srcHelper){
        [_srcHelper stop];
    }
}

- (void)loadSetting:(NSString*)key type:(SPEECHREC_SETTING_TYPE)settingType
{
    @try {
        id preferenceValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        id defaultValue = [self getUserDefault:key];
        NSString* prefString;
        switch(settingType){
            case SPEECHREC_SETTING_TYPE_BOOL:
                if(preferenceValue){
                    prefString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
                    if(prefString&&[prefString length]>0){
                        [_settings setObject:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:key]]
                                         forKey:key];
                        break;
                    }
                }
                if(defaultValue){
                    [_settings setObject:[NSNumber numberWithBool:[defaultValue boolValue]]
                                     forKey:key];
                }
                break;
            case SPEECHREC_SETTING_TYPE_INTEGER:
                if(preferenceValue){
                    prefString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
                    if(prefString&&[prefString length]>0){
                        [_settings setObject:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:key]]
                                         forKey:key];
                        break;
                    }
                }
                if(defaultValue){
                    [_settings setObject:[NSNumber numberWithInteger:[defaultValue integerValue]]
                                     forKey:key];
                }
                break;
            case SPEECHREC_SETTING_TYPE_REAL:
                if(preferenceValue){
                    prefString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
                    if(prefString&&[prefString length]>0){
                        [_settings setObject:[NSNumber numberWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:key]]
                                         forKey:key];
                        break;
                    }
                }
                if(defaultValue){
                    [_settings setObject:[NSNumber numberWithDouble:[defaultValue doubleValue]]
                                     forKey:key];
                }
                break;
            case SPEECHREC_SETTING_TYPE_STRING:
            {
                if(preferenceValue){
                    [_settings setObject:[[NSUserDefaults standardUserDefaults] stringForKey:key]
                                     forKey:key];
                }else{
                    if(defaultValue&&[defaultValue length]>0){
                        [_settings setObject:defaultValue
                                         forKey:key];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    @catch(...) {
    }
}

- (id)getUserDefault:(NSString*)key
{
    id defaultValueId = nil;
    NSString* rootPlistFile = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"];
    NSDictionary* settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:rootPlistFile];
    NSArray* preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary* item in preferencesArray){
        NSString* keyValue = [item objectForKey:@"Key"];
        id defaultValue = [item objectForKey:@"DefaultValue"];
        if(keyValue&&defaultValue) {
            if ([keyValue compare:key] == NSOrderedSame) {
                defaultValueId = defaultValue;
            }
        }
    }
    return defaultValueId;
}

- (BOOL)isResultXml
{
    BOOL ret = NO;
    if([_settings objectForKey:@"result_xml"]&&[[_settings objectForKey:@"result_xml"] boolValue]){
        ret = YES;
    }
    return ret;
}

- (double)decibelFromData:(NSData*)data
{
    double decibel = 0;
    if(data&&[data length]>0){
        short* noiseReductData = (short*)malloc([data length]);
        [data getBytes:noiseReductData length:[data length]];
        for(int i=0; i<[data length]/sizeof(short); i++){
            short sample = noiseReductData[i];
            if(sample==0){
                sample = 1;
            }
            double db = log10(pow(sample, 2) / pow(SHRT_MAX, 2)) * 10;
            decibel += db;
        }
        decibel /= ([data length]/sizeof(short));
        free(noiseReductData);
        noiseReductData = NULL;
    }
    return decibel;
}

- (void)updatePressureLevel:(NSNumber*)levelObj{
    double level = [levelObj doubleValue];
    SPEECHREC_BUTTON_MODE newLevel = _latestLevel;
    if(-10<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_15;
    }else if(-15<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_14;
    }else if(-20<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_13;
    }else if(-25<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_12;
    }else if(-30<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_11;
    }else if(-35<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_10;
    }else if(-40<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_9;
    }else if(-45<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_8;
    }else if(-50<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_7;
    }else if(-55<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_6;
    }else if(-60<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_5;
    }else if(-65<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_4;
    }else if(-70<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_3;
    }else if(-75<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_2;
    }else if(-80<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_1;
    }else if(-90<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
    }
    if(abs(_latestLevel-newLevel)>2){
        if(_latestLevel>newLevel){
            newLevel -= _latestLevel;
        }else{
            newLevel += _latestLevel;
        }
        if(newLevel>SPEECHREC_BUTTON_MODE_LEVEL_15){
            newLevel = SPEECHREC_BUTTON_MODE_LEVEL_15;
        }
        if(newLevel<SPEECHREC_BUTTON_MODE_LEVEL_0){
            newLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
        }
        _latestLevel = newLevel;
    }
    [self swapButtonImage:newLevel];
}

- (void)swapButtonImage:(SPEECHREC_BUTTON_MODE)mode{
    UIImage* buttonImage = nil;
    float alpha = 1.0;
    float zoom = 1.0;
    switch(mode){
        case SPEECHREC_BUTTON_MODE_NONE:
            _mode = SPEECHREC_RECOG_MODE_NONE;
            buttonImage = [UIImage imageNamed:@"none"];
            alpha = 0.8;
            zoom = 0.7;
            break;
        case SPEECHREC_BUTTON_MODE_READY:
            _mode = SPEECHREC_RECOG_MODE_PUSH;
            buttonImage = [UIImage imageNamed:@"none"];
            alpha = 1.0;
            zoom = 0.9;
            break;
        case SPEECHREC_BUTTON_MODE_LEVEL_0:
        case SPEECHREC_BUTTON_MODE_LEVEL_1:
        case SPEECHREC_BUTTON_MODE_LEVEL_2:
        case SPEECHREC_BUTTON_MODE_LEVEL_3:
        case SPEECHREC_BUTTON_MODE_LEVEL_4:
        case SPEECHREC_BUTTON_MODE_LEVEL_5:
        case SPEECHREC_BUTTON_MODE_LEVEL_6:
        case SPEECHREC_BUTTON_MODE_LEVEL_7:
        case SPEECHREC_BUTTON_MODE_LEVEL_8:
        case SPEECHREC_BUTTON_MODE_LEVEL_9:
        case SPEECHREC_BUTTON_MODE_LEVEL_10:
        case SPEECHREC_BUTTON_MODE_LEVEL_11:
        case SPEECHREC_BUTTON_MODE_LEVEL_12:
        case SPEECHREC_BUTTON_MODE_LEVEL_13:
        case SPEECHREC_BUTTON_MODE_LEVEL_14:
        case SPEECHREC_BUTTON_MODE_LEVEL_15:
            if(_mode!=SPEECHREC_RECOG_MODE_RECOG){
                _mode = SPEECHREC_RECOG_MODE_PUSH;
                buttonImage = [UIImage imageNamed:[NSString stringWithFormat:@"speak_now_%d.png", mode]];
                alpha = 1.0;
                zoom = 0.9;
            }
            break;
        case SPEECHREC_BUTTON_MODE_RECOGNIZE:
            _mode = SPEECHREC_RECOG_MODE_RECOG;
            buttonImage = [UIImage imageNamed:@"recognizing"];
            alpha = 1.0;
            zoom = 1.0;
            break;
        default:
            break;
    }
    if(buttonImage){
        [UIView beginAnimations:@"micAnim" context:NULL];
        [UIView setAnimationDuration:0.05f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:FALSE];
        [_buttonMic setAlpha:alpha];
        [_buttonMic setImage:buttonImage forState:UIControlStateNormal];
        [[_buttonMic imageView] setTransform:CGAffineTransformMakeScale(zoom, zoom)];
        [UIView commitAnimations];
    }
}

- (void) showAlert:(NSString*)message title:(NSString*)title
{
    if ([UIAlertController class]) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//            [alertController dismissViewControllerAnimated:YES completion:nil];
//        });
    }else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//                                                            message:message
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
        //[alertView show];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//            [alertView dismissWithClickedButtonIndex:0 animated:YES];
//        });
    }
    NSLog(@"%@ - %@",title,message);
}

- (void)socketSample{
    SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:@"localhost:8080" options:@{@"log": @YES, @"forcePolling": @YES}];
    
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
    }];
    
    [socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];
        
        [socket emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data) {
            [socket emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
        });
        
        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];
    
    [socket connect];
}
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}



@end
