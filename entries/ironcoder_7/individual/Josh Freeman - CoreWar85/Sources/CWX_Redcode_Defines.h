/*
 *  CWX_Redcode_Defines.h
 *  CoreWarX
 *
 *  Created by Josh Freeman on 11/11/07.
 *  Copyright 2007 Twilight Edge Software. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

typedef enum
{
	Redcode_Opcode_DAT = 0,
	Redcode_Opcode_MOV,
	Redcode_Opcode_ADD,
	Redcode_Opcode_SUB,
	Redcode_Opcode_JMP,
	Redcode_Opcode_JMZ,
	Redcode_Opcode_JMG,
	Redcode_Opcode_DJZ,
	Redcode_Opcode_CMP,
	Redcode_Opcode_SPL

} Redcode_Opcode;

typedef enum
{
	Redcode_AddressMode_Immediate = 0,
	Redcode_AddressMode_Direct,
	Redcode_AddressMode_Indirect

} Redcode_AddressMode;

typedef struct
{
	unsigned char opcode;
	unsigned char addressModeA;
	unsigned char addressModeB;
	unsigned char _unusedAlign;
	short argumentA;
	short argumentB;

} Redcode_MemoryCell;
