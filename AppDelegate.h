

@interface AppDelegate : NSObject<UIApplicationDelegate>
{
    UIWindow *window;
	UIViewController *viewController;
    
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;

@end