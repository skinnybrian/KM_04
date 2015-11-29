//
//  ViewController.h
//  sample
//
//  Created by NTT IT on 2015.
//  Copyright(C) 2015 NTT IT CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRClientHelper.h"
#import "SRClientDataClasses.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *buttonMic;
@property (weak, nonatomic) IBOutlet UILabel *tsukkomiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *caraImage;

@property (strong, nonatomic) SRClientHelper* srcHelper;
@property (strong, nonatomic)NSMutableDictionary* settings;
@property (assign, nonatomic)int mode;
//@property (assign, nonatomic)
@end

typedef enum{
    SPEECHREC_SETTING_TYPE_BOOL,
    SPEECHREC_SETTING_TYPE_INTEGER,
    SPEECHREC_SETTING_TYPE_REAL,
    SPEECHREC_SETTING_TYPE_STRING
}SPEECHREC_SETTING_TYPE;

typedef enum{
    SPEECHREC_BUTTON_MODE_NONE = -99,
    SPEECHREC_BUTTON_MODE_READY = -1,
    SPEECHREC_BUTTON_MODE_LEVEL_0,
    SPEECHREC_BUTTON_MODE_LEVEL_1,
    SPEECHREC_BUTTON_MODE_LEVEL_2,
    SPEECHREC_BUTTON_MODE_LEVEL_3,
    SPEECHREC_BUTTON_MODE_LEVEL_4,
    SPEECHREC_BUTTON_MODE_LEVEL_5,
    SPEECHREC_BUTTON_MODE_LEVEL_6,
    SPEECHREC_BUTTON_MODE_LEVEL_7,
    SPEECHREC_BUTTON_MODE_LEVEL_8,
    SPEECHREC_BUTTON_MODE_LEVEL_9,
    SPEECHREC_BUTTON_MODE_LEVEL_10,
    SPEECHREC_BUTTON_MODE_LEVEL_11,
    SPEECHREC_BUTTON_MODE_LEVEL_12,
    SPEECHREC_BUTTON_MODE_LEVEL_13,
    SPEECHREC_BUTTON_MODE_LEVEL_14,
    SPEECHREC_BUTTON_MODE_LEVEL_15,
    SPEECHREC_BUTTON_MODE_RECOGNIZE
}SPEECHREC_BUTTON_MODE;

typedef enum{
    SPEECHREC_RECOG_MODE_NONE,
    SPEECHREC_RECOG_MODE_PUSH,
    SPEECHREC_RECOG_MODE_RECOG
}SPEECHREC_RECOG_MODE;
