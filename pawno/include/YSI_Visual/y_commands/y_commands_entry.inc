#if defined _INC_y_commands
	#endinput
#endif
#define _INC_y_commands

/*
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 the "License"; you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the YSI framework.
	
	The Initial Developer of the Original Code is Alex "Y_Less" Cole.
	Portions created by the Initial Developer are Copyright (c) 2022
	the Initial Developer. All Rights Reserved.

Contributors:
	Y_Less
	koolk
	JoeBullet/Google63
	g_aSlice/Slice
	Misiur
	samphunter
	tianmeta
	maddinat0r
	spacemud
	Crayder
	Dayvison
	Ahmad45123
	Zeex
	irinel1996
	Yiin-
	Chaprnks
	Konstantinos
	Masterchen09
	Southclaws
	PatchwerkQWER
	m0k1
	paulommu
	udan111
	Cheaterman

Thanks:
	JoeBullet/Google63 - Handy arbitrary ASM jump code using SCTRL.
	ZeeX - Very productive conversations.
	koolk - IsPlayerinAreaEx code.
	TheAlpha - Danish translation.
	breadfish - German translation.
	Fireburn - Dutch translation.
	yom - French translation.
	50p - Polish translation.
	Zamaroht - Spanish translation.
	Los - Portuguese translation.
	Dracoblue, sintax, mabako, Xtreme, other coders - Producing other modes for
		me to strive to better.
	Pixels^ - Running XScripters where the idea was born.
	Matite - Pestering me to release it and using it.

Very special thanks to:
	Thiadmer - PAWN, whose limits continue to amaze me!
	Kye/Kalcor - SA:MP.
	SA:MP Team past, present and future - SA:MP.

Optional plugins:
	Gamer_Z - GPS.
	Incognito - Streamer.
	Me - sscanf2, fixes2, Whirlpool.
*/

#include "..\..\YSI_Core\y_utils"

#define MAX_COMMAND_LENGTH              (FUNCTION_LENGTH)

#define COMMAND_NOT_FOUND               (-1)

#if !defined MAX_COMMANDS
	#define MAX_COMMANDS                (512)
#endif

// Misc includes.
#include "..\..\YSI_Data\y_hashmap"
#include "..\..\YSI_Data\y_iterate"
#include "..\..\YSI_Data\y_playerarray"
#include "..\..\YSI_Server\y_punycode"

// Include the group functions (maybe).
#define Y_COMMANDS_GROUP_NAME<%0...%1> %0YCMD%1
#define Y_COMMANDS_GROUP_LIMIT         MAX_COMMANDS
#define Y_COMMANDS_GROUP_TAG           _

// The one external function that we need to rename
#define YCMD_SetPlayer Command_SetPlayer
#include "..\..\YSI_Players\y_groups\y_groups__include"

// Redefine the new names back to the old names.
#define Command_InitialiseFromGroups YCMD_InitialiseFromGroups
#define Group_SetCommand Group_SetYCMD
#define Group_CommandAllowed Group_YCMDAllowed
#define Group_CommandDenied Group_YCMDDenied
#define Group_GetCommand Group_GetYCMD
#define Group_SetCommandDefault Group_SetYCMDDefault
#define Group_SetCommandNew Group_SetYCMDNew
#define Group_ExclusiveCommand Group_ExclusiveYCMD
#define Iter_Func@Group_Command Iter_Func@Group_YCMD
#define Iterator@Group_Command Iterator@Group_YCMD
#define iterstart@Group_Command iterstart@Group_YCMD
#define Group_SetGlobalCommand Group_SetGlobalYCMD
#define Group_GlobalCommandAllowed Group_GlobalYCMDAllowed
#define Group_GlobalCommandDenied Group_GlobalYCMDDenied
#define Group_GetGlobalCommand Group_GetGlobalYCMD
#define Group_SetGlobalCommandDefault Group_SetGlobalYCMDDefault
#define Group_SetGlobalCommandNew Group_SetGlobalYCMDNew
#define Group_GlobalExclusiveCommand Group_GlobalExclusiveYCMD
#define Iter_Func@Group_GlobalCommand Iter_Func@Group_GlobalYCMD
#define Iterator@Group_GlobalCommand Iterator@Group_GlobalYCMD
#define iterstart@Group_GlobalCommand iterstart@Group_GlobalYCMD

// Set commands as master 51.
#define MASTER 51
#define YSIM_U_DISABLE
#include "..\..\YSI_Core\y_master"

#if defined YSI_TESTS
	#if !defined Y_COMMANDS_NO_IPC
		#define Y_COMMANDS_NO_IPC
	#endif
#endif

#include "..\..\YSI_Coding\y_hooks"
#include "..\..\YSI_Server\y_thirdpartyinclude\y3_indirection"
#include "..\..\YSI_Coding\y_remote"

// Include the main implementation.
#include "y_commands_impl"

#if defined YSI_TESTS
	#include "..\..\YSI_Coding\y_inline"
	#if defined YSI_NO_TEST_WARNINGS
		#pragma warning push
		#pragma warning disable 203
		#pragma warning disable 204
		#pragma warning disable 213
		#pragma warning disable 214
		#pragma warning disable 219
		#pragma warning disable 234
		#pragma warning disable 239
		#pragma warning disable 240
	#endif
	#include "y_commands_tests"
	#if defined YSI_NO_TEST_WARNINGS
		#pragma warning pop
	#endif
#endif

// Restore previous settings.
//#undef _GROUP_MAKE_LIMIT
//#undef _GROUP_MAKE_NAME

#include "..\..\YSI_Core\y_master"

