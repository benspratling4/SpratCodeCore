//
//  NSData+SpratCodeCore.m
//  SpratCodeCore
//
//  Created by Ben Spratling on 6/18/15.
//  Copyright (c) 2015 benspratling.com. All rights reserved.
//

#import "NSData+SpratCodeCore.h"

@implementation NSData (SpratCodeCore)


void FillBufferWithRandomData(uint8_t* buffer, size_t size)
{
	FILE *fp = fopen("/dev/random", "r");
	if (!fp) {
		perror("randgetter");
		exit(-1);
	}
	int i;
	for (i=0; i<size; i++) {
		uint8_t c = fgetc(fp);
		buffer[i] = c;
	}
	fclose(fp);
}


uint8_t* CreateRandomDataWithLength(NSUInteger length)
{
	uint8_t* data = malloc(length);
	FillBufferWithRandomData(data, length);
	return data;
}


+ (NSData *)randomDataWithLength_scc:(NSUInteger)length {
	uint8_t* data = CreateRandomDataWithLength(length);
	return [NSData dataWithBytesNoCopy:data length:length freeWhenDone:YES];
}


@end
