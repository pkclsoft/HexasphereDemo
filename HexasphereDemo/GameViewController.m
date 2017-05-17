//
//  GameViewController.m
//  HexasphereDemo
//
//  Created by Peter Easdown on 17/5/17.
//

#import "GameViewController.h"
#import "Hexasphere.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a new scene
    SCNScene *scene = [SCNScene scene];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);

    static const float GLOBE_RADIUS = 2.0;

    Hexasphere *earth = [Hexasphere hexasphereWithRadius:GLOBE_RADIUS numDivisions:20 andHexSize:0.9];
    earth.name = @"earth";
    earth.position = SCNVector3Make(0.0, 0.0, 0.0);
    earth.scale = SCNVector3Make(GLOBE_RADIUS, GLOBE_RADIUS, GLOBE_RADIUS);

    [scene.rootNode addChildNode:earth];

    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    scnView.autoenablesDefaultLighting = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];

    // This does two things:
    // 1. It demonstrates how to change the color of a single tile, and
    // 2. It forces the node to update it's material at startup.  For some reason I haven't
    //    found, the initial value of the material doesn't take effect until this is done.
    //
    [earth updateTile:500 withColor:[UIColor redColor]];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
