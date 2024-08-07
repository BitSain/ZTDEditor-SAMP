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

// TODO: Two dialog IDs - one for `Dialog_ShowCallback`, one for `Dialog_Show`.
// NEVER re-use `_A<_yD@>`
const YSI_DIALOG_ID_1 = _A<@_yD>;
const YSI_DIALOG_ID_2 = _A<_@yD>;

#define YSI_DIALOG_NONE (Func:0<iiiis>)
#define YSI_DIALOG_MASK (Func:cellmax<iiiis>)
#define YSI_DIALOG_INVALID (Func:cellmin<iiiis>)

static stock
	YSI_g_sPlayerDialog[MAX_PLAYERS] = {-1, ...},
	Func:YSI_g_sPlayerCallback[MAX_PLAYERS]<iiiis>;

stock Dialog_Get(playerid)
{
	return YSI_g_sPlayerDialog[playerid];
}

REMOTE_FUNC__ void:Dialog_Set(playerid, dialogid)
{
	// If they could already see a dialog shown by this script, get rid of the
	// data from that one.
	YSI_g_sPlayerDialog[playerid] = dialogid;
	if (YSI_g_sPlayerCallback[playerid] & YSI_DIALOG_MASK)
	{
		Indirect_Release(YSI_g_sPlayerCallback[playerid]);
	}
	YSI_g_sPlayerCallback[playerid] = YSI_DIALOG_NONE;
}

// Func:callback<iiiis> | Func:callback<iis>
stock bool:Dialog_ShowCallback(playerid, {F@_@iiiis, F@_@iis}:callback, DIALOG_STYLE:style, const string:title[], const string:caption[], const string:button1[], const string:button2[] = "", tag = tagof (callback))
{
	BROADCAST_FUNC__ Dialog_Set(playerid, YSI_DIALOG_ID_1);
	Indirect_Claim(callback),
	Indirect_SetTag(callback, tag),
	// Works tag-safely because the compile-time tag check uses `<iiiis>`.
	YSI_g_sPlayerCallback[playerid] = callback;
	return bool:ShowPlayerDialog(playerid, YSI_DIALOG_ID_1, style, __const(title), __const(caption), __const(button1), __const(button2));
}

#if __COMPILER_WARNING_SUPPRESSION
	// On old compilers, only issue the warning at the call site.
	#pragma warning push
	#pragma warning disable 234
#endif
#pragma deprecated Use Dialog_ShowCallback
stock bool:Dialog_ShowCallbackData(playerid, callback[E_CALLBACK_DATA], DIALOG_STYLE:style, const string:title[], const string:caption[], const string:button1[], const string:button2[] = "")
{
	return bool:Dialog_ShowCallback(playerid, F@_@iiiis:callback[E_CALLBACK_DATA:0], style, title, caption, button1, button2);
}
#if __COMPILER_WARNING_SUPPRESSION
	#pragma warning pop
#endif

stock bool:Dialog_Show(playerid, DIALOG_STYLE:style, const string:title[], const string:caption[], const string:button1[], const string:button2[] = "")
{
	BROADCAST_FUNC__ Dialog_Set(playerid, YSI_DIALOG_ID_2);
	YSI_g_sPlayerCallback[playerid] = YSI_DIALOG_INVALID;
	return bool:ShowPlayerDialog(playerid, YSI_DIALOG_ID_2, style, __const(title), __const(caption), __const(button1), __const(button2));
}

stock bool:Dialog_Hide(playerid)
{
	BROADCAST_FUNC__ Dialog_Set(playerid, -1);
	#if defined HidePlayerDialog
		return bool:HidePlayerDialog(playerid);
	#else
		// This almost looks like a Windows API function call!
		return bool:ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, NULL, NULL, NULL, NULL);
	#endif
}

HOOK__ OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	// If this is a filterscript that has the currently displayed dialog in it,
	// then we need all scripts to know that this is no longer the case.  If
	// this script is not in charge of the current dialog then do not broadcast
	// the reset, just do it locally.
	YSI_g_sPlayerDialog[playerid] = -1;
	// This is NOT a `YSI_DIALOG_MASK` test, because we want to pass for invalid
	// callbacks, i.e. just normal dialogs.
	if (YSI_g_sPlayerCallback[playerid])
	{
		if (YSI_g_sPlayerCallback[playerid] != YSI_DIALOG_INVALID)
		{
			Indirect_Release(YSI_g_sPlayerCallback[playerid]);
		}
		YSI_g_sPlayerCallback[playerid] = YSI_DIALOG_NONE;
		
		#if defined HidePlayerDialog
			HidePlayerDialog(playerid);
		#else
			ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, NULL, NULL, NULL, NULL);
		#endif
	}
	return 1;
}

// Fix `tagof` on the old compiler.
__COMPILER_TAG_DATA(F@_@iis, 0);
__COMPILER_TAG_DATA(F@_@iiiis, 0);

// `playerid, dialogid, response, listitem, inputtext[]`, but shorter (because
// otherwise the old compiler crashes...)
HOOK__ OnDialogResponse(p,d,r,l,i[])
{
	#pragma unused d
	// Apparently there's a hack to alter this.
	d = YSI_g_sPlayerDialog[p];
	Debug_Print1("Dialog_OnDialogResponse called: %d %d %d %d %s", p, d, r, l, i);
	if (d == YSI_DIALOG_ID_1)
	{
		// Can't be `YSI_DIALOG_INVALID`, because `d == YSI_DIALOG_ID_1.
		if (YSI_g_sPlayerCallback[p])
		{
			new
				Func:callback<iiiis> = YSI_g_sPlayerCallback[p];
			YSI_g_sPlayerCallback[p] = YSI_DIALOG_NONE;
			// Totally blank the stored dialog information, after making a local
			// copy of it for the sake of calling the callback.  This is so that
			// we don't free the memory for the callback prematurely.
			BROADCAST_FUNC__ Dialog_Set(p, -1);
			// Call the callback.
			if (Indirect_GetTag(callback) == _:tagof (F@_@iiiis:))
			{
				Indirect_Call(_:callback, tagof (F@_@iiiis:), p, YSI_DIALOG_ID_1, r, l, IsNull(i) ? NULL : i);
			}
			else
			{
				Indirect_Call(_:callback, tagof (F@_@iis:), r, l, IsNull(i) ? NULL : i);
			}
			// Free the data.
			Indirect_Release(callback);
			return ~1;
		}
		return ~0;
	}
	return 0;
}

stock bool:Dialog_ShowPlayerDialog(playerid, dialog, DIALOG_STYLE:style, const string:title[], const string:caption[], const string:button1[], const string:button2[])
{
	// Fail.
	if (dialog == YSI_DIALOG_ID_1 || dialog == YSI_DIALOG_ID_2)
	{
		Debug_Error("Trying to show a dialog with YSI reserved ID %d", dialog);
		return false;
	}
	BROADCAST_FUNC__ Dialog_Set(playerid, dialog);
	YSI_g_sPlayerCallback[playerid] = YSI_DIALOG_INVALID;
	return bool:ShowPlayerDialog(playerid, dialog, style, __const(title), __const(caption), __const(button1), __const(button2));
}

#if defined _ALS_ShowPlayerDialog
	#undef ShowPlayerDialog
#else
	#define _ALS_ShowPlayerDialog
#endif
#define ShowPlayerDialog Dialog_ShowPlayerDialog

#define _ALS_HidePlayerDialog
#define HidePlayerDialog Dialog_Hide

