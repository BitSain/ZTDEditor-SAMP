#if defined _INC_y_inline
	#endinput
#endif
#define _INC_y_inline

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

#include "..\..\YSI_Server\y_thirdpartyinclude"
#include "..\y_va"
#include "..\y_cgen"

#if !defined YSI_MAX_INLINE_STRING
	#define YSI_MAX_INLINE_STRING YSI_MAX_STRING
#endif

#include "..\y_malloc"

CHAIN_HOOK(Inline)
#undef CHAIN_ORDER
#define CHAIN_ORDER CHAIN_NEXT(Inline)

#include "y_inline_impl"

// Not implemented errors.
#include "y_inline_extra"

#if defined YSI_TESTS
	#include "..\y_hooks"
	//#include "..\..\YSI_Extra\y_inline_bcrypt"
	//#include "..\..\YSI_Extra\y_inline_mysql"
	//#include "..\..\YSI_Extra\y_inline_requests"
	#include "..\..\YSI_Extra\y_inline_timers"
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
	#include "y_inline_tests"
	#if defined YSI_NO_TEST_WARNINGS
		#pragma warning pop
	#endif
#endif

