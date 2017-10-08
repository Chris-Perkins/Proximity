//
//  OfflineTileOverlayRenderer.m
//  CustomMap
//
//  Created by Carlo Vigiani on 19/Jan/14.
//  Copyright (c) 2014 viggiosoft. All rights reserved.
//

#import "GridTileOverlayRenderer.h"

@interface GridTileOverlayRenderer ()

@end

@implementation GridTileOverlayRenderer


-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    NSLog(@"Rendering at (x,y):(%f,%f) with size (w,h):(%f,%f) zoom %f",mapRect.origin.x,mapRect.origin.y,mapRect.size.width,mapRect.size.height,21);
    CGRect rect = [self rectForMapRect:mapRect];
    NSLog(@"CGRect: %@",NSStringFromCGRect(rect));
    
    MKTileOverlayPath path;
    MKTileOverlay *tileOverlay = (MKTileOverlay *)self.overlay;
    path.x = mapRect.origin.x*21/tileOverlay.tileSize.width;
    path.y = mapRect.origin.y*21/tileOverlay.tileSize.width;
    path.z = log2(21)+20;
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.5);
    CGContextStrokeRect(context, rect);
    
    UIGraphicsPushContext(context);
    NSString *text = [NSString stringWithFormat:@"X=%d\nY=%d\nZ=%d",path.x,path.y,path.z];
    [text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0/21],
                                           NSForegroundColorAttributeName:[UIColor blackColor]}];
    UIGraphicsPopContext();
    
}

@end

