//
//  ViewController.m
//  ASImageScoring
//
//  Created by ASPL on 8/23/16.
//  Copyright © 2016 ASPL. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@import ImageIO;

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImage *placeholdeImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgvwScannedImage;
@property (weak, nonatomic) IBOutlet UIButton *btnProcess;
@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePicture;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

@property (weak, nonatomic) IBOutlet UIButton *btnChoosePhoto;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Load the picture for face detection
     placeholdeImage = [UIImage imageNamed:@"placeholder.png"];
    _imgvwScannedImage.image = placeholdeImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)markFaces:(UIImageView *)facePicture
{
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];

    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    
    if([[_imgvwScannedImage image] isEqual:placeholdeImage]){
        _lblError.text=@"Please take picture first.";
        
    }else if([features count]==0){
        
        _lblError.text=@"No Face Detected !!!";
        
    }else if([features count] == 1){
        
        CIFaceFeature* faceFeature = [features objectAtIndex:0];
        
        //provided are BOOL's for the eye's and
        // mouth so we can check if they already exist.

            if(faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition && !faceFeature.leftEyeClosed && !faceFeature.rightEyeClosed)
            {
                _lblError.text=@"Face Detected !!!";

            }else{
                _lblError.text=@"Not a proper image.";
            }
        
    }else{
        
        _lblError.text=[NSString stringWithFormat:@"%ld faces detected",[features count]];
    }
    
    // flip image on y-axis to match coordinate system used by core image
    [_vwContainer setTransform:CGAffineTransformMakeScale(1, -1)];
    
    // flip the entire window to make everything right side up
    [self.imgvwScannedImage setTransform:CGAffineTransformMakeScale(1, -1)];
}

#pragma mark - Button Actions

- (IBAction)processImage:(id)sender {
    
    // Execute the method used to markFaces in background
    [self markFaces:_imgvwScannedImage];
}

- (IBAction)takePicture:(id)sender {
    
    _lblError.text  = @"";
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)choosePicture:(id)sender {
    
    _lblError.text  = @"";
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}



#pragma mark - Image Picker Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imgvwScannedImage.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
