//
//  ViewController.m
//  ObjectMarker
//
//  Created by Jai Dhorajia on 01/02/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

#import "ViewController.h"

#define FILE_MANAGER [NSFileManager defaultManager]
#define BASE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] // Change base path here
#define FILE_PATH_NAME @"./positive_images"

#define FOLDER_NAME @"Images"
#define IMAGES_FOLDERPATH [BASE_PATH stringByAppendingPathComponent:FOLDER_NAME]

#define FILE_NAME @"positives.txt"
#define OUTPUT_FILEPATH [BASE_PATH stringByAppendingPathComponent:FILE_NAME]
#define IMAGENAMEKEY @"ImageName"

@interface ViewController ()

@end

@implementation ViewController
@synthesize ary_imagelist;
@synthesize ary_finalRectlist;
@synthesize documentInteractionController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"    ObjectMarker iOS";
    //[self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // If "Images" folder doesnt exist, create it
    if(![FILE_MANAGER fileExistsAtPath:IMAGES_FOLDERPATH])
        [FILE_MANAGER createDirectoryAtPath:IMAGES_FOLDERPATH
                withIntermediateDirectories:NO
                                 attributes:nil
                                      error:nil];
    
    //BOOL isWriteable = [FILE_MANAGER isWritableFileAtPath:BASE_PATH]; //Check file path is writealbe
    // You can now add a file name to your path and the create the initial empty file
    [FILE_MANAGER createFileAtPath:[BASE_PATH stringByAppendingPathComponent:@"positives.txt"] contents:nil attributes:nil];
    
    // Fetch the image list from Images folder from documents directory
    self.ary_imagelist = [[NSMutableArray alloc] initWithArray:[FILE_MANAGER contentsOfDirectoryAtPath:IMAGES_FOLDERPATH
                                                                                                 error:nil]];
    [self.ary_imagelist removeObject:@".DS_Store"];         // Remove unwanted files
    
    self.ary_finalRectlist = [[NSMutableArray alloc] init];
    
    NSMutableArray *temp_ary_imagelist = [[NSMutableArray alloc] init];
    for(int cnt=0; cnt<self.ary_imagelist.count; cnt++)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[self.ary_imagelist objectAtIndex:cnt], IMAGENAMEKEY, nil];
        [temp_ary_imagelist addObject:dict];
        [dict release];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:IMAGENAMEKEY ascending:YES comparator:^(NSString *obj1, NSString *obj2){ return [obj1 compare:obj2 options:NSNumericSearch | NSCaseInsensitiveSearch]; }];
    [temp_ary_imagelist sortUsingDescriptors:@[sd]];
    
    [self.ary_imagelist removeAllObjects];
    for(int cnt=0; cnt<temp_ary_imagelist.count; cnt++)
        [self.ary_imagelist addObject:[[temp_ary_imagelist objectAtIndex:cnt] objectForKey:IMAGENAMEKEY]];
    [temp_ary_imagelist release];
    
    NSLog(@"%@",self.ary_imagelist);
    loadOnce = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (loadOnce)
    {
        if(self.ary_imagelist.count != 0)
        {
            // Set next and previous buttons
            btn_next =  [UIButton buttonWithType:UIButtonTypeCustom];
            [btn_next setFrame:CGRectMake(0, 0, 50, 32)];
            if (self.ary_imagelist.count == 1)
            {
                [btn_next setTitle:@"Done" forState:UIControlStateNormal];
                [btn_next setTitle:@"XXXX" forState:UIControlStateHighlighted];
                [btn_next setBackgroundColor:[UIColor redColor]];
            }
            else
            {
                [btn_next setTitle:@"-->" forState:UIControlStateNormal];
                [btn_next setTitle:@"--XX" forState:UIControlStateHighlighted];
                [btn_next setBackgroundColor:[UIColor blueColor]];
            }
            [btn_next addTarget:self action:@selector(btn_next_pressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *bar_next = [[[UIBarButtonItem alloc] initWithCustomView:btn_next] autorelease];
            
            btn_preview =  [UIButton buttonWithType:UIButtonTypeCustom];
            [btn_preview setFrame:CGRectMake(0, 0, 70, 32)];
            [btn_preview setTitle:@"Preview" forState:UIControlStateNormal];
            [btn_preview setTitle:@"XXXXXXX" forState:UIControlStateHighlighted];
            [btn_preview setBackgroundColor:[UIColor purpleColor]];
            [btn_preview addTarget:self action:@selector(btn_preview_pressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *bar_preview = [[[UIBarButtonItem alloc] initWithCustomView:btn_preview] autorelease];
            
            self.navigationItem.rightBarButtonItems = @[bar_next,bar_preview];
            
            current_pos = 0;
            NSString *getImagePath = [IMAGES_FOLDERPATH stringByAppendingPathComponent:[self.ary_imagelist objectAtIndex:current_pos]];
            originalImage = [UIImage imageWithContentsOfFile:getImagePath];
            CGSize scaledSize = [self scaleProportionToFitScreen:originalImage.size];
            [self.target_imgvw setFrame:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
            self.target_imgvw.image = originalImage;
            NSLog(@"Image Name - %@   Resolution - %@",[self.ary_imagelist objectAtIndex:current_pos],NSStringFromCGSize(originalImage.size));
            
            self.DrawingView.frame = self.target_imgvw.bounds;
            self.DrawingView.delegate = self;
            
            // Set Current Image Counter and Image name in navigation bar
            btn_imgCurrent =  [UIButton buttonWithType:UIButtonTypeCustom];
            [btn_imgCurrent setFrame:CGRectMake(0, 0, 70, 32)];
            [btn_imgCurrent setTitle:[NSString stringWithFormat:@"%d",current_pos] forState:UIControlStateNormal];
            [btn_imgCurrent setBackgroundColor:[UIColor brownColor]];
            UIBarButtonItem *bar_imgCurrent = [[[UIBarButtonItem alloc] initWithCustomView:btn_imgCurrent] autorelease];
            
            btn_imgName =  [UIButton buttonWithType:UIButtonTypeCustom];
            [btn_imgName setFrame:CGRectMake(0, 0, 200, 32)];
            [btn_imgName setTitle:[NSString stringWithFormat:@"%@",[self.ary_imagelist objectAtIndex:current_pos]]
                         forState:UIControlStateNormal];
            [btn_imgName setBackgroundColor:[UIColor orangeColor]];
            UIBarButtonItem *bar_imgName = [[[UIBarButtonItem alloc] initWithCustomView:btn_imgName] autorelease];
            self.navigationItem.leftBarButtonItems = @[bar_imgCurrent,bar_imgName];
            
            loadOnce = NO;
        }
    }
}

- (void)btn_preview_pressed:(id)sender
{
    NSURL *URL = [NSURL fileURLWithPath:[BASE_PATH stringByAppendingPathComponent:@"positives.txt"]];
    if (URL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        // Preview PDF
        [self.documentInteractionController presentPreviewAnimated:YES];
    }
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (void)btn_next_pressed:(id)sender
{
    if(([btn_next.titleLabel.text isEqualToString:@"Done"] || [btn_next.titleLabel.text isEqualToString:@"XXXX"]) && [self.ary_finalRectlist count]>0)
    {
        NSMutableString *strToWrite = [NSMutableString stringWithFormat:@"%@/%@ %d",FILE_PATH_NAME,[self.ary_imagelist objectAtIndex:current_pos],[self.ary_finalRectlist count]];
        for (int cnt=0; cnt<[self.ary_finalRectlist count]; cnt++) {
            CGRect rect = CGRectFromString([self.ary_finalRectlist objectAtIndex:cnt]);
            float x = rect.origin.x;
            float y = rect.origin.y;
            float width = rect.size.width;
            float height = rect.size.height;
            NSMutableString *strRect = [NSMutableString stringWithFormat:@" %d %d %d %d",(int)x,(int)y,(int)width,(int)height];
            [strToWrite appendString:strRect];
            NSLog(@"%@",strToWrite);
        }
        
        // Add new
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:[BASE_PATH stringByAppendingPathComponent:@"positives.txt"]];
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[strToWrite dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
        
        [self.ary_finalRectlist removeAllObjects];
        
        btn_next.enabled = NO;
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Message"
                                                       message:@"Finished marking all the images. Text file is generated in documents directory."];
        [alert show];
    }
    else
    {
        if ([self.ary_finalRectlist count]>0)
        {
            NSMutableString *strToWrite = [NSMutableString stringWithFormat:@"%@/%@ %d",FILE_PATH_NAME,[self.ary_imagelist objectAtIndex:current_pos],[self.ary_finalRectlist count]];
            for (int cnt=0; cnt<[self.ary_finalRectlist count]; cnt++) {
                CGRect rect = CGRectFromString([self.ary_finalRectlist objectAtIndex:cnt]);
                float x = rect.origin.x;
                float y = rect.origin.y;
                float width = rect.size.width;
                float height = rect.size.height;
                NSMutableString *strRect = [NSMutableString stringWithFormat:@" %d %d %d %d",(int)x,(int)y,(int)width,(int)height];
                [strToWrite appendString:strRect];
                NSLog(@"%@",strToWrite);
            }
            
            // Add new
            NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:[BASE_PATH stringByAppendingPathComponent:@"positives.txt"]];
            [fileHandler seekToEndOfFile];
            [fileHandler writeData:[strToWrite dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandler writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandler closeFile];
            
            [self.ary_finalRectlist removeAllObjects];
            
            if(current_pos+1 >= 0 && current_pos+1 <= ([self.ary_imagelist count]-1))
            {
                current_pos++;
                NSString *getImagePath = [IMAGES_FOLDERPATH stringByAppendingPathComponent:[self.ary_imagelist objectAtIndex:current_pos]];
                originalImage = [UIImage imageWithContentsOfFile:getImagePath];
                CGSize scaledSize = [self scaleProportionToFitScreen:originalImage.size];
                [self.target_imgvw setFrame:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
                self.target_imgvw.image = originalImage;
                NSLog(@"Image Name - %@   Resolution - %@",[self.ary_imagelist objectAtIndex:current_pos],NSStringFromCGSize(originalImage.size));
                
                self.DrawingView.startPt=CGPointZero;
                self.DrawingView.currPt=CGPointZero;
                [self.DrawingView setNeedsDisplay];
                self.DrawingView.frame = self.target_imgvw.bounds;
            }
            
            if(current_pos >= ([self.ary_imagelist count]-1))
            {
                current_pos = ([self.ary_imagelist count]-1);
                
                [btn_next setTitle:@"Done" forState:UIControlStateNormal];
                [btn_next setTitle:@"XXXX" forState:UIControlStateHighlighted];
                [btn_next setBackgroundColor:[UIColor redColor]];
            }
            
            [btn_imgCurrent setTitle:[NSString stringWithFormat:@"%d",current_pos] forState:UIControlStateNormal];
            [btn_imgName setTitle:[NSString stringWithFormat:@"%@",[self.ary_imagelist objectAtIndex:current_pos]]
                         forState:UIControlStateNormal];
            //NSLog(@"Current Image Position - %d",current_pos);
        }
        else
        {
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Error"
                                                           message:@"Atleast mark one object bro!!!"];
            [alert setCancelButtonWithTitle:@"Cancel" block:^{
                // do nothing
            }];
            [alert show];
        }
    }
}

- (CGSize)scaleProportionToFitScreen:(CGSize)sizeOriginalImage
{
    float oriWidth = sizeOriginalImage.width;
    float oriHeight = sizeOriginalImage.height;
    float scrWidth = self.view.frame.size.width;
    float scrHeight = self.view.frame.size.height;
    float scaledWidth = 0.0f;
    float scaledHeight = 0.0f;
    
    if(sizeOriginalImage.width >= sizeOriginalImage.height)
    {
        scaledWidth = scrWidth;
        scaledHeight = (scrWidth*oriHeight)/oriWidth;
        sizeOriginalImage = CGSizeMake(scaledWidth, scaledHeight);
    }
    else
    {
        scaledHeight = scrHeight;
        scaledWidth = (scrHeight*oriWidth)/oriHeight;
        sizeOriginalImage = CGSizeMake(scaledWidth, scaledHeight);
    }
    return sizeOriginalImage;
}

// drawRectDelegate
- (void)rectDrawn:(CGRect)rect
{
    NSLog(@"Final rect - %@",NSStringFromCGRect(rect));
    
    CGSize scaledSize = [self scaleProportionToFitScreen:originalImage.size];
    CGSize originalSize = originalImage.size;
    CGRect originalRect;
    originalRect.origin.x = (rect.origin.x*originalSize.width)/scaledSize.width;
    originalRect.origin.y = (rect.origin.y*originalSize.height)/scaledSize.height;
    originalRect.size.width = (rect.size.width*originalSize.width)/scaledSize.width;
    originalRect.size.height = (rect.size.height*originalSize.height)/scaledSize.height;
    
    NSLog(@"Original rect - %@",NSStringFromCGRect(originalRect));
    
    // To test the rect frame with respect to original image size
    // Comment it if dont want to test
    UIGraphicsBeginImageContext(originalImage.size);
    [originalImage drawAtPoint:CGPointZero];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blueColor] setStroke];
    CGContextStrokeRect(ctx, originalRect);
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *pngData = UIImagePNGRepresentation(retImage);
    [pngData writeToFile:[BASE_PATH stringByAppendingPathComponent:@"testRectOriginalImage.png"] atomically:YES];
    
    [self.ary_finalRectlist addObject:NSStringFromCGRect(originalRect)];
}

- (void)dealloc {
    [_target_imgvw release];
    [self.ary_imagelist release];
    [self.ary_finalRectlist release];
    [_DrawingView release];
    [super dealloc];
}
@end