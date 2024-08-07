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

static stock
	sgPlayerCounter[MAX_PLAYERS];

HOOK__ OnPlayerConnect(playerid)
{
	sgPlayerCounter[playerid] = 0;
}

ptask y_timers_PCounter[1000](playerid)
{
	// What an odd bug!  Putting this in a format breaks the format!
	++sgPlayerCounter[playerid];
	//printf("playerid: %d, %d", playerid, sgPlayerCounter[playerid]);
	//new
	//	b = sgPlayerCounter[playerid];
	//printf("playerid: %d, %d", playerid, b);
	va_SendClientMessage(playerid, 0xFF0000AA, "PLAYER COUNTER: %d", sgPlayerCounter[playerid]);
}

task y_timers_Counter[1000]()
{
	static
		sCounter = 0;
	va_SendClientMessageToAll(0x0000FFAA, "GLOBAL COUNTER: %d", sCounter++);
}

@test(.group = "y_timers") PCounter1(playerid)
{
	ASK("Is the red PLAYER COUNTER going up?");
}

@test(.group = "y_timers") PCounter2(playerid)
{
	pause y_timers_PCounter[playerid];
	ASK("Has the red PLAYER COUNTER stopped?");
}

@test(.group = "y_timers") Counter1(playerid)
{
	ASK("Is the blue GLOBAL COUNTER going up?");
}

@test(.group = "y_timers") Counter2(playerid)
{
	pause y_timers_Counter;
	ASK("Has the blue GLOBAL COUNTER stopped?");
}

timer BigMessage1[4000](playerid)
{
	SendClientMessage(playerid, 0x00FF00AA, "BIG MESSAGE appearing once.");
}

timer BigMessage2[4000](playerid)
{
	SendClientMessage(playerid, 0x00FF00AA, "BIG MESSAGE appearing repeatedly.");
}

@test(.group = "y_timers") Timer1(playerid)
{
	DEFER__ BigMessage1(playerid);
	ASK("Is a green BIG MESSAGE appearing once after 4 seconds?");
}

static
	Timer:sgTimer = Timer:0;

@test(.group = "y_timers") Timer2(playerid)
{
	sgTimer = REPEAT__ BigMessage2(playerid);
	ASK("Is a green BIG MESSAGE appearing every 4 seconds?");
}

timer StopMessage1[4000](playerid)
{
	SendClientMessage(playerid, 0x00FF00AA, "BIG MESSAGE should stop now.");
	STOP__ sgTimer;
}

@test(.group = "y_timers") Timer3(playerid)
{
	DEFER__ StopMessage1(playerid);
	ASK("Is the green BIG MESSAGE stopping appearing after 4 seconds?");
}

forward Timer:_yT@ForwardTimer(string:msg[]);

@test(.group = "y_timers") ForwardTimer()
{
	DEFER__ ForwardTimer("hi");
}

timer ForwardTimer[5000](string:msg[])
{
	#pragma unused msg
}

static stock
	Timer:YSI_g_sStopAndStart;

timer StopAndStart[50]()
{
	//printf("StopAndStart started");
	//printf("===================");
	STOP__ YSI_g_sStopAndStart;
	//printf("StopAndStart ended");
}

@test(.group = "y_timers") StopAndStart()
{
	YSI_g_sStopAndStart = DEFER__ StopAndStart();
	ASSERT(Timer_IsRunning(YSI_g_sStopAndStart));
	ASSERT_NZ(_Timer_F(YSI_g_sStopAndStart, 1)); // `stop`
	ASSERT(!Timer_IsRunning(YSI_g_sStopAndStart));
	ASSERT_ZE(_Timer_F(YSI_g_sStopAndStart, 1)); // `stop`
	ASSERT(!Timer_IsRunning(YSI_g_sStopAndStart));
	YSI_g_sStopAndStart = DEFER__ StopAndStart();
}

timer StopAndStop[50]()
{
	printf("StopAndStop started: %d", _:_YSI_g_sCurrentTimer);
	STOP__;
	STOP__;
	STOP__;
	printf("StopAndStop finished");
}

@test(.group = "y_timers", .run = false) StopAndStop()
{
	YSI_g_sStopAndStart = REPEAT__[5] StopAndStop();
	for (new i = 0; i != 1000; ++i)
	{
		ASSERT_NZ(DEFER__ StopAndStop());
	}
}

new Timer:YSI_g_sKillYourself;

@timer(0) KillYourself()
{
	printf("KillYourself start");
	STOP__ YSI_g_sKillYourself;
	printf("KillYourself end");
}

@test(.group = "y_timers") KillYourself()
{
	printf("KillYourself before");
	YSI_g_sKillYourself = defer KillYourself();
	printf("KillYourself after");
}

@timer(500) y_timers_syntax2()
{
}

#if defined YSI_NO_TEST_WARNINGS
	#pragma unused _@yTy_timers_syntax2
#endif

@timer(500, .auto = true) y_timers_syntax3(playerid)
{
}

@timer(500, true)y_timers_syntax4()
{
}

@timer(100) TimeOverride()
{
}

@test(.group = "y_timers") TimeOverride()
{
	new time = 10;
	new Timer:t = defer TimeOverride[_:time * 50]();
	#pragma unused t
}

