//
//  ViewController.m
//  imagepartition
//
//  Created by Jonathan King on 20/02/2016.
//  Copyright © 2016 Jonathan King. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <PPScanDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *partitionImageView;
@property (weak, nonatomic) IBOutlet SelectImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) UIImage *image;

@property (nonatomic, strong) NSString *rawOcrParserId;
@property (nonatomic, strong) NSString *priceParserId;

@property (nonatomic, strong) PPCoordinator *coordinator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set the delegate for the SelectImageView
    _imageView.delegate = self;
    
    // initialise the image
    _image = [UIImage imageNamed:@"sainsbury.jpg"];
    
    NSLog(@"%@", _image);
    _imageView.image = _image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Partition the image
    CGRect cropRect = CGRectMake(900, 800, 400, 100);
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], cropRect);
    UIImage *partitionImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    _partitionImageView.image = partitionImage;
    _partitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // OCR initialisation
    self.rawOcrParserId = @"Raw ocr"; // use anything you like
    self.priceParserId = @"Price";
    
    /** Instantiate the scanning coordinator */
    NSError *error;
    self.coordinator = [self coordinatorWithError:&error];
    
    /** If scanning isn't supported, present an error */
    if (self.coordinator == nil) {
        NSString *messageString = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Warning"
                                    message:messageString
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma SelectImageViewDelegate
- (void)selectionWasMade:(CGRect)selection {
    // Selection was made in the image, so update the partition image to display the selection
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], selection);
    UIImage *partitionImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    _partitionImageView.image = partitionImage;
    
    [self.coordinator processImage:partitionImage
                    scanningRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)
                          delegate:self];
}

#pragma PPScanDelegate

/**
 * Method allocates and initializes the Scanning coordinator object.
 * Coordinator is initialized with settings for scanning
 *
 *  @param error Error object, if scanning isn't supported
 *
 *  @return initialized coordinator
 */
- (PPCoordinator *)coordinatorWithError:(NSError**)error {
    
    /** 0. Check if scanning is supported */
    
    if ([PPCoordinator isScanningUnsupported:error]) {
        return nil;
    }
    
    /** 1. Initialize the Scanning settings */
    
    // Initialize the scanner settings object. This initialize settings with all default values.
    PPSettings *settings = [[PPSettings alloc] init];

    
    /** 2. Setup the license key */
    
    /** Set the license key */
    settings.licenseSettings.licenseKey = @"62KNMAZV-FD4GRA4K-UCTGTZKV-QXIOKVMF-2DSVLBOQ-4VKYLUHF-KWC5BZKV-RUAJHDL5";
    
    /**
     * 3. Set up what is being scanned. See detailed guides for specific use cases.
     * Here's an example for initializing raw OCR scanning.
     */
    
    // To specify we want to perform OCR recognition, initialize the OCR recognizer settings
    PPOcrRecognizerSettings *ocrRecognizerSettings = [[PPOcrRecognizerSettings alloc] init];
    
    // We want raw OCR parsing
    [ocrRecognizerSettings addOcrParser:[[PPRawOcrParserFactory alloc] init] name:self.rawOcrParserId];
    
    // We want to parse prices from raw OCR result as well
    [ocrRecognizerSettings addOcrParser:[[PPPriceOcrParserFactory alloc] init] name:self.priceParserId];
    
    // Add the recognizer setting to a list of used recognizer
    [settings.scanSettings addRecognizerSettings:ocrRecognizerSettings];
    
    
    /** 4. Initialize the Scanning Coordinator object */
    
    _coordinator = [[PPCoordinator alloc] initWithSettings:settings];
    
    return _coordinator;
}

- (void)scanningViewController:(UIViewController<PPScanningViewController> *)scanningViewController
              didOutputResults:(NSArray *)results {
    
    // Here you process scanning results. Scanning results are given in the array of PPRecognizerResult objects.
    
    // first, pause scanning until we process all the results
    [scanningViewController pauseScanning];
    
    // Collect data from the result
    for (PPRecognizerResult* result in results) {
        
        if ([result isKindOfClass:[PPOcrRecognizerResult class]]) {
            PPOcrRecognizerResult* ocrRecognizerResult = (PPOcrRecognizerResult*)result;
            
            NSLog(@"OCR results are:");
            NSLog(@"Raw ocr: %@", [ocrRecognizerResult parsedResultForName:self.rawOcrParserId]);
            NSLog(@"Price: %@", [ocrRecognizerResult parsedResultForName:self.priceParserId]);
            
            NSString *price = [ocrRecognizerResult parsedResultForName:self.priceParserId];
            NSString *reformattedPrice = [NSString stringWithFormat:@"£%@",[price stringByReplacingOccurrencesOfString:@"," withString:@"."]];
            _priceLabel.text = (price.length == 0) ? @"Unable to determine price." : reformattedPrice;
            
            PPOcrLayout* ocrLayout = [ocrRecognizerResult ocrLayout];
//            NSLog(@"Dimensions of ocrLayout are %@", NSStringFromCGRect([ocrLayout box]));
        }
    };
    
    // resume scanning while preserving internal recognizer state
    [scanningViewController resumeScanningAndResetState:NO];
}


@end
