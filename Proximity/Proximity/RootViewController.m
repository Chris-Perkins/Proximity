//
//  RootViewController.m
//  CustomMap
//
//  Created by Carlo Vigiani on 19/Jan/14.
//  Copyright (c) 2014 viggiosoft. All rights reserved.
//

#import "RootViewController.h"
#import "GridTileOverlay.h"
#import "WatermarkTileOverlayRenderer.h"
#if ( OFFLINE_USE_CUSTOM_OVERLAY_RENDERER == 1)
#import "GridTileOverlayRenderer.h"
#endif

@import MapKit;

@interface RootViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKTileOverlay *tileOverlay;
@property (strong, nonatomic) MKTileOverlay *gridOverlay;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.zoomEnabled = false;
    self.mapView.scrollEnabled = false;
    self.mapView.userInteractionEnabled = false;
    
    // load grid tile overlay
    self.gridOverlay = [[GridTileOverlay alloc] init];
    self.gridOverlay.canReplaceMapContent=NO;
    [self.mapView addOverlay:self.gridOverlay level:MKOverlayLevelAboveLabels];
    
    // Do any additional setup after loading the view from its nib.
    [self reloadTileOverlay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TileOverlay

-(void)reloadTileOverlay {
    
    // remove existing map tile overlay
    if(self.tileOverlay) {
        [self.mapView removeOverlay:self.tileOverlay];
    }
    
    // use online overlay
    /*NSString *urlTemplate = @"https://mt0.google.com/vt/x={x}&y={y}&z={z}";
    self.tileOverlay = [[MKTileOverlay alloc] initWithURLTemplate:urlTemplate];
    self.tileOverlay.canReplaceMapContent=YES;
    [self.mapView insertOverlay:self.tileOverlay belowOverlay:self.gridOverlay];*/
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if([overlay isKindOfClass:[MKTileOverlay class]]) {
        MKTileOverlay *tileOverlay = (MKTileOverlay *)overlay;
        MKTileOverlayRenderer *renderer = nil;
        if([tileOverlay isKindOfClass:[GridTileOverlay class]]) {
#if ( OFFLINE_USE_CUSTOM_OVERLAY_RENDERER == 1 )
            renderer = [[GridTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
#else
            renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
#endif
        } else {
            //if(self.overlayType==CustomMapTileOverlayTypeGoogle) {
            renderer = [[WatermarkTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
            /*} else {
                renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
            }*/
        }
        
        return renderer;
    }
    
    return nil;
}

@end

