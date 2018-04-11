//
//  BulletPhysics.m
//  BulletTest
//
//  Created by Borna Noureddin on 2015-03-20.
//  Modified by Daniel Tian (A00736794) on 2018-04-11
//  Source: http://www.bulletphysics.org/mediawiki-1.5.8/index.php/Hello_World
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "BulletPhysics.h"
//#include "BulletCollision/Gimpact/btGImpactCollisionAlgorithm.h"

@interface BulletPhysics(){
    btBroadphaseInterface *broadphase;
    btDefaultCollisionConfiguration* collisionConfiguration;
    btCollisionDispatcher* dispatcher;
    btSequentialImpulseConstraintSolver* solver;
    btDiscreteDynamicsWorld* dynamicsWorld;
    
    btCollisionShape* groundShape;
    btCollisionShape* fallShape;
    btCollisionShape* cubeShape;
    
    btDefaultMotionState* groundMotionState;
    btRigidBody* groundRigidBody;
    
    btDefaultMotionState* fallMotionState; //for the sphere
    btRigidBody* fallRigidBody;
    
    btDefaultMotionState* cubeMotionstate; //for the cube
    btRigidBody* cubeRigidBody;
    
    btDefaultMotionState* cameraMotionState;//for the camera
    btRigidBody* cameraRigidBody;
}
@end

@implementation BulletPhysics

@synthesize sphereTransform;
@synthesize cubeTransform;
@synthesize cameraTransform;

//constants
const float GRAVITY_VALUE = -9.81f;

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        sphereTransform.setY(10.f);
        
        // Build the broadphase
        broadphase = new btDbvtBroadphase();
        
        // Set up the collision configuration and dispatcher
        collisionConfiguration = new btDefaultCollisionConfiguration();
        dispatcher = new btCollisionDispatcher(collisionConfiguration);
        
        // The actual physics solver
        solver = new btSequentialImpulseConstraintSolver;
        
        // The world.
        dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher, broadphase, solver, collisionConfiguration);
        dynamicsWorld->setGravity(btVector3(0, GRAVITY_VALUE, 0));

        groundShape = new btStaticPlaneShape(btVector3(0, 1, 0), 1); //we will place a ground plane running through the origin, y = 1
        
        fallShape = new btBoxShape(btVector3(.5f, .5f, .5f));//new btSphereShape(1); //The shape that we will let fall from the sky is a sphere with a radius of 1 metre.
        
        cubeShape = new btBoxShape(btVector3(.5f, .5f, .5f));
        
        
        //Rigid Bodies
        groundMotionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(0, -1, 0)));
        
        btRigidBody::btRigidBodyConstructionInfo groundRigidBodyCI(0, groundMotionState, groundShape, btVector3(0, 0, 0));
        groundRigidBody = new btRigidBody(groundRigidBodyCI);
        groundRigidBody->setRestitution(1.0f);
        
        dynamicsWorld->addRigidBody(groundRigidBody); //we add the ground to the world
        
        //Adding the falling sphere is very similar. We will place it 10m above the ground.
        fallMotionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(0, sphereTransform.getY(), 0)));
        
        //Since it's dynamic we will give it a mass of 1kg. I can't remember how to calculate the inertia of a sphere, but that doesn't matter because Bullet provides a utility function
        btScalar mass = 1;
        btVector3 fallInertia(0, 0, 0);
        fallShape->calculateLocalInertia(mass, fallInertia);
        
        //Now we can construct the rigid body just like before, and add it to the world:
        btRigidBody::btRigidBodyConstructionInfo fallRigidBodyCI(mass, fallMotionState, fallShape, fallInertia);
        fallRigidBody = new btRigidBody(fallRigidBodyCI);
        dynamicsWorld->addRigidBody(fallRigidBody);
        
        
        //cube motion state
        cubeMotionstate = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(0,10, 0)));
        
        cubeShape->calculateLocalInertia(mass, fallInertia);
        btRigidBody::btRigidBodyConstructionInfo cubeRigidBodyCI(mass, cubeMotionstate, cubeShape, fallInertia);
        cubeRigidBody = new btRigidBody(cubeRigidBodyCI);
        
        cubeRigidBody->setRestitution(.6f);
        dynamicsWorld->addRigidBody(cubeRigidBody);
        
        
        //camera motion state
        mass = 15;
        cameraMotionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(-5,0,-5)));
        btRigidBody::btRigidBodyConstructionInfo camRigidBodyCI(mass, cameraMotionState, cubeShape, fallInertia);
        cameraRigidBody = new btRigidBody(camRigidBodyCI);
        dynamicsWorld->addRigidBody(cameraRigidBody);
        
    }
    return self;
}

-(void) checkCollision{
    //Assume world->stepSimulation or world->performDiscreteCollisionDetection has been called
    
    dynamicsWorld->performDiscreteCollisionDetection();
    
    int numManifolds = dynamicsWorld->getDispatcher()->getNumManifolds();
    for (int i = 0; i < numManifolds; i++)
    {
        btPersistentManifold* contactManifold =  dynamicsWorld->getDispatcher()->getManifoldByIndexInternal(i);
        const btCollisionObject* obA = contactManifold->getBody0();
        const btCollisionObject* obB = contactManifold->getBody1();

        int numContacts = contactManifold->getNumContacts();
        for (int j = 0; j < numContacts; j++)
        {
            btManifoldPoint& pt = contactManifold->getContactPoint(j);
            if (pt.getDistance() < 0.f)
            {
                const btVector3& ptA = pt.getPositionWorldOnA();
                const btVector3& ptB = pt.getPositionWorldOnB();
                const btVector3& normalOnB = pt.m_normalWorldOnB;
                //[self ApplyForce];
                //printf("Collided\n");
            }
        }
    }
}

- (void)dealloc
{
    // Clean up behind ourselves
    dynamicsWorld->removeRigidBody(cameraRigidBody);
    delete cameraRigidBody->getMotionState();
    delete cameraRigidBody;
    
    dynamicsWorld->removeRigidBody(cubeRigidBody);
    delete cubeRigidBody->getMotionState();
    delete cubeRigidBody;
    
    dynamicsWorld->removeRigidBody(fallRigidBody);
    delete fallRigidBody->getMotionState();
    delete fallRigidBody;
    
    dynamicsWorld->removeRigidBody(groundRigidBody);
    delete groundRigidBody->getMotionState();
    delete groundRigidBody;
    
    delete fallShape;
    delete cubeShape;
    
    delete groundShape;
    
    delete dynamicsWorld;
    delete solver;
    delete collisionConfiguration;
    delete dispatcher;
    delete broadphase;
}

-(void)UpdateCamera:(float)x _y:(float)y _z:(float) z{
    cameraTransform.setX(x);
    cameraTransform.setY(y);
    cameraTransform.setZ(z);
    
    btTransform transform;
    transform.setOrigin(cameraTransform);
    transform.setRotation(btQuaternion(0, 0, 0, 1));
    // transform.setBasis(someMatrix) // Optionally rotate by a btMatrix3x3
    
    cameraRigidBody->setWorldTransform(transform);
}

-(void)Update:(float)elapsedTime
{
    //[self checkCollision];
    
    dynamicsWorld->stepSimulation(1 / 60.f, 10);
    //dynamicsWorld->performDiscreteCollisionDetection();
    btTransform trans;
    fallRigidBody->getMotionState()->getWorldTransform(trans);
    sphereTransform = trans.getOrigin(); //.setY(trans.getOrigin().getY());
    btTransform trans2;
    cubeRigidBody->getMotionState()->getWorldTransform(trans2);
    cubeTransform = trans2.getOrigin();
    
    
    //btTransform camtrans;
    //cameraRigidBody->getMotionState()->getWorldTransform(camtrans);
    //printf("cam transform: %f, %f, %f\n", camtrans.getOrigin().getX(), camtrans.getOrigin().getY(), camtrans.getOrigin().getZ());
    //printf("Cube transform: %f, %f, %f\n", cubeTransform.getX(), cubeTransform.getY(), cubeTransform.getZ());
    //printf("sphere height: %f\n", trans.getOrigin().getY()); //NSLog(@"%f\t%f\n", elapsedTime*1000, trans.getOrigin().getY());
}

-(void)ApplyForce{
    float force = 5.0f;
    cubeRigidBody->activate(true);
    cubeRigidBody->applyCentralImpulse(btVector3(0.f,force,0.f));
}

@end
