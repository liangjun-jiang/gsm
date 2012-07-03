

#import "AccelerometerFilter.h"

// Implementation of the basic filter. All it does is mirror input to output.

@implementation AccelerometerFilter

@synthesize x, y, z, adaptive;
@synthesize fx, fy, fz;

-(void)addAcceleration:(UIAcceleration*)accel
{
	x = accel.x;
	y = accel.y;
	z = accel.z;
}

- (void)addAttitude:(CMAttitude *)attitude 
{
    fx = attitude.roll;
    fy = attitude.pitch;
    fz = attitude.yaw;
    
}

- (void)addRotation:(CMRotationRate )rotation
{
    fx = rotation.x;
    fy = rotation.y;
    fz = rotation.z;
    
}

-(NSString*)name
{
	return @"You should not see this";
}

@end

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0

double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}

// See http://en.wikipedia.org/wiki/Low-pass_filter for details low pass filtering
@implementation LowpassFilter

-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if(self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = dt / (dt + RC);
	}
	return self;
}

-(void)addAcceleration:(UIAcceleration*)accel
{
	double alpha = filterConstant;
	
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(accel.x, accel.y, accel.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
	}
	
	x = accel.x * alpha + x * (1.0 - alpha);
	y = accel.y * alpha + y * (1.0 - alpha);
	z = accel.z * alpha + z * (1.0 - alpha);
}

-(void)addRotation:(CMRotationRate)rotation
{
	double alpha = filterConstant;
	
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(fx, fy, fz) - Norm(rotation.x, rotation.y, rotation.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
	}
	
	fx = rotation.x * alpha + fx * (1.0 - alpha);
	fy = rotation.y * alpha + fy * (1.0 - alpha);
	fz = rotation.z * alpha + fz * (1.0 - alpha);
}


-(void)addAttitude:(CMAttitude*)atti
{
	double alpha = filterConstant;
	
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(fx, fy, fz) - Norm(atti.roll, atti.pitch, atti.yaw)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
	}
	
	fx = atti.roll* alpha + fx * (1.0 - alpha);
	fy = atti.pitch * alpha + fy * (1.0 - alpha);
	fz = atti.yaw * alpha + fz * (1.0 - alpha);
}

-(NSString*)name
{
	return adaptive ? @"Adaptive Lowpass Filter" : @"Lowpass Filter";
}

@end

// See http://en.wikipedia.org/wiki/High-pass_filter for details on high pass filtering
@implementation HighpassFilter

-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if(self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = RC / (dt + RC);
	}
	return self;
}

-(void)addAcceleration:(UIAcceleration*)accel
{
	double alpha = filterConstant;
	
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(accel.x, accel.y, accel.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = d * filterConstant / kAccelerometerNoiseAttenuation + (1.0 - d) * filterConstant;
	}
	
	x = alpha * (x + accel.x - lastX);
	y = alpha * (y + accel.y - lastY);
	z = alpha * (z + accel.z - lastZ);
	
	lastX = accel.x;
	lastY = accel.y;
	lastZ = accel.z;
}

-(NSString*)name
{
	return adaptive ? @"Adaptive Highpass Filter" : @"Highpass Filter";
}

@end