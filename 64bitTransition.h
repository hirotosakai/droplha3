//
//  64bitTransition.h
//
//  Created by Hiroto Sakai on 2016-09-20.
//  Based on 64-Bit Transition Guide from Apple

#if __LP64__ || NS_BUILD_32_LIKE_64
typedef long NSInteger;
typedef unsigned long NSUInteger;
#else
typedef int NSInteger;
typedef unsigned int NSUInteger;
#endif