#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

@interface ShaderLoader : NSObject

@property (nonatomic, assign) GLuint PROGRAM_HANDLE;

- (id) initWithVertexShader: (NSString *) vertexShader
             fragmentShader: (NSString *) fragmentShader;

- (void)prepareToDraw;

@end
