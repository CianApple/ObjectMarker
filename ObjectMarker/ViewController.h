//
//  ViewController.h
//  ObjectMarker
//
//  Created by Jai Dhorajia on 01/02/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawRectView.h"
#import "BlockAlertView.h"

@interface ViewController : UIViewController <drawRectDelegate,UIDocumentInteractionControllerDelegate>
{
    int current_pos;
    BOOL loadOnce;
    
    UIButton *btn_next;
    UIButton *btn_imgCurrent;
    UIButton *btn_preview;
    UIButton *btn_imgName;
    
    UIImage *originalImage;
}
@property (retain, nonatomic) IBOutlet UIImageView *target_imgvw;
@property (retain, nonatomic) IBOutlet DrawRectView *DrawingView;
@property (retain, nonatomic) NSMutableArray *ary_imagelist;
@property (retain, nonatomic) NSMutableArray *ary_finalRectlist;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@end
