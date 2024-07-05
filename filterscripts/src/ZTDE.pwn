// Start of file
/*
 *     Zamaroht's TextDraw Editor Continued by BitSain
 *     Designed for SA-MP 0.3.7
 *     (C) 2024 BitSain | All right reserved. 
 *
 *     Release of Project: v1.0.0
 *     Last Update Date: 05.07.2024 - 12:35h (day.month.year - hours:minutes)
 *
 *     [!] Compiled with Zeex's Compiler
 *     [!] Link of Compiler: https://github.com/pawn-lang/compiler/releases/                 
 *     [!] Compiler version: 3.10.10+
 *
 *     =================================================================
 *
 *     Original Author: Zamaroht (Nicol�s Laurito)
 *     Continuity Author: BitSain (bitsaindeveloper@gmail.com)
 *
 *     Start of Development (Old): 25 December 2009, 22:16 (GMT-3)
 *     End of Development (Old): 01 January 2010, 23:31 (GMT-3)
 *     Start of Continuation: 24 February 2024, 11:15 (GMT-3) [BRAZIL]
 *
 *     [ Credits ]:
 *        - 'Zamaroht' Nicol�s Laurito (Author and Creator of version v1.0.0)
 *        - BitSain (Repository creator and project continuer from v1.0.0)
 *
 *        - SAMP Team (a_samp include)
 *        - Y_Less (YSI includes & sscanf2)
 *        - JaTochNietDan (filemanager plugin)
 *        - oscar-broman (strlib)
 *        - Dini and dutils functions were used by DracoBlue.
 *
 *     =================================================================
 *
 *     [ Disclaimer ]:
 *     You do not need to include me in your credits if you used this filterscript to create your textdraws.
 *     You hold all rights over the exported files and filterscripts created by this filterscript.
 *     You can redistribute the main filterscript as you wish, but ALWAYS keep the name of the author, the continuator, 
 *     and a link back to the original post https://portalsamp.com/showthread.php?tid=4754) attached to the means of distribution.
 *     Even if you create a modification based on this filterscript, the same terms apply.
 *
 *     [ Warning ]:
 *     Reproduction of ZTDEditor Without proper credit is Prohibited.
 *     Do not duplicate this script elsewhere!
*/

// =============================================================================
//                  ->              OPTIONS
// =============================================================================
// SCRIPT 
#define FILTERSCRIPT

// YSI
#define YSI_NO_OPTIMISATION_MESSAGE
#define YSI_NO_VERSION_CHECK
#define YSI_NO_CACHE_MESSAGE
#define YSI_NO_MODE_CACHE
#define YSI_NO_VERSION_CHECK
#define YSI_NO_HEAP_MALLOC

// =============================================================================
//                  ->              INCLUDES
// =============================================================================
#include <a_samp>
#undef MAX_PLAYERS
#define MAX_PLAYERS 10

#include <sscanf2>
#include <filemanager>
#include <strlib>
#include <Dini>

#include <YSI_Coding\y_inline>
#include <YSI_Data\y_iterate>
#include <YSI_Data\y_foreach>
#include <YSI_Visual\y_dialog>

// =============================================================================
// 					->				Internal Declarations
// =============================================================================
//Configs
#define ZTDE_VERSION "v1.0.0"

// Avoid use experimental features in production projects to prevent potential bugs. 
 // I'm still testing these features.
#define ZTDE_EXPERIMENTAL false // false = DISABLE | true = ENABLE

//Debug
#define ZTDE_DEBUG false         //true = enable | false = disable
#define ZTDE_DEBUG_LEVEL 0   //0 = None | 1 = m�nim details | 2 = medium details | 3 = max details

#if ZTDE_DEBUG_LEVEL != 0
    #if ZTDE_DEBUG == false
        #error [ZTDE ERROR]: 'ZTDE_DEBUG' is disabled! Activate it. (Line 76 | false to true)
    #endif
#endif

//Macros
#define function%0(%1) forward%0(%1); public%0(%1)

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

// Standardize Messages
#define ScriptMessage(%0,%1) SendClientMessage(%0, MSG_COLOR, %1)
#define ScriptMessageToAll(%1) SendClientMessageToAll(MSG_COLOR, %1)

// Limits
#define MAX_TEXTDRAWS       	256					 // Max textdraws shown on client screen.
#define MSG_COLOR           		0xFAF0CEFF	 	 // Color to be shown in the messages.
#define PREVIEW_CHARS       	35					 // Amount of characters that show on the textdraw's preview.

//Directories
#define PROJECT_DIRECTORY "ztdeditor/Projects/%s"
#define EXPORT_DIRECTORY "ztdeditor/ExportProjects/%s"
#define IMPORT_DIRECTORY "ztdeditor/ImportTextDraws/"
#define IMPORT_DIRECTORY2 IMPORT_DIRECTORY"%s"

// Used with P_Aux
enum {
    DELETING,
    LOADING
};

// Used with P_KeyEdition
enum {
    EDIT_NONE, 
    EDIT_POSITION, 
    #if ZTDE_EXPERIMENTAL == true
        EDIT_ALL_TD_POSITION, 
        EDIT_ALL_TD_SIZE,
    #endif
    EDIT_SIZE, 
    EDIT_BOX
};

// Used with P_ColorEdition
enum {
    COLOR_TEXT,
    COLOR_OUTLINE,
    COLOR_BOX
};

// TextDraws Alignments
enum {
    ALIGN_LEFT = 1,
    ALIGN_CENTER,
    ALIGN_RIGHT
};

// DIALOG IDS
enum {
    DIALOG_SELECT_PROJECT, //0
    DIALOG_NEW_PROJECT_FILENAME, //1
    DIALOG_LOAD_PROJECT_MENU, //2
    DIALOG_LOAD_PROJECT_FILENAME, //3
    DIALOG_MAIN_EDITION_MENU, //4
    DIALOG_TEXTDRAW_EDIT_MENU, //5
    DIALOG_CONFIRM_DELETE_PROJECT, //6
    DIALOG_CONFIRM_DELETE_TEXTDRAW, //7
    DIALOG_ETD_STRING, //8
    DIALOG_ETD_POSITION, //9
    DIALOG_ETD_POSITION2, //10
    DIALOG_ETD_ALIGNMENT, //11
    DIALOG_ETD_PROPORTIONAL, //12
    DIALOG_ETD_COLOR, //13
    DIALOG_ETD_HEX_COLOR, //14
    DIALOG_ETD_RGB_COLOR, //15
    DIALOG_ETD_COLOR_PRESETS, //16
    DIALOG_ETD_FONT, //17
    DIALOG_ETD_FONTSIZE, //18
    DIALOG_ETD_FONTSIZE2, //19
    DIALOG_ETD_OUTLINE, //20
    DIALOG_ETD_OUTLINE_SHADOW, //21
    DIALOG_ETD_OUTLINE_SHADOW_SIZE, //22
    DIALOG_ETD_BOX, //23
    DIALOG_ETD_BOX2, //24
    DIALOG_ETD_BOX_SIZE, //25
    DIALOG_EXPORT_TEXTDRAW, //26
    DIALOG_EXPORT_FSCRIPT_OPTIONS, //27
    DIALOG_EXPORT_FSCRIPT_COMMAND, //28
    DIALOG_EXPORT_FSCRIPT_DURATION, //29
    DIALOG_EXPORT_FSCRIPT_INTERVAL, //30
    DIALOG_EXPORT_FSCRIPT_DELAY, //31
    DIALOG_EXPORT_FSCRIPT_DELAYKILL, //32
    DIALOG_ETD_SELECTABLE, //33
    DIALOG_ETD_PREVIEW_MODEL_OPT, //34
    DIALOG_ETD_PREVIEW_MODEL_INDEX, //35
    DIALOG_ETD_PREVIEW_MODEL_RX, //36
    DIALOG_ETD_PREVIEW_MODEL_RY, //37
    DIALOG_ETD_PREVIEW_MODEL_RZ, //38
    DIALOG_ETD_PREVIEW_MODEL_ZOOM, //39
    DIALOG_ETD_MODE, //40
    DIALOG_OTHERS_OPTIONS, //41
    DIALOG_SET_ALL_TEXTDRAWS_MODE, //42
    // DIALOG_REORDER_TEXTDRAWS_ID,
    // DIALOF_MOVE_ALL_TEXTS
};

// DATAS
enum enum_tData{ // Textdraw data.
	bool:T_Created, // Wheter the textdraw ID is created or not.
	Text:T_Handler, // Where the TD id is saved itself.
	T_Text[1536], // The textdraw's string.
	Float:T_X,
	Float:T_Y,
    Float:T_TextSize[2],
    Float:T_Size[2],
	T_Alignment,
	T_BackColor,
	T_BoxColor,
	T_Color,
	T_Font,
	T_Outline,
	bool:T_Proportional,
	T_Shadow,
	T_UseBox,
	T_Selectable,
	T_PreviewModel,
	T_Mode,
	Float:PMRotX,
	Float:PMRotY,
	Float:PMRotZ,
	Float:PMZoom
};

enum enum_pData { // Player data.
	bool:P_Editing, // Wheter the player is editing or not at the moment (allow /menu).
	P_DialogPage, // Page of the textdraw selection dialog they are at.
	P_CurrentTextdraw, // Textdraw ID being currently edited.
	P_CurrentMenu, // Just used at the start, to know if the player is LOADING or DELETING.
	P_KeyEdition, // Used to know which editions is being performed with keyboard. Check defines.
	P_Aux, // Auxiliar variable, used as a temporal variable in various cases.
	P_ColorEdition, // Used to know WHAT the player is changing the color of. Check defines.
	P_Color[4], // Holds RGBA when using color combinator.
	P_ExpCommand[128], // Holds temporaly the command which will be used for a command fscript export.
	P_Aux2, // Just used in special export cases.
    //
    bool:P_ReorderingIDs
};
new tData[MAX_TEXTDRAWS][enum_tData],
	pData[MAX_PLAYERS][enum_pData];

new CurrentProject[128]; // String containing the location of the current opened project file.

// Database for the edit textdraws
// new DB:TDProject;

new Iterator:zTextList<MAX_TEXTDRAWS>;

// =============================================================================
// 					->				Callbacks
// =============================================================================

//Filterscript
public OnFilterScriptInit() {
	print("\n--------------------------------------");
	print("[ZTDE]: TextDraw Editor "#ZTDE_VERSION"RC2 by Zamaroht for SA-MP 0.3.7 Loaded.");
	print("[ZTDE]: Continued by BitSain (Bug Fixes, Optization, Improvements and languague support)");
	print("[ZTDE]: Zamaroht's TextDraw Editor Version: "#ZTDE_VERSION"");
	print("--------------------------------------\n");

	foreach(new i : Player){
		ResetPlayerVars(i);
    }

    // TDProject = DB:0;

    Iter_Init(zTextList);
    Iter_Clear(zTextList);
	return true;
}

public OnFilterScriptExit() {
	print("[ZTDE]: Unloading Zamaroht's TextDraw Editor... (Continued by BitSain)");
    
    foreach(new i : Player){
        ResetPlayerVars(i);
        ShowPlayerDialog(i, -1, DIALOG_STYLE_MSGBOX, "", "", "", "");
    }
    foreach(new i : zTextList) {
	    if(tData[i][T_Handler] != Text:INVALID_TEXT_DRAW) TextDrawHideForAll(tData[i][T_Handler]);
	    if(Iter_Contains(zTextList, i) && tData[i][T_Created]) TextDrawDestroy(tData[i][T_Handler]);
	}

    /*if(TDProject)
        db_close(TDProject);

    TDProject = DB:0;*/
    Iter_Clear(zTextList);

	print("[ZTDE]: Zamaroht's TextDraw Editor Unloaded. (Continued by BitSain)");
	return true;
}

// Player
public OnPlayerConnect(playerid) {
    ResetPlayerVars(playerid);
    if(!strlen(CurrentProject) || !strcmp(CurrentProject, " ")) {
    	foreach(new i : zTextList) {
    	    if(Iter_Contains(zTextList, i) && tData[i][T_Created] && tData[i][T_Handler] != Text:INVALID_TEXT_DRAW)
    	        TextDrawHideForPlayer(playerid, tData[i][T_Handler]);
    	}
    }
	return true;
}

public OnPlayerRequestSpawn(playerid) {
	ScriptMessage(playerid, "[ZTDE]: Zamaroht's TextDraw Editor "#ZTDE_VERSION" | Continued by BitSain.");
	ScriptMessage(playerid, "[ZTDE]: Use /Text to show the Edition Menu");
	ScriptMessage(playerid, "[ZTDE]: Use /zHelp to show the Help Menu");

    SpawnPlayer(playerid);
    SetPlayerPos(playerid, 0.0, 0.0, 5.0);
    SetCameraBehindPlayer(playerid);
	return true;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
	if(!strcmp(cmdtext, "/zHelp", true)){
        ScriptMessage(playerid, "[ZTDE]: Building...");
        ScriptMessage(playerid, "[ZTDE]: /zHelp");
        ScriptMessage(playerid, "[ZTDE]: /Text");
		return true;
	}
	else if(!strcmp(cmdtext, "/Text", true)){
		if(pData[playerid][P_Editing]) return ScriptMessage(playerid, "[ZTDE]: Finish the current edition before using /text!");
		if(pData[playerid][P_ReorderingIDs]) return ScriptMessage(playerid, "[ZTDE]: You can't use that command yet. Please wait for the current process to finish.");

		else if(!strlen(CurrentProject) || !strcmp(CurrentProject, " ")){
		    if(IsPlayerMinID(playerid)){
			    ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
			    pData[playerid][P_Editing] = true;
                return true;
		    }
		    else{
		        ScriptMessage(playerid, "[ZTDE]: Just the smaller player ID can manage projects. Ask him to open one.");
                return false;
            }
		}
		else {
		    ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, 0);
		    pData[playerid][P_Editing] = true;
            return true;
		}
	}
	return false;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(response) PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0); // Confirmation sound
    else PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0); // Cancelation sound

    switch(dialogid){
        case (DIALOG_SELECT_PROJECT + 1574): { // First dialog. (OPTIMIZED)
            if(response) { // If he pressed accept.
                strmid(CurrentProject, "", 0, 1, 128);
        
                switch(listitem) {
                    case 0: { // He pressed new project.
                        ShowTextDrawDialog(playerid, DIALOG_NEW_PROJECT_FILENAME);
                        return true;
                    }
                    case 1: { // He pressed load project.
                        ShowTextDrawDialog(playerid, DIALOG_LOAD_PROJECT_MENU, 1);
                        return true;
                    }
                    case 2: { // He pressed delete project.
                        ShowTextDrawDialog(playerid, DIALOG_LOAD_PROJECT_MENU, 2);
                        return true;
                    }
                }
                return false;
            } 
            else {
                pData[playerid][P_Editing] = false;
                return true;
            }
        }
        
        case (DIALOG_NEW_PROJECT_FILENAME + 1574): { // New Project (OPTIMIZED)
            if(response) {
                if(strlen(inputtext) > 120) {
                    ShowTextDrawDialog(playerid, DIALOG_NEW_PROJECT_FILENAME, 1); // Too long.
                    return true;
                } 
                else if(ContainsIllegalCharacters(inputtext) || !strlen(inputtext) || inputtext[0] == ' ') {
                    ShowTextDrawDialog(playerid, DIALOG_NEW_PROJECT_FILENAME, 3); // Illegal characters.
                    return true;
                } 
                else {
                    new filename[128], filedirectory[256]; 
                    format(filename, sizeof(filename), "%s.tde", inputtext);
                    format(filedirectory, sizeof(filedirectory), PROJECT_DIRECTORY, filename);
                    if(fexist(filedirectory)) {
                        ShowTextDrawDialog(playerid, DIALOG_NEW_PROJECT_FILENAME, 2); // Already exists.
                        return true;
                    } else {
                        CreateNewProject(filename);
                        format(CurrentProject, sizeof(CurrentProject), filename);
                        
                        new tmpstr[128];
                        format(tmpstr, sizeof(tmpstr), "[ZTDE]: You are now working on the '%s' project.", filename);
                        ScriptMessage(playerid, tmpstr);
                        
                        ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]); // Show the main edition menu.
                        return true;
                    }
                }
            } 
            else {
                ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
                return true;
            }
        }
        
        case (DIALOG_LOAD_PROJECT_MENU + 1574): { // Load/Delete project (OPTIMIZED)
            if(response) {
                if(pData[playerid][P_CurrentMenu] == DELETING) {
                    if(listitem != 0) {
                        pData[playerid][P_Aux] = listitem - 1;
                        ShowTextDrawDialog(playerid, DIALOG_CONFIRM_DELETE_PROJECT);
                        return true;
                    } 
                    else {
                        ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
                        return true;
                    }
                }
                else if(pData[playerid][P_CurrentMenu] == LOADING) {
                    if(listitem != 0) {
                        new filename[135];
                        format(filename, sizeof(filename), "%s", GetFileNameFromLst("ztdeditor/tdlist.lst", listitem - 1));
                        LoadProject(playerid, filename);
                        return true;
                    } 
                    else {
                        ShowTextDrawDialog(playerid, DIALOG_LOAD_PROJECT_FILENAME);
                        return true;
                    }
                }
            } 
            else {
                ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
                return true;
            }
            return true;
        }
        
        case (DIALOG_LOAD_PROJECT_FILENAME + 1574): { // Load custom project (OPTIMIZED)
            if(response) {
                new directory[256]; format(directory, sizeof(directory), PROJECT_DIRECTORY, inputtext);
                if(!IsProjectFile(inputtext)) {
                    return ScriptMessage(playerid, "[ZTDE]: The file format must be '.tde'");
                }
                LoadProject(playerid, directory);
                return true;
            }
            else {
                switch(pData[playerid][P_CurrentMenu]) {
                    case DELETING:
                        return ShowTextDrawDialog(playerid, DIALOG_LOAD_PROJECT_MENU, 2);
                    case LOADING:
                        return ShowTextDrawDialog(playerid, DIALOG_LOAD_PROJECT_MENU);
                }
                return false;
            }
        }
        
        case (DIALOG_MAIN_EDITION_MENU + 1574): {
            if(response) {
                switch(listitem) {
                    case 0: { // New textdraw
                        pData[playerid][P_CurrentTextdraw] = -1;
                        new i = Iter_Free(zTextList);
                        if(i != ITER_NONE) {
                            ClearTextDraw(i);
                            CreateDefaultTextDraw(i);
                            pData[playerid][P_CurrentTextdraw] = i;
                            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                        }
                        if(pData[playerid][P_CurrentTextdraw] == -1) {
                            ScriptMessage(playerid, "[ZTDE]: You can't create any more textdraws!");
                            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                        } else {
                            new string[128];
                            format(string, sizeof(string), "[ZTDE]: Textdraw #%d successfully created.", pData[playerid][P_CurrentTextdraw]);
                            ScriptMessage(playerid, string);
                        }
                        return true;
                    }
                    case 1: { // Export
                        ShowTextDrawDialog(playerid, DIALOG_EXPORT_TEXTDRAW);
                        return true;
                    }
                    case 2: { // Import
                        ImportTextDraws(playerid);
                        return true;
                    }
                    case 3: { // Close project
                        if(IsPlayerMinID(playerid)) {
                            foreach (new i : zTextList) {
                                ClearTextDraw(i);
                            }
                            Iter_Clear(zTextList);
                            new string[128];
                            format(string, sizeof(string), "[ZTDE]: Project '%s' closed.", CurrentProject);
                            ScriptMessage(playerid, string);
                            strmid(CurrentProject, " ", 128, 128);
                            ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
                        } else {
                            ScriptMessage(playerid, "[ZTDE]: Just the smaller player ID can manage projects. Ask him to open one.");
                            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                        }
                        return true;
                    }
                    default: {
                        if(pData[playerid][P_DialogPage] == 0 && listitem == 4) { // Other options
                            ShowTextDrawDialog(playerid, DIALOG_OTHERS_OPTIONS);
                            return true;
                        }
                        else if(listitem >= (pData[playerid][P_DialogPage] == 0 ? 5 : 4) && listitem <= (pData[playerid][P_DialogPage] == 0 ? 12 : 11)) { // Select TD
                            new id = pData[playerid][P_DialogPage] == 0 ? 5 : 4;
                            for (new i = pData[playerid][P_DialogPage]; i < MAX_TEXTDRAWS; i++) {
                                if(Iter_Contains(zTextList, i) && tData[i][T_Created]) {
                                    if(id == listitem) {
                                        pData[playerid][P_CurrentTextdraw] = i;
                                        ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                                        break;
                                    }
                                    id++;
                                }
                            }
                            new string[128];
                            format(string, sizeof(string), "[ZTDE]: You are now editing textdraw #%d", pData[playerid][P_CurrentTextdraw]);
                            ScriptMessage(playerid, string);
                            return true;
                        }
                        else if(listitem == (pData[playerid][P_DialogPage] == 0 ? 13 : 12)) { // Next button
                            new BiggestID, itemcount;
                            for (new i = pData[playerid][P_DialogPage]; i < MAX_TEXTDRAWS; i++) {
                                if(Iter_Contains(zTextList, i) && tData[i][T_Created]) {
                                    itemcount++;
                                    BiggestID = i;
                                    if(itemcount == 9) break;
                                }
                            }
                            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, BiggestID);
                            return true;
                        }
                        else if(listitem == (pData[playerid][P_DialogPage] == 0 ? 14 : 13)) { // Back button
                            new BiggestID = pData[playerid][P_DialogPage];
                            for (new i; BiggestID < MAX_TEXTDRAWS; BiggestID--) {
                                if(BiggestID <= 0) {
                                    BiggestID = 0;
                                    break;
                                } else if(Iter_Contains(zTextList, BiggestID) && tData[BiggestID][T_Created]) {
                                    i++;
                                    if(i == 9) break;
                                }
                            }
                            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, BiggestID);
                            return true;
                        } else {
                            return false;
                        }
                    }
                }
            } else {
                pData[playerid][P_Editing] = false;
                pData[playerid][P_DialogPage] = 0;
                return true;
            }
        }
        
        case (DIALOG_TEXTDRAW_EDIT_MENU + 1574): { // Main edition menu (OPTIMIZED)
            if(response) {
                switch(listitem) {
                    case 0: { // Change text
                        ShowTextDrawDialog(playerid, DIALOG_ETD_STRING);
                        return true;
                    }
                    case 1: { // Change position
                        ShowTextDrawDialog(playerid, DIALOG_ETD_POSITION);
                        return true;
                    }
                    case 2: { // Change alignment
                        ShowTextDrawDialog(playerid, DIALOG_ETD_ALIGNMENT);
                        return true;
                    }
                    case 3: { // Change font color
                        pData[playerid][P_ColorEdition] = COLOR_TEXT;
                        ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR);
                        return true;
                    }
                    case 4: { // Change font
                        ShowTextDrawDialog(playerid, DIALOG_ETD_FONT);
                        return true;
                    }
                    case 5: { // Change proportionality
                        ShowTextDrawDialog(playerid, DIALOG_ETD_PROPORTIONAL);
                        return true;
                    }
                    case 6: { // Change letter size
                        ShowTextDrawDialog(playerid, DIALOG_ETD_FONTSIZE);
                        return true;
                    }
                    case 7: { // Edit outline
                        ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
                        return true;
                    }
                    case 8: { // Edit box
                        if(tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] == 0) {
                            ShowTextDrawDialog(playerid, DIALOG_ETD_BOX);
                        } else {
                            ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
                        }
                        return true;
                    }
                    case 9: { // Textdraw mode
                        ShowTextDrawDialog(playerid, DIALOG_ETD_MODE);
                        return true;
                    }
                    case 10: { // TextDrawSetSelectable
                        ShowTextDrawDialog(playerid, DIALOG_ETD_SELECTABLE);
                        return true;
                    }
                    case 11: { // PreviewModel
                        ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                        return true;
                    }
                    case 12: { // Duplicate textdraw
                        new from = pData[playerid][P_CurrentTextdraw], to = DuplicateTextdraw(from, true, true);
                        if(to != -1) {
                            pData[playerid][P_CurrentTextdraw] = -1;
                            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                        }
                        else {
                            ScriptMessage(playerid, "[ZTDE]: You can't create any more textdraws!");
                            ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                            return false;
                        }

                        new string[128];
                        format(string, sizeof(string), "[ZTDE]: Textdraw #%d successfully copied to Textdraw #%d.", from, to);
                        ScriptMessage(playerid, string);
                        return true;
                    }
                    case 13: { // Delete textdraw
                        ShowTextDrawDialog(playerid, DIALOG_CONFIRM_DELETE_TEXTDRAW);
                        return true;
                    }
                }
            }
            else {
                ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                return true;
            }
        }
                
        case (DIALOG_CONFIRM_DELETE_PROJECT + 1574): { // Delete project confirmation dialog (OPTIMIZED)
            if(response) {
                new filename[128], filedirectory[256];
                format(filename, sizeof(filename), "%s", GetFileNameFromLst("ztdeditor/tdlist.lst", pData[playerid][P_Aux]));
                format(filedirectory, sizeof(filedirectory), PROJECT_DIRECTORY, filename);
                fremove(filedirectory);
                DeleteLineFromFile("ztdeditor/tdlist.lst", pData[playerid][P_Aux]);
        
                new message[128];
                format(message, sizeof(message), "[ZTDE]: The project saved as '%s' was successfully deleted.", filename);
                ScriptMessage(playerid, message);
        
                ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
            } else {
                ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
            }
            return true;
        }
        
        case (DIALOG_CONFIRM_DELETE_TEXTDRAW + 1574): { // Delete TD confirmation (OPTIMIZED)
            if(response) {
                DeleteTDFromFile(pData[playerid][P_CurrentTextdraw]);
                ClearTextDraw(pData[playerid][P_CurrentTextdraw]);
                Iter_Remove(zTextList, pData[playerid][P_CurrentTextdraw]);

                new message[128];
                format(message, sizeof(message), "[ZTDE]: You have deleted textdraw #%d", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, message);
        
                pData[playerid][P_CurrentTextdraw] = -1;
                ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_STRING + 1574): { // Change textdraw's text (OPTIMIZED)
            if(response) {
                if(!strlen(inputtext)) {
                    return ShowTextDrawDialog(playerid, DIALOG_ETD_STRING);
                }
                else {
                    new tdid = pData[playerid][P_CurrentTextdraw];
                    if(tData[tdid][T_UseBox] || tData[tdid][T_Selectable]){
                        for(new i; i < strlen(inputtext); i++){
                            if(inputtext[i] == ' ')
                                inputtext[i] = '_';
                        }
                    }
                    format(tData[tdid][T_Text], 1024, inputtext);

                    SaveTDData(tdid, "T_Text");
                    UpdateTextdraw(tdid);
                    ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                    return true;
                }
            }
            else
                return ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
        }
        
        case (DIALOG_ETD_POSITION + 1574): { // Change textdraw's position: exact or move (OPTIMIZED)
            if(response) {
                switch(listitem) {
                    case 0: { // Exact position
                        pData[playerid][P_Aux] = 0;
                        ShowTextDrawDialog(playerid, DIALOG_ETD_POSITION2, 0, 0);
                    }
                    case 1: { // Move it
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid)) {
                            format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
                        } else {
                            format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
                        }
                        format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to move. ", string);
        
                        if(!IsPlayerInAnyVehicle(playerid)) {
                            format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
                        } else {
                            format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
                        }
                        format(string, sizeof(string), "%s to finish.~n~", string);
        
                        GameTextForPlayer(playerid, string, 9999999, 3);
                        ScriptMessage(playerid, "[ZTDE]: Use [up], [down], [left] and [right] keys to move the textdraw. [sprint] to boost and [enter car] to finish.");
        
                        TogglePlayerControllable(playerid, false);
                        pData[playerid][P_KeyEdition] = EDIT_POSITION;
                        SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_POSITION2 + 1574): { // Set position manually (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_POSITION2, pData[playerid][P_Aux], 1);
                } else {
                    if(pData[playerid][P_Aux] == 0) { // If editing X
                        tData[pData[playerid][P_CurrentTextdraw]][T_X] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_X");
                        ShowTextDrawDialog(playerid, DIALOG_ETD_POSITION2, 1, 0);
                    } else { // If editing Y
                        tData[pData[playerid][P_CurrentTextdraw]][T_Y] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Y");
                        ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                        ScriptMessage(playerid, "[ZTDE]: Textdraw successfully moved.");
                    }
                }
            } else {
                if(pData[playerid][P_Aux] == 1) { // If he is editing Y, move him to X.
                    pData[playerid][P_Aux] = 0;
                    ShowTextDrawDialog(playerid, DIALOG_ETD_POSITION2, 0, 0);
                } else { // If he was editing X, move him back to select menu
                    ShowTextDrawDialog(playerid, DIALOG_ETD_POSITION);
                }
            }
            return true;
        }
        
        case (DIALOG_ETD_ALIGNMENT + 1574): { // Change textdraw's alignment (OPTIMIZED)
            if(response) {
                new tdid = pData[playerid][P_CurrentTextdraw];
                new align = ( listitem < 1 ? (1) : ( (listitem > 3 ? (3) : (listitem + 1) ) ) );
                tData[tdid][T_Alignment] = align;
                UpdateTextdraw(tdid);
                SaveTDData(tdid, "T_Alignment");
                
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's alignment changed to %d.", tdid, align);
                ScriptMessage(playerid, string);
                
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            else ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            return true;
        }
        
        case (DIALOG_ETD_PROPORTIONAL + 1574): { // Change textdraw's proportionality (OPTIMIZED)
            if(response) {
                new tdid = pData[playerid][P_CurrentTextdraw];
                tData[tdid][T_Proportional] = listitem == 0 ? (true) : (false);
                UpdateTextdraw(tdid);
                SaveTDData(tdid, "T_Proportional");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's proportionality changed to %s.", tdid, (listitem == 0 ? ("ON") : ("OFF")));
                ScriptMessage(playerid, string);
        
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                return true;
            }
            else 
                return ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
        }
        
        case (DIALOG_ETD_COLOR + 1574): { // Change color (OPTIMIZED)
            if(response) {
                switch(listitem) {
                    case 0: { // Write hex
                        return ShowTextDrawDialog(playerid, DIALOG_ETD_HEX_COLOR);
                    }
                    case 1: { // Color combinator
                        return ShowTextDrawDialog(playerid, DIALOG_ETD_RGB_COLOR, 0, 0);
                    }
                    case 2: { // Premade color
                        return ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR_PRESETS);
                    }
                }
                return false;
            }
            else {
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 
                    return ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE) 
                    return ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX) 
                    return ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
                return false;
            }
        }
        
        case (DIALOG_ETD_HEX_COLOR + 1574): { // Textdraw's color: custom hex (OPTIMIZED)
            if(response) {
                new red[3], green[3], blue[3], alpha[3];
                
                if(inputtext[0] == '0' && inputtext[1] == 'x') { // Using 0xFFFFFF format
                    if(strlen(inputtext) != 8 && strlen(inputtext) != 10) return ShowTextDrawDialog(playerid, DIALOG_ETD_HEX_COLOR, 1);
                    else {
                        format(red, sizeof(red), "%c%c", inputtext[2], inputtext[3]);
                        format(green, sizeof(green), "%c%c", inputtext[4], inputtext[5]);
                        format(blue, sizeof(blue), "%c%c", inputtext[6], inputtext[7]);
                        if(inputtext[8] != '\0')
                            format(alpha, sizeof(alpha), "%c%c", inputtext[8], inputtext[9]);
                        else
                            alpha = "FF";
                    }
                }
                else if(inputtext[0] == '#') { // Using #FFFFFF format
                    if(strlen(inputtext) != 7 && strlen(inputtext) != 9) return ShowTextDrawDialog(playerid, DIALOG_ETD_HEX_COLOR, 1);
                    else {
                        format(red, sizeof(red), "%c%c", inputtext[1], inputtext[2]);
                        format(green, sizeof(green), "%c%c", inputtext[3], inputtext[4]);
                        format(blue, sizeof(blue), "%c%c", inputtext[5], inputtext[6]);
                        if(inputtext[7] != '\0')
                            format(alpha, sizeof(alpha), "%c%c", inputtext[7], inputtext[8]);
                        else
                            alpha = "FF";
                    }
                }
                else { // Using FFFFFF format
                    if(strlen(inputtext) != 6 && strlen(inputtext) != 8) return ShowTextDrawDialog(playerid, DIALOG_ETD_HEX_COLOR, 1);
                    else {
                        format(red, sizeof(red), "%c%c", inputtext[0], inputtext[1]);
                        format(green, sizeof(green), "%c%c", inputtext[2], inputtext[3]);
                        format(blue, sizeof(blue), "%c%c", inputtext[4], inputtext[5]);
                        if(inputtext[6] != '\0')
                            format(alpha, sizeof(alpha), "%c%c", inputtext[6], inputtext[7]);
                        else
                            alpha = "FF";
                    }
                }
                
                // Setting the color based on edition type
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                    tData[pData[playerid][P_CurrentTextdraw]][T_Color] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
                    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
                    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                
                // Updating and saving textdraw data
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");
                
                // Sending success message and showing appropriate dialog
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's color has been changed.", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, string);
        
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                    ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
                    ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
                    ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
            }
            else {
                ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR);
            }
            return true;
        }
		
		case (DIALOG_ETD_RGB_COLOR + 1574): { // Textdraw's color: Color combinator (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_RGB_COLOR, pData[playerid][P_Aux], 2);
                } else if(strval(inputtext) < 0 || strval(inputtext) > 255) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_RGB_COLOR, pData[playerid][P_Aux], 1);
                } else {
                    pData[playerid][P_Color][pData[playerid][P_Aux]] = strval(inputtext);
                     
                    if(pData[playerid][P_Aux] == 3) { // Finished editing alpha
                        // Setting the color based on edition type
                        if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                            tData[pData[playerid][P_CurrentTextdraw]][T_Color] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
                                pData[playerid][P_Color][2], pData[playerid][P_Color][3]);
                        else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
                            tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
                                pData[playerid][P_Color][2], pData[playerid][P_Color][3]);
                        else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
                            tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
                                pData[playerid][P_Color][2], pData[playerid][P_Color][3]);
                        // Updating and saving textdraw data
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");
        
                        // Sending success message and showing appropriate dialog
                        new string[128];
                        format(string, sizeof(string), "[ZTDE]: Textdraw #%d's color has been changed.", pData[playerid][P_CurrentTextdraw]);
                        ScriptMessage(playerid, string);
        
                        if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                            ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                        else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
                            ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
                        else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
                            ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
                    } else {
                        pData[playerid][P_Aux] += 1;
                        ShowTextDrawDialog(playerid, DIALOG_ETD_RGB_COLOR, pData[playerid][P_Aux], 0);
                    }
                }
            } else {
                if(pData[playerid][P_Aux] >= 1) { // Editing alpha, blue, etc.
                    pData[playerid][P_Aux] -= 1;
                    ShowTextDrawDialog(playerid, DIALOG_ETD_RGB_COLOR, pData[playerid][P_Aux], 0);
                } else { // Editing red, move back to select color menu
                    ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR);
                }
            }
            return true;
        }
        
        case (DIALOG_ETD_COLOR_PRESETS + 1574): { // Textdraw's color: premade colors (OPTIMIZED)
            if(response) {
                new col;
                switch(listitem) {
                    case 0: col = 0xff0000ff;
                    case 1: col = 0x00ff00ff;
                    case 2: col = 0x0000ffff;
                    case 3: col = 0xffff00ff;
                    case 4: col = 0xff00ffff;
                    case 5: col = 0x00ffffff;
                    case 6: col = 0xffffffff;
                    case 7: col = 0x000000ff;
                }
                // Setting the color based on edition type
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                    tData[pData[playerid][P_CurrentTextdraw]][T_Color] = col;
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
                    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = col;
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
                    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = col;
        
                // Updating and saving textdraw data
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");
        
                // Sending success message and showing appropriate dialog
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's color has been changed.", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, string);
        
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                    ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
                    ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
                    ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
            } else {
                ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR);
            }
            return true;
        }
        
        case (DIALOG_ETD_FONT + 1574): { // Change textdraw's font (OPTIMIZED)
            if(response) {
                tData[pData[playerid][P_CurrentTextdraw]][T_Font] = listitem;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Font");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's font changed to %d.", pData[playerid][P_CurrentTextdraw], listitem);
                ScriptMessage(playerid, string);
                
                // Handling specific font cases
                if(listitem < 5) {
                    if(GetPVarInt(playerid, "Use2DTD") == 1) {
                        DeletePVar(playerid, "Use2DTD");
                    }
                }
                else if(listitem == 4) {
                    ScriptMessage(playerid, "[ZTDE]: To use font 4, you have to active the box.");
                    ScriptMessage(playerid, "[ZTDE]: Change the box size to change TD size.");
                    ScriptMessage(playerid, "[ZTDE]: Function added by irinel1996.");
                }
                else if(listitem == 5) {
                    SetPVarInt(playerid, "Use2DTD", 1);
                    ScriptMessage(playerid, "[ZTDE]: Add by adri1.");
                    ScriptMessage(playerid, "[ZTDE]: Important: Use Box!");
                }
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_FONTSIZE + 1574): { // Change textdraw's letter size: exact or move (OPTIMIZED)
            if(response) {
                switch(listitem) {
                    case 0: { // Exact size
                        pData[playerid][P_Aux] = 0;
                        ShowTextDrawDialog(playerid, DIALOG_ETD_FONTSIZE2, 0, 0);
                    }
                    case 1: { // Resize it
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
                        else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
                        format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to resize. ", string);
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
                        else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
                        format(string, sizeof(string), "%s to finish.~n~", string);
        
                        GameTextForPlayer(playerid, string, 9999999, 3);
                        ScriptMessage(playerid, "[ZTDE]: Use [up], [down], [left] and [right] keys to resize the textdraw. [sprint] to boost and [enter car] to finish.");
        
                        TogglePlayerControllable(playerid, false);
                        pData[playerid][P_KeyEdition] = EDIT_SIZE;
                        SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_FONTSIZE2 + 1574): { // Change letter size manually (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_FONTSIZE2, pData[playerid][P_Aux], 1);
                } else {
                    if(pData[playerid][P_Aux] == 0) { // If he edited X 
                        tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_XSize");
                        ShowTextDrawDialog(playerid, DIALOG_ETD_FONTSIZE2, 1, 0);
                    } else if(pData[playerid][P_Aux] == 1) { // If he edited Y
                        tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_YSize");
                        ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
        
                        ScriptMessage(playerid, "[ZTDE]: Textdraw successfully resized.");
                    }
                }
            } else {
                if(pData[playerid][P_Aux] == 1) { // If he is editing Y, move him to X.
                    pData[playerid][P_Aux] = 0;
                    ShowTextDrawDialog(playerid, DIALOG_ETD_FONTSIZE2, 0, 0);
                } else { // If he was editing X, move him back to select menu
                    ShowTextDrawDialog(playerid, DIALOG_ETD_FONTSIZE);
                }
            }
            return true;
        }
        
        case (DIALOG_ETD_OUTLINE + 1574): { // main outline menu (OPTIMIZED)
            if(response){
                switch(listitem){
                    case 0: { // Toggle outline
                        tData[pData[playerid][P_CurrentTextdraw]][T_Outline] = !tData[pData[playerid][P_CurrentTextdraw]][T_Outline];
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Outline");
                        ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
                        
                        ScriptMessage(playerid, "[ZTDE]: Textdraw's outline toggled.");
                    }
                    case 1: { // Change shadow
                        ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE_SHADOW);
                    }
                    case 2: { // Change color
                        pData[playerid][P_ColorEdition] = COLOR_OUTLINE;
                        ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR);
                    }
                    case 3: { // Finish
                        ScriptMessage(playerid, "[ZTDE]: Finished outline customization.");
                        ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                    }
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_OUTLINE_SHADOW + 1574): { // Outline shadow (OPTIMIZED)
            if(response) {
                if(listitem == 6) { // selected custom
                    ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE_SHADOW_SIZE);
                } else {
                    tData[pData[playerid][P_CurrentTextdraw]][T_Shadow] = listitem;
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Shadow");
                    ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
        
                    new string[128];
                    format(string, sizeof(string), "[ZTDE]: Textdraw #%d's outline shadow changed to %d.", pData[playerid][P_CurrentTextdraw], listitem);
                    ScriptMessage(playerid, string);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
            }
            return true;
        }
        
        case (DIALOG_ETD_OUTLINE_SHADOW_SIZE + 1574): { // outline shadow customized (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE_SHADOW_SIZE, 1);
                } else {
                    tData[pData[playerid][P_CurrentTextdraw]][T_Shadow] = strval(inputtext);
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Shadow");
                    ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE);
        
                    new string[128];
                    format(string, sizeof(string), "[ZTDE]: Textdraw #%d's outline shadow changed to %d.", pData[playerid][P_CurrentTextdraw], strval(inputtext));
                    ScriptMessage(playerid, string);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_ETD_OUTLINE_SHADOW);
            }
            return true;
        }
        
        case (DIALOG_ETD_BOX + 1574): { // Box on - off (OPTIMIZED)
            if(response) {
                if(listitem == 0) { // Turned box on
                    tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 1;
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");
        
                    ScriptMessage(playerid, "[ZTDE]: Textdraw box enabled. Proceeding with edition...");
        
                    ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
                } else if(listitem == 1) { // He disabled it, nothing more to edit.
                    tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 0;
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");
        
                    ScriptMessage(playerid, "[ZTDE]: Textdraw box disabled.");
        
                    ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_BOX2 + 1574): { // IMPORTANT Box main menu (OPTIMIZED)
            if(response) {
                if(listitem == 0) { // Turned box off
                    tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 0;
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");
        
                    ScriptMessage(playerid, "[ZTDE]: Textdraw box disabled.");
        
                    ShowTextDrawDialog(playerid, DIALOG_ETD_BOX);
                } else if(listitem == 1) { // box size
                    new string[512];
                    string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                    if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
                    else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
                    format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to resize. ", string);
                    if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
                    else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
                    format(string, sizeof(string), "%s to finish.~n~", string);
        
                    GameTextForPlayer(playerid, string, 9999999, 3);
                    ScriptMessage(playerid, "[ZTDE]: Use [up], [down], [left] and [right] keys to resize the box. [sprint] to boost and [enter car] to finish.");
        
                    TogglePlayerControllable(playerid, false);
                    pData[playerid][P_KeyEdition] = EDIT_BOX;
                    SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                } else if(listitem == 2) { // box color
                    pData[playerid][P_ColorEdition] = COLOR_BOX;
                    ShowTextDrawDialog(playerid, DIALOG_ETD_COLOR);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_SELECTABLE + 1574): { // Change textdraw's selectable (OPTIMIZED)
            if(response) {
                tData[pData[playerid][P_CurrentTextdraw]][T_Selectable] = 1;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Selectable");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's can selectable ON.", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, string);
            } else {
                tData[pData[playerid][P_CurrentTextdraw]][T_Selectable] = 0;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Selectable");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's can selectable OFF.", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, string);
            }
            ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            return true;
        }

        case (DIALOG_ETD_PREVIEW_MODEL_OPT + 1574): { // Preview model (OPTIMIZED)
            // Model Index\nRot X\nRot Y\nRot Z\nZoom
            if(response) {
                switch(listitem) {
                    case 0: ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_INDEX);
                    case 1: ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_RX);
                    case 2: ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_RY);
                    case 3: ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_RZ);
                    case 4: ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_ZOOM);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        case (DIALOG_ETD_PREVIEW_MODEL_INDEX + 1574): { // Model Index (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                    return false;
                }
                tData[pData[playerid][P_CurrentTextdraw]][T_PreviewModel] = strval(inputtext);
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_PreviewModel");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's changed Preview Model to \"%d\".", pData[playerid][P_CurrentTextdraw], strval(inputtext));
                ScriptMessage(playerid, string);
            }
            ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
            return true;
        }
        case (DIALOG_ETD_PREVIEW_MODEL_RX + 1574): { // Rot X (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                    return false;
                }
                tData[pData[playerid][P_CurrentTextdraw]][PMRotX] = floatstr(inputtext);
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "PMRotX");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's changed Preview Model RX to \"%f\".", pData[playerid][P_CurrentTextdraw], floatstr(inputtext));
                ScriptMessage(playerid, string);
                ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                return true;
            }
            ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
            return false;
        }
        case (DIALOG_ETD_PREVIEW_MODEL_RY + 1574): { // Rot Y (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                    return false;
                }
                tData[pData[playerid][P_CurrentTextdraw]][PMRotY] = floatstr(inputtext);
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "PMRotY");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's changed Preview Model RY to \"%f\".", pData[playerid][P_CurrentTextdraw], floatstr(inputtext));
                ScriptMessage(playerid, string);
                ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                return true;
            }
            ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
            return false;
        }
        case (DIALOG_ETD_PREVIEW_MODEL_RZ + 1574): { // Rot Z (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                    return false;
                }
                tData[pData[playerid][P_CurrentTextdraw]][PMRotZ] = floatstr(inputtext);
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "PMRotZ");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's changed Preview Model RZ to \"%f\".", pData[playerid][P_CurrentTextdraw], floatstr(inputtext));
                ScriptMessage(playerid, string);
                ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                return true;
            }
            ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
            return false;
        }
        case (DIALOG_ETD_PREVIEW_MODEL_ZOOM + 1574): { // Zoom (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) {
                    ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                    return false;
                }
                else {
                    tData[pData[playerid][P_CurrentTextdraw]][PMZoom] = floatstr(inputtext);
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "PMZoom");
        
                    new string[128];
                    format(string, sizeof(string), "[ZTDE]: Textdraw #%d's changed Preview Model Zoom to \"%f\".", pData[playerid][P_CurrentTextdraw], floatstr(inputtext));
                    ScriptMessage(playerid, string);
                    ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                    return true;
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_ETD_PREVIEW_MODEL_OPT);
                return false;
            }
        }
        
        case (DIALOG_EXPORT_TEXTDRAW + 1574): { // Export menu (OPTIMIZED)
            if(response) {
                switch(listitem) {
                    case 0: // classic mode
                        ExportProject(playerid, 0);
                    case 1: // self-working fs
                        ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_OPTIONS);
                    case 2: // PlayerTextDraw [ADD BY ADRI1]
                        ExportProject(playerid, 7);
                    case 3: // Mixed mode (By ForT)
                        ExportProject(playerid, 8);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
            }
            return true;
        }
        
        case (DIALOG_EXPORT_FSCRIPT_OPTIONS + 1574): { // Export to self working filterscript (OPTIMIZED)
            if(response) {
                switch(listitem) {
                    case 0: // Show all the time.
                        ExportProject(playerid, 1);
                    case 1: // Show on class selection.
                        ExportProject(playerid, 2);
                    case 2: // Show while in vehicle
                        ExportProject(playerid, 3);
                    case 3: // Show with command
                        ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_COMMAND);
                    case 4: // Show automatly repeteadly after some time
                        ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_INTERVAL);
                    case 5: // Show after player killed someone
                        ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DELAYKILL);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_EXPORT_TEXTDRAW);
            }
            return true;
        }
        
        case (DIALOG_EXPORT_FSCRIPT_COMMAND + 1574): { // Write command for export (OPTIMIZED)
            if(response) {
                if(!strlen(inputtext)) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_COMMAND);
                else {
                    if(inputtext[0] != '/')
                        format(pData[playerid][P_ExpCommand], 128, "/%s", inputtext);
                    else
                        format(pData[playerid][P_ExpCommand], 128, "%s", inputtext);
        
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DURATION);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_OPTIONS);
            }
            return true;
        }
		
	    case (DIALOG_EXPORT_FSCRIPT_DURATION + 1574): { // Time after command for export (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DURATION);
                else if(strval(inputtext) < 0) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DURATION);
                else {
                    pData[playerid][P_Aux] = strval(inputtext);
                    ExportProject(playerid, 4);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_COMMAND);
            }
            return true;
        }
        
        case (DIALOG_EXPORT_FSCRIPT_INTERVAL + 1574): { // Write time in secs to appear for export (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_INTERVAL);
                else if(strval(inputtext) < 0) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_INTERVAL);
                else {
                    pData[playerid][P_Aux] = strval(inputtext);
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DELAY);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_OPTIONS);
            }
            return true;
        }
        
        case (DIALOG_EXPORT_FSCRIPT_DELAY + 1574): { // Time after appeared to disappear for export (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DELAY);
                else if(strval(inputtext) < 0) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DELAY);
                else {
                    pData[playerid][P_Aux2] = strval(inputtext);
                    ExportProject(playerid, 5);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_INTERVAL);
            }
            return true;
        }
        
        case (DIALOG_EXPORT_FSCRIPT_DELAYKILL + 1574): { // Time after appeared to disappear when killed for export (OPTIMIZED)
            if(response) {
                if(!IsNumeric2(inputtext)) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DELAYKILL);
                else if(strval(inputtext) < 0) 
                    ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_DELAYKILL);
                else {
                    pData[playerid][P_Aux] = strval(inputtext);
                    ExportProject(playerid, 6);
                }
            } else {
                ShowTextDrawDialog(playerid, DIALOG_EXPORT_FSCRIPT_OPTIONS);
            }
            return true;
        }
        
        case (DIALOG_ETD_MODE + 1574): { // Change textdraw's mode (OPTIMIZED)
            if(response) {
                tData[pData[playerid][P_CurrentTextdraw]][T_Mode] = 0;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Mode");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's mode is GLOBAL.", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, string);
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            } else {
                tData[pData[playerid][P_CurrentTextdraw]][T_Mode] = 1;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Mode");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's mode is PLAYER", pData[playerid][P_CurrentTextdraw]);
                ScriptMessage(playerid, string);
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            }
            return true;
        }
        
        //By BitSain
        case (DIALOG_OTHERS_OPTIONS + 1574): { // Others Options (OPTIMIZED)
            if(!response){
                ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                return true;
            }
        
            switch(listitem){
                case 0:{ // Set All TextDraws in mode
                    ShowTextDrawDialog(playerid, DIALOG_SET_ALL_TEXTDRAWS_MODE);
                    return true;
                } 

                case 1: { // Reorder All TextDraws ID
                    if(Iter_Count(zTextList) < 2)
                        return ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);

                    pData[playerid][P_ReorderingIDs] = true;
                
                    new TextDrawIDs[MAX_TEXTDRAWS];
                    new idx = 0;
                
                    // Collect all TextDraw IDs
                    foreach(new i : zTextList) {
                        if(i <= 0) continue;
                        TextDrawIDs[idx++] = i;
                    }
                
                    // Implement insertion sort
                    for(new i = 1; i < idx; i++) {
                        new key = TextDrawIDs[i];
                        new j = i - 1;
                        while(j >= 0 && TextDrawIDs[j] > key) {
                            TextDrawIDs[j + 1] = TextDrawIDs[j];
                            j = j - 1;
                        }
                        TextDrawIDs[j + 1] = key;
                    }
                
                    // Reorder the IDs
                    for(new j = 0; j < idx; j++) {
                        new emptySlot = j + 1;
                        if(TextDrawIDs[j] != emptySlot) {
                            if(DuplicateTextdraw(TextDrawIDs[j], false, false, emptySlot) != -1){
                                DeleteTDFromFile(TextDrawIDs[j]);
                                ClearTextDraw(TextDrawIDs[j]);
                                Iter_Remove(zTextList, TextDrawIDs[j]);
                            }
                        }
                    }
                
                    SaveAllTextDraws();
                    UpdateAllTextDraws();
                    ScriptMessage(playerid, "[ZTDE]: The ID of all TextDraws were reordered.");
                    pData[playerid][P_ReorderingIDs] = false;
                    ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
                    return true;
                }
                
                #if ZTDE_EXPERIMENTAL == true

                    case 2: { // Move All TextDraws
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid)) {
                            format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
                        } else {
                            format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
                        }
                        format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to move. ", string);
        
                        if(!IsPlayerInAnyVehicle(playerid)) {
                            format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
                        } else {
                            format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
                        }
                        format(string, sizeof(string), "%s to finish.~n~", string);
        
                        GameTextForPlayer(playerid, string, 9999999, 3);
                        ScriptMessage(playerid, "[ZTDE]: Use [up], [down], [left] and [right] keys to move all textdraws [sprint] to boost and [enter car] to finish.");
        
                        TogglePlayerControllable(playerid, false);
                        pData[playerid][P_KeyEdition] = EDIT_ALL_TD_POSITION;
                        SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                        return true;
                    } 

                    case 3: { // Resize All Textdraws (NOT USE!!!!!!! BUG)
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid)) format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
                        else    format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
                        format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to resize. ", string);
                        if(!IsPlayerInAnyVehicle(playerid)) format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
                        else    format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
                        format(string, sizeof(string), "%s to finish.~n~", string);

                        GameTextForPlayer(playerid, string, 9999999, 3);
                        ScriptMessage(playerid, "[ZTDE]: Use [up], [down], [left] and [right] keys to resize all textdraws. [sprint] to boost and [enter car] to finish.");

                        TogglePlayerControllable(playerid, false);
                        pData[playerid][P_KeyEdition] = EDIT_ALL_TD_SIZE;
                        SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }

                #endif

                default:
                    return false;
            }
           
        }
        case (DIALOG_SET_ALL_TEXTDRAWS_MODE + 1574): { // Set All TextDraws in Mode (OPTIMIZED)
            if(!response){
                ShowTextDrawDialog(playerid, DIALOG_OTHERS_OPTIONS);
                return true;
            }
        
            switch(listitem){
                case 0:{ //Type Global
                    foreach(new i : zTextList) {
                        if(Iter_Contains(zTextList, i) && tData[i][T_Created]) {
                            tData[i][T_Mode] = 0;
                            SaveTDData(i, "T_Mode");
                        }
                    }
                    ScriptMessage(playerid, "[ZTDE]: All TextDraws were set to global mode.");
                }
                case 1:{ //Type Player
                    foreach(new i : zTextList) {
                        if(Iter_Contains(zTextList, i) && tData[i][T_Created]) {
                            tData[i][T_Mode] = 1;
                            SaveTDData(i, "T_Mode");
                        }
                    }
                    ScriptMessage(playerid, "[ZTDE]: All TextDraws were set to player mode.");
                }
            }
            ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
            return true;
        }
    }
	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(pData[playerid][P_KeyEdition] != EDIT_NONE && newkeys == KEY_SECONDARY_ATTACK) {
        GameTextForPlayer(playerid, " ", 100, 3);
        TogglePlayerControllable(playerid, true);

        new string[128];
        switch(pData[playerid][P_KeyEdition]) {
            #if ZTDE_EXPERIMENTAL == true
                case EDIT_POSITION: {
                    format(string, sizeof(string), "[ZTDE]: Textdraw #%d successfully moved.", pData[playerid][P_CurrentTextdraw]);
                }
                case EDIT_ALL_TD_POSITION: {
                    format(string, sizeof(string), "[ZTDE]: All Textdraw successfully moved. (%d tdid's)", Iter_Count(zTextList));
                    UpdateAllTextDraws();
                    SaveAllTextDraws();
                }
            #endif
            case EDIT_SIZE: {
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d successfully resized.", pData[playerid][P_CurrentTextdraw]);
            }
            case EDIT_BOX: {
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's box successfully resized.", pData[playerid][P_CurrentTextdraw]);
                SetTimerEx("ShowTextDrawDialogEx", 500, false, "ii", playerid, DIALOG_ETD_BOX2);
            }
        }
        if(pData[playerid][P_KeyEdition] != EDIT_BOX) {
            SetTimerEx("ShowTextDrawDialogEx", 500, false, "ii", playerid, DIALOG_TEXTDRAW_EDIT_MENU);
        }
        ScriptMessage(playerid, string);
        pData[playerid][P_KeyEdition] = EDIT_NONE;
    }
    return true;
}

// =============================================================================
// 					->				Functions
// =============================================================================
stock IsProjectFile(const filename[]) { //By BitSain
    new ending[5];
    strmid(ending, filename, strlen(filename) - 4, strlen(filename));
    return (strcmp(ending, ".tde") == 0);
}

stock LoadProject(playerid, const filename[]) {
    /*  Loads a project for edition.
        @filename[]:            Filename where the project is currently saved.
    */
    new string[128], filedirectory[256];
    format(filedirectory, sizeof(filedirectory), PROJECT_DIRECTORY, filename);
    
    if(!dini_Isset(filedirectory, "TDFile")) {
        #if ZTDE_DEBUG == true

            SendClientMessage(playerid, 0xFF0000FF, sprintf("[ZTDE-ERROR]: {FFFFFF}%s", filedirectory));
        #endif

        ScriptMessage(playerid, "[ZTDE]: Invalid textdraw file.");
        ShowTextDrawDialog(playerid, DIALOG_SELECT_PROJECT);
        return false;
    }
    else {
        Iter_Clear(zTextList);

        for(new i; i < MAX_TEXTDRAWS; i ++) {
            format(string, sizeof(string), "%dT_Created", i);
            if(dini_Isset(filedirectory, string)) {
                if(Iter_Contains(zTextList, i)) {
                    printf("[ZTDE-ERROR]: (LoadProject) tdid %d already exists.", i);
                    continue;
                }

                CreateDefaultTextDraw(i, false, false); // Create but don't save.

                format(string, sizeof(string), "%dT_Text", i);
                if(dini_Isset(filedirectory, string))
                    format(tData[i][T_Text], 1536, dini_Get(filedirectory, string));

                format(string, sizeof(string), "%dT_X", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_X] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dT_Y", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Y] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dT_Alignment", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Alignment] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_BackColor", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_BackColor] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_UseBox", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_UseBox] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_BoxColor", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_BoxColor] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_TextSizeX", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_TextSize][0] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dT_TextSizeY", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_TextSize][1] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dT_Color", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Color] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_Font", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Font] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_XSize", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Size][0] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dT_YSize", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Size][1] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dT_Outline", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Outline] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_Proportional", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Proportional] = dini_Bool(filedirectory, string);

                format(string, sizeof(string), "%dT_Shadow", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Shadow] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dT_Selectable", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Selectable] = dini_Int(filedirectory, string);
                    
                format(string, sizeof(string), "%dT_Mode", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Mode] = dini_Int(filedirectory, string);
                    
                format(string, sizeof(string), "%dT_PreviewModel", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_PreviewModel] = dini_Int(filedirectory, string);

                format(string, sizeof(string), "%dPMRotX", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][PMRotX] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dPMRotY", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][PMRotY] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dPMRotZ", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][PMRotZ] = dini_Float(filedirectory, string);

                format(string, sizeof(string), "%dPMZoom", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][PMZoom] = dini_Float(filedirectory, string);
            }
        }

        UpdateAllTextDraws();

        strmid(CurrentProject, filename, 0, strlen(filename), 128);
        printf("[DEBUG ZTDE]: Current Project: %s", CurrentProject);
        ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU);
        return true;
    }
}

stock CreateDialogTitle(playerid, const text[]) {
    /*	Creates a default title for the dialogs.
        @playerid:      ID of the player getting his dialog title generated.
	    @text[]:	    Text to be attached to the title.
	*/
	#pragma unused playerid
	
	new string[128];
	if(!strlen(CurrentProject) || !strcmp(CurrentProject, " "))
		format(string, sizeof(string), "ZTDEditor: %s", text);
	else
	    format(string, sizeof(string), "%s - ZTDEditor: %s", CurrentProject, text);
	return string;
}

stock CreateNewProject(const name[]) {
    /*	Creates a new .tde project file.
	    @name[]:		Name to be used in the filename.
	*/

	new string[128], File:File, filedirectory[256];

	// Add it to the list.
	format(string, sizeof(string), "%s\r\n", name);
	File = fopen("ztdeditor/tdlist.lst", io_append);
	fwrite(File, string);
	fclose(File);

	// Create the default file.
    format(filedirectory, sizeof(filedirectory), PROJECT_DIRECTORY, name);
	File = fopen(filedirectory, io_write);
	fwrite(File, "TDFile=yes");
	fclose(File);
}

stock ShowTextDrawDialog(playerid, dialogid, aux = 0, aux2 = 0){
    /*	Shows a specific dialog for a specific player
	    @playerid:      ID of the player to show the dialog to.
	    @dialogid:      ID of the dialog to show.
	    @aux:           Auxiliary variable. Works to make variations of certain dialogs.
	    @aux2:          Auxiliary variable. Works to make variations of certain dialogs.

	    -Returns:
	    true on success, false on fail.
	*/

	switch(dialogid) {
	    case DIALOG_SELECT_PROJECT: { // Select project.
            new info[256];
		    format(info, sizeof(info), "%sNew Project\n", info);
		    format(info, sizeof(info), "%sLoad Project\n", info);
		    format(info, sizeof(info), "%sDelete Project", info);
		    ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Startup"), info, "Accept", "Cancel");
		    return true;
	    }
	    
	    case DIALOG_NEW_PROJECT_FILENAME: {
	        new info[256];
	        if(!aux)	info = "Write the name of the new project file.\n";
	        else if(aux == 1) info = "ERROR: The name is too long, please try again.\n";
	        else if(aux == 2) info = "ERROR: That filename already exists, try again.\n";
	        else if(aux == 3) info = "ERROR: That file name contains ilegal characters. You aren't allowed to\ncreate subdirectories. Please try again.";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "New project"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_LOAD_PROJECT_MENU: {
            // Store in a var if he's deleting or loading.
            if(aux == 2) {
                pData[playerid][P_CurrentMenu] = DELETING;
            } else {
                pData[playerid][P_CurrentMenu] = LOADING;
            }
            
            new info[2048];
            if(fexist("ztdeditor/tdlist.lst")) {
                if(aux != 2) {
                    format(info, sizeof(info), "Custom filename...");
                } else {
                    format(info, sizeof(info), "<< Go back");
                }
        
                new File:tdlist = fopen("ztdeditor/tdlist.lst", io_read);
                if(tdlist) {
                    new line[128];
                    while(fread(tdlist, line)) {
                        // Remove extra newline at the end of the line
                        line[strlen(line) - 1] = EOS;
                        strcat(info, "\n", sizeof(info));
                        strcat(info, line, sizeof(info));
                    }
        
                    fclose(tdlist);
                }
        
                ShowPlayerDialog(playerid, dialogid + 1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Load project"), info, "Accept", "Go back");
            } else {
                if(aux) {
                    format(info, sizeof(info), "%sCan't find tdlist.lst.\n", info);
                }
                format(info, sizeof(info), "%sWrite manually the name of the project file you want\n", info);
                if(aux != 2) {
                    format(info, sizeof(info), "%sto open:\n", info);
                    ShowPlayerDialog(playerid, dialogid + 1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Load project"), info, "Accept", "Go back");
                } else {
                    format(info, sizeof(info), "%sto delete:\n", info);
                    ShowPlayerDialog(playerid, dialogid + 1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Delete project"), info, "Accept", "Go back");
                }
            }
            return true;
        }
	    
	    case DIALOG_LOAD_PROJECT_FILENAME: {
			ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Load project"), \
		 		"Write manually the name of the project file\n you want to load:\n", "Accept", "Go back");
			return true;
	    }
	    
	    case DIALOG_MAIN_EDITION_MENU: { // Main edition menu (shows all the textdraws and lets you create a new one).
	        new info[1024 + 64], 
	        	shown = 0;
	        format(info, sizeof(info), "%sCreate new Textdraw", info);
	        shown ++;
	        format(info, sizeof(info), "%s\nExport project", info);
	        shown ++;
            format(info, sizeof(info), "%s\nImport project", info);
            shown ++;
	        format(info, sizeof(info), "%s\nClose project", info);
	        shown ++;
            if(aux == 0) format(info, sizeof(info), "%s\nOthers Options", info), shown++;
	        // Aux here is used to indicate from which TD show the list from.
	        pData[playerid][P_DialogPage] = aux;
	        
            foreach(new i : zTextList) {
                if i < aux *then continue;

	            if(Iter_Contains(zTextList, i) && tData[i][T_Created]) {
	                shown ++;
					if((shown == 13 && aux != 0) || (shown == 14 && aux == 0)) {
                        format(info, sizeof(info), "%s\nNext >>", info);
                        if(aux != 0) format(info, sizeof(info), "%s\n<< Back", info);
						break;
					}
					
	                new PieceOfText[PREVIEW_CHARS];
	                if(strlen(tData[i][T_Text]) > sizeof(PieceOfText)) {
	                    strmid(PieceOfText, tData[i][T_Text], 0, PREVIEW_CHARS, PREVIEW_CHARS);
	                    format(info, sizeof(info), "%s\nTDraw %d: '%s [...]'", info, i, PieceOfText);
	                }
					else {
					    format(info, sizeof(info), "%s\nTDraw %d: '%s'", info, i, tData[i][T_Text]);
					}
	            }
	        }
            if(shown == 4) // None TD && Dialog page != 0 (shown = 5: others options of dialog page 0.)
                return ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, --aux);

	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw selection"), info, "Accept", "Cancel");
	        return true;
	    }
	    
	    case DIALOG_TEXTDRAW_EDIT_MENU: {
	        new p_current = pData[playerid][P_CurrentTextdraw];
	    
	        new info[1024];
	        format(info, sizeof(info), "%sChange text string\n", info);
	        format(info, sizeof(info), "%sChange position\n", info);
	        format(info, sizeof(info), "%sChange alignment\n", info);
	        format(info, sizeof(info), "%sChange text color\n", info);
	        format(info, sizeof(info), "%sChange font\n", info);
	        format(info, sizeof(info), "%sChange proportionality\n", info);
	        format(info, sizeof(info), "%sChange font size\n", info);
	        format(info, sizeof(info), "%sEdit outline\n", info);
	        format(info, sizeof(info), "%sEdit box\n", info);
	        format(info, sizeof(info), "%sCurrent mode: %s\n", info, tData[p_current][T_Mode] == 0 ? ("{00AAFF}GLOBAL") : ("{00AAFF}PLAYER"));
	        format(info, sizeof(info), "%sTextDraw can selectable...\n", info);
	        format(info, sizeof(info), "%sPreview Model options...\n", info);
	        format(info, sizeof(info), "%sDuplicate Textdraw...\n", info);
	        format(info, sizeof(info), "%sDelete Textdraw...\n", info);
	        
	        new title[40];
	        format(title, sizeof(title), "TextDraw %d", p_current);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, title), info, "Accept", "Cancel");
	        return true;
	    }
	    
	    case DIALOG_CONFIRM_DELETE_PROJECT: {
	        new info[256];
	        format(info, sizeof(info), "%sAre you sure you want to delete the\n", info);
	        format(info, sizeof(info), "%s%s project?\n\n", info, GetFileNameFromLst("ztdeditor/tdlist.lst", pData[playerid][P_Aux]));
	        format(info, sizeof(info), "%sWARNING: There is no way to undo this operation.", info);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Confirm deletion"), info, "Yes", "No");
	        return true;
	    }
	    
	    case DIALOG_CONFIRM_DELETE_TEXTDRAW: {
	        new info[256];
	        format(info, sizeof(info), "%sAre you sure you want to delete the\n", info);
	        format(info, sizeof(info), "%sTextdraw number %d?\n\n", info, pData[playerid][P_CurrentTextdraw]);
	        format(info, sizeof(info), "%sWARNING: There is no way to undo this operation.", info);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Confirm deletion"), info, "Yes", "No");
	        return true;
	    }
	    
	    case DIALOG_ETD_STRING: {
	        new info[1024];
	        info = "Write the new textdraw's text.\nUse ~n~ to break lines!\nThe current text is:\n\n";
	        format(info, sizeof(info), "%s%s\n\n", info, tData[pData[playerid][P_CurrentTextdraw]][T_Text]);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's string"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_POSITION: {
	        new info[256];
	        info = "Write exact position\nMove the Textdraw";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's position"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_POSITION2: {
	        // aux is 0 for X, 1 for Y.
	        // aux2 is the type of error message. 0 for no error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: You have to write a number.\n\n";
	        
	        format(info, sizeof(info), "%sWrite in numbers the new exact ", info);
	        if(aux == 0) format(info, sizeof(info), "%sX", info);
	        else if(aux == 1) format(info, sizeof(info), "%sY", info);
         	format(info, sizeof(info), "%s position of the Textdraw\n", info);
         	
        	pData[playerid][P_Aux] = aux; // To know if he's editing X or Y.
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's position"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_ALIGNMENT: {
	        new info[256];
	        info = "Left (type 1)\nCentered (type 2)\nRight (type 3)";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's alignment"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_PROPORTIONAL: {
	        new info[256];
	        info = "Proportionality On\nProportionality Off";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's proportionality"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_COLOR: {
	        new info[256];
	        info = "Write an hexadecimal number\nUse color combinator\nSelect a premade color";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_HEX_COLOR: {
	        new info[256];
	        if(aux) info = "ERROR: You have written an invalid hex number.\n\n";
	        format(info, sizeof(info), "%sWrite the hexadecimal number you want:\n", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_RGB_COLOR: {
	        // aux is 0 for red, 1 for green, 2 for blue, and 3 for alpha.
	        // aux2 is the type of error message. 0 for no error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: The number range has to be between 0 and 255.\n\n";
	        else if(aux2 == 2) info = "ERROR: You have to write a number.\n\n";

	        format(info, sizeof(info), "%sWrite the amount of ", info);
	        if(aux == 0) format(info, sizeof(info), "%sRED", info);
	        else if(aux == 1) format(info, sizeof(info), "%sGREEN", info);
	        else if(aux == 2) format(info, sizeof(info), "%sBLUE", info);
	        else if(aux == 3) format(info, sizeof(info), "%sOPACITY", info);
         	format(info, sizeof(info), "%s you want.\n", info);
         	format(info, sizeof(info), "%sThe number has to be in a range between 0 and 255.", info);

        	pData[playerid][P_Aux] = aux; // To know what color he's editing.
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_COLOR_PRESETS: {
	        new info[256];
	        info = "Red\nGreen\nBlue\nYellow\nPink\nLight Blue\nWhite\nBlack";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_FONT: {
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's font"), "Font type 0\nFont type 1\nFont type 2\nFont type 3\nFont type 4\nFont 5 (( TEXT_DRAW_FONT_MODEL_PREVIEW ))", "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_FONTSIZE: {
	        new info[256];
	        info = "Write exact size\n";
	        format(info, sizeof(info), "%sResize the Textdraw", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's font size"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_FONTSIZE2: {
	        // aux is 0 for X, 1 for Y.
	        // aux2 is the type of error message. 0 for no error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: You have to write a number.\n\n";

	        format(info, sizeof(info), "%sWrite in numbers the new exact ", info);
	        if(aux == 0) format(info, sizeof(info), "%sX", info);
	        else if(aux == 1) format(info, sizeof(info), "%sY", info);
         	format(info, sizeof(info), "%s lenght of the font letters.\n", info);

        	pData[playerid][P_Aux] = aux; // To know if he's editing X or Y.
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's size"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_OUTLINE: {
	        new info[256];
	        if(tData[pData[playerid][P_CurrentTextdraw]][T_Outline] == 1)	info = "Outline Off";
	        else info = "Outline On";
	        format(info, sizeof(info), "%s\nShadow size\nOutline/Shadow color\nFinish outline edition...", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's outline"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_OUTLINE_SHADOW: {
	        new info[256];
	        info = "Outline shadow 0\nOutline shadow 1\nOutline shadow 2\nOutline shadow 3\nOutline shadow 4\nOutline shadow 5\nCustom...";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's outline shadow"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_OUTLINE_SHADOW_SIZE: {
	        new info[256];
	        if(aux) info = "ERROR: You have written an invalid number.\n\n";
	        format(info, sizeof(info), "%sWrite a number indicating the size of the shadow:\n", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's outline shadow"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_BOX: {
	        new info[256];
	        info = "Box On\nBox Off";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's box"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_ETD_BOX2: {
	        new info[256];
	        info = "Box Off\nBox size\nBox color";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's box"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_EXPORT_TEXTDRAW: {
	        new info[256];
	        info = "Classic export mode\nSelf-working filterscript\nPlayerTextDraw\nMixed export mode";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_EXPORT_FSCRIPT_OPTIONS: {
	        new info[512];
	        info = "FScript: Show textdraw all the time\nFScript: Show textdraw on class selection\nFScript: Show textdraw while in vehicle\n\
					FScript: Show textdraw with command\nFScript: Show every X amount of time\nFScript: Show after killing someone";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_EXPORT_FSCRIPT_COMMAND: {
	        new info[128];
	        info = "Write the command you want to show the textdraw.\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_EXPORT_FSCRIPT_DURATION: {
	        new info[128];
	        info = "How long (IN SECONDS) will it remain in the screen?\n";
	        format(info, sizeof(info), "%sWrite 0 if you want to hide it by typing the command again.\n", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_EXPORT_FSCRIPT_INTERVAL: {
	        new info[128];
	        info = "Every how long do you want that the textdraws appear?\nWrite a time in SECONDS:\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }

	    case DIALOG_EXPORT_FSCRIPT_DELAY: {
	        new info[128];
	        info = "Once it appeared, how long will it remain on the screen?\nWrite a time in SECONDS:\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case DIALOG_EXPORT_FSCRIPT_DELAYKILL: {
	        new info[128];
	        info = "Once it appeared, how long will it remain on the screen?\nWrite a time in SECONDS:\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    case DIALOG_ETD_SELECTABLE: {
	        new info[1024];
	        format(info, sizeof(info), "Selectable TextDraw. The current selectable is: %d\n",tData[pData[playerid][P_CurrentTextdraw]][T_Selectable]);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Textdraw's selectable"), info, "Select ON", "Select OFF");
	        return true;
	    }
	    case DIALOG_ETD_PREVIEW_MODEL_OPT: {
	        if(GetPVarInt(playerid, "Use2DTD") == 1) {
				ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's Preview Model Options"), "Model Index\nRot X\nRot Y\nRot Z\nZoom", "Accept", "Cancel");
			}
	        else if(!GetPVarInt(playerid, "Use2DTD")) {
				ScriptMessage(playerid, "[ZTDE]: Select Font #5 for create a preview TextDraw");
				ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
			}
	        return true;
	    }
	    case DIALOG_ETD_PREVIEW_MODEL_INDEX: {
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's Preview Model Index"), "Insert Model Index: (( ObjectID ))", "Accept", "Cancel");
	        return true;
	    }
	    case DIALOG_ETD_PREVIEW_MODEL_RX: {
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's Preview Model Index"), "Insert Model Index RX:", "Go", "Back");
	        return true;
	    }
	    case DIALOG_ETD_PREVIEW_MODEL_RY: {
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's Preview Model Index"), "Insert Model Index RY:", "Go", "Back");
	        return true;
	    }
	    case DIALOG_ETD_PREVIEW_MODEL_RZ: {
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's Preview Model Index"), "Insert Model Index RZ:", "Go", "Back");
	        return true;
	    }
	    case DIALOG_ETD_PREVIEW_MODEL_ZOOM: {
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's Preview Model Index"), "Insert Model Index Zoom:", "Go", "Back");
	        return true;
	    }
	    case DIALOG_ETD_MODE: {
	        new info[175];
	        format(info, sizeof(info), "Mode TextDraw. The current mode is: %s\n",tData[pData[playerid][P_CurrentTextdraw]][T_Mode] == 0 ? ("Global") : ("Player"));

	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Textdraw's mode"), info, "Global", "Player");
	        return true;
	    }

	    //By BitSain
	    case DIALOG_OTHERS_OPTIONS:{
	    	new info[526] = 
                "{FFFFFF}Set All TextDraws in mode\n\
                {FFFFFF}Reorder all TextDraws ID\n\
                {FFFFFF}Move All TextDraws {FF0000}(DISABLED)\n\
                {FFFFFF}Resize All TextDraws {FF0000}(DISABLED)";

	    	ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Others Options"), info, "Select", "Back");
	    	return true;
	    }

	    case DIALOG_SET_ALL_TEXTDRAWS_MODE:{
            ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Set All TextDraws in mode:"), "Set All TextDraws in mode Global\nSet All TextDraws in mode Player", "Select", "Back");
            return true;
        }
	}
	return false;
}

stock ResetPlayerVars(playerid) {
	/*	Resets a specific player's pData info.
	    @playerid:      ID of the player to reset the data of.
	*/
	
	pData[playerid][P_Editing] = false;
	strmid(CurrentProject, "", 0, 1, 128);
}

stock ClearTextDraw(tdid) {
	/*	Resets a textdraw's variables and destroys it.
	    @tdid:          Textdraw ID
	*/
	if(tData[tdid][T_Handler] != Text:INVALID_TEXT_DRAW) TextDrawHideForAll(tData[tdid][T_Handler]);
	static const reset[enum_tData];
    tData[tdid] = reset;

    strmid(tData[tdid][T_Text], "", 0, 1, 2);
    tData[tdid][T_Handler] = Text:INVALID_TEXT_DRAW;
    tData[tdid][T_PreviewModel] = -1;
    tData[tdid][PMZoom] = 1.0;
    tData[tdid][PMRotX] = -16.0;
    tData[tdid][PMRotY] = 0.0;
    tData[tdid][PMRotZ] = -55.0;
}

stock CreateDefaultTextDraw(tdid, bool:save = true, bool:update = true) {
	/*  Creates a new textdraw with default settings.
		@tdid:          Textdraw ID
	*/
    if(Iter_Contains(zTextList, tdid) || tData[tdid][T_Created]) return;
    Iter_Add(zTextList, tdid);

	tData[tdid][T_Created] = true;
    tData[tdid][T_Handler] = TextDrawCreate(0.0, 0.0, "_");
    format(tData[tdid][T_Text], 1024, "New Textdraw%d", tdid);
    tData[tdid][T_X] = 250.0;
    tData[tdid][T_Y] = 10.0;
    tData[tdid][T_TextSize][0] = 0.0;
    tData[tdid][T_TextSize][1] = 0.0;
    tData[tdid][T_Size][0] = 0.5;
    tData[tdid][T_Size][1] = 1.0;
    tData[tdid][T_Alignment] = 1;
    tData[tdid][T_BackColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_UseBox] = 0;
    tData[tdid][T_BoxColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_Color] = RGB(255, 255, 255, 255);
    tData[tdid][T_Font] = 1;
    tData[tdid][T_Outline] = 0;
    tData[tdid][T_Proportional] = true;
    tData[tdid][T_Shadow] = 1;
    tData[tdid][T_Selectable] = 0;
    tData[tdid][T_Mode] = 0;
    tData[tdid][T_PreviewModel] = -1;
    tData[tdid][PMZoom] = 1.0;
    tData[tdid][PMRotX] = -16.0;
    tData[tdid][PMRotY] = 0.0;
    tData[tdid][PMRotZ] = -55.0;
	
    if(update) UpdateTextdraw(tdid);
    if(save) SaveAllTDData(tdid);
}

stock DuplicateTextdraw(source, bool:save = true, bool:update = true, to = -1) {
    /*  Duplicates a textdraw from another one. Updates the new one.
        @source:            Where to copy the textdraw from.
        @to:                Where to copy the textdraw to.
    */
    if(to == -1) to = Iter_Free(zTextList);
    if((!Iter_Contains(zTextList, source) || !tData[source][T_Created]) && (Iter_Contains(zTextList, to) || tData[to][T_Created])) 
        return -1;

    CreateDefaultTextDraw(to);
    ClearTextDraw(to);

	tData[to][T_Created] = tData[source][T_Created];
	format(tData[to][T_Text], 1024, tData[source][T_Text]);
    tData[to][T_X] = tData[source][T_X];
    tData[to][T_Y] = tData[source][T_Y];
    tData[to][T_Alignment] = tData[source][T_Alignment];
    tData[to][T_BackColor] = tData[source][T_BackColor];
    tData[to][T_UseBox] = tData[source][T_UseBox];
    tData[to][T_BoxColor] = tData[source][T_BoxColor];
    tData[to][T_TextSize][0] = tData[source][T_TextSize][0];
    tData[to][T_TextSize][1] = tData[source][T_TextSize][1];
    tData[to][T_Color] = tData[source][T_Color];
    tData[to][T_Font] = tData[source][T_Font];
    tData[to][T_Size][0] = tData[source][T_Size][0];
    tData[to][T_Size][1] = tData[source][T_Size][1];
    tData[to][T_Outline] = tData[source][T_Outline];
    tData[to][T_Proportional] = tData[source][T_Proportional];
    tData[to][T_Shadow] = tData[source][T_Shadow];
    tData[to][T_Selectable] = tData[source][T_Selectable];
    tData[to][T_Mode] = tData[source][T_Mode];
    tData[to][T_PreviewModel] = tData[source][T_PreviewModel];
    tData[to][PMRotX] = tData[source][PMRotX];
    tData[to][PMRotY] = tData[source][PMRotY];
    tData[to][PMRotZ] = tData[source][PMRotZ];
    tData[to][PMZoom] = tData[source][PMZoom];

	if(update) UpdateTextdraw(to);
	if(save) SaveAllTDData(to);
    return to;
}

stock UpdateTextdraw(tdid) {
	if((Iter_Contains(zTextList, tdid) && tData[tdid][T_Created]) && tData[tdid][T_Handler] != Text:INVALID_TEXT_DRAW){
        TextDrawHideForAll(tData[tdid][T_Handler]);
        TextDrawDestroy(tData[tdid][T_Handler]);
    }

	// Recreate it
	tData[tdid][T_Handler] = TextDrawCreate(tData[tdid][T_X], tData[tdid][T_Y], tData[tdid][T_Text]);
    TextDrawLetterSize(tData[tdid][T_Handler], tData[tdid][T_Size][0], tData[tdid][T_Size][1]);
    TextDrawFont(tData[tdid][T_Handler], tData[tdid][T_Font]);
	TextDrawAlignment(tData[tdid][T_Handler], tData[tdid][T_Alignment]);
	TextDrawColor(tData[tdid][T_Handler], tData[tdid][T_Color]);
    TextDrawBackgroundColor(tData[tdid][T_Handler], tData[tdid][T_BackColor]);
	TextDrawSetOutline(tData[tdid][T_Handler], tData[tdid][T_Outline]);
	TextDrawSetProportional(tData[tdid][T_Handler], tData[tdid][T_Proportional]);
	TextDrawSetShadow(tData[tdid][T_Handler], tData[tdid][T_Shadow]);
	TextDrawUseBox(tData[tdid][T_Handler], tData[tdid][T_UseBox]);
    if(tData[tdid][T_Selectable] || tData[tdid][T_TextSize][0] != 0.0 || tData[tdid][T_TextSize][1] != 0.0)
        TextDrawTextSize(tData[tdid][T_Handler], tData[tdid][T_TextSize][0], tData[tdid][T_TextSize][1]);
    TextDrawBoxColor(tData[tdid][T_Handler], tData[tdid][T_BoxColor]);
    TextDrawSetSelectable(tData[tdid][T_Handler], tData[tdid][T_Selectable]);
    TextDrawSetPreviewModel(tData[tdid][T_Handler], tData[tdid][T_PreviewModel]);
    TextDrawSetPreviewRot(tData[tdid][T_Handler], tData[tdid][PMRotX], tData[tdid][PMRotY], tData[tdid][PMRotZ], tData[tdid][PMZoom]);

    TextDrawShowForAll(tData[tdid][T_Handler]);
	return true;
}

stock UpdateAllTextDraws(){
    foreach(new i : zTextList)
        UpdateTextdraw(i);
}

stock SaveTDData(tdid, const data[]) {
    if(!Iter_Contains(zTextList, tdid) || !tData[tdid][T_Created]) return false;
	/*  Saves a specific data from a specific textdraw to project file.
	    @tdid:              Textdraw ID.
	    @data[]:            Data to be saved.
	*/
	new string[128], filename[135];
	format(string, sizeof(string), "%d%s", tdid, data);
	format(filename, sizeof(filename), PROJECT_DIRECTORY, CurrentProject);

	if(!strcmp("T_Created", data))
        dini_IntSet(filename, string, 1);
	else if(!strcmp("T_Text", data))
		dini_Set(filename, string, tData[tdid][T_Text]);
	else if(!strcmp("T_X", data))
		dini_FloatSet(filename, string, tData[tdid][T_X]);
	else if(!strcmp("T_Y", data))
		dini_FloatSet(filename, string, tData[tdid][T_Y]);
    else if(!strcmp("T_TextSizeX", data))
        dini_FloatSet(filename, string, tData[tdid][T_TextSize][0]);
    else if(!strcmp("T_TextSizeY", data))
        dini_FloatSet(filename, string, tData[tdid][T_TextSize][1]);
    else if(!strcmp("T_XSize", data))
        dini_FloatSet(filename, string, tData[tdid][T_Size][0]);
    else if(!strcmp("T_YSize", data))
        dini_FloatSet(filename, string, tData[tdid][T_Size][1]);
	else if(!strcmp("T_Alignment", data))
		dini_IntSet(filename, string, tData[tdid][T_Alignment]);
	else if(!strcmp("T_BackColor", data))
		dini_IntSet(filename, string, tData[tdid][T_BackColor]);
	else if(!strcmp("T_UseBox", data))
		dini_IntSet(filename, string, tData[tdid][T_UseBox]);
	else if(!strcmp("T_BoxColor", data))
		dini_IntSet(filename, string, tData[tdid][T_BoxColor]);
    else if(!strcmp("T_Color", data))
		dini_IntSet(filename, string, tData[tdid][T_Color]);
    else if(!strcmp("T_Font", data))
		dini_IntSet(filename, string, tData[tdid][T_Font]);
    else if(!strcmp("T_Outline", data))
		dini_IntSet(filename, string, tData[tdid][T_Outline]);
    else if(!strcmp("T_Proportional", data))
		dini_BoolSet(filename, string, tData[tdid][T_Proportional]);
    else if(!strcmp("T_Shadow", data))
		dini_IntSet(filename, string, tData[tdid][T_Shadow]);
    else if(!strcmp("T_Selectable", data))
		dini_IntSet(filename, string, tData[tdid][T_Selectable]);
    else if(!strcmp("T_Mode", data))
		dini_IntSet(filename, string, tData[tdid][T_Mode]);
    else if(!strcmp("T_PreviewModel", data))
		dini_IntSet(filename, string, tData[tdid][T_PreviewModel]);
    else if(!strcmp("PMRotX", data))
		dini_FloatSet(filename, string, tData[tdid][PMRotX]);
    else if(!strcmp("PMRotY", data))
		dini_FloatSet(filename, string, tData[tdid][PMRotY]);
    else if(!strcmp("PMRotZ", data))
		dini_FloatSet(filename, string, tData[tdid][PMRotZ]);
    else if(!strcmp("PMZoom", data))
		dini_FloatSet(filename, string, tData[tdid][PMZoom]);
	else {
	    ScriptMessageToAll("[ZTDE]: Incorrect data parsed, textdraw autosave failed");
        #if ZTDE_DEBUG == true
            printf("[ZTDE]: Incorrect data parsed, textdraw autosave failed in project '%s'", CurrentProject);
        #endif
	    return false;
    }
    return true;
}

stock SaveAllTextDraws(){
    foreach(new i : zTextList)
        SaveAllTDData(i);
}

stock SaveAllTDData(tdid){
    if(!Iter_Contains(zTextList, tdid) || !tData[tdid][T_Created]) return;

    SaveTDData(tdid, "T_Created");
    SaveTDData(tdid, "T_Text");
    SaveTDData(tdid, "T_X"); 
    SaveTDData(tdid, "T_Y");
    SaveTDData(tdid, "T_XSize"); 
    SaveTDData(tdid, "T_YSize");
    SaveTDData(tdid, "T_TextSizeX"); 
    SaveTDData(tdid, "T_TextSizeY");
    SaveTDData(tdid, "T_Alignment");
    SaveTDData(tdid, "T_Color");
    SaveTDData(tdid, "T_Font");
    SaveTDData(tdid, "T_Mode");
    SaveTDData(tdid, "T_UseBox");
    SaveTDData(tdid, "T_BoxColor");
    SaveTDData(tdid, "T_Shadow");
    SaveTDData(tdid, "T_Outline");
    SaveTDData(tdid, "T_BackColor");
    SaveTDData(tdid, "T_Proportional");
    SaveTDData(tdid, "T_Selectable");
    SaveTDData(tdid, "T_PreviewModel");
    SaveTDData(tdid, "PMRotX");
    SaveTDData(tdid, "PMRotY");
    SaveTDData(tdid, "PMRotZ");
    SaveTDData(tdid, "PMZoom");
}

stock DeleteTDFromFile(tdid) {
    if(!Iter_Contains(zTextList, tdid) || !tData[tdid][T_Created]) return;
    /*  Deletes a specific textdraw from its .tde file
        @tdid:              Textdraw ID.
    */
    new string[128], filename[135];
    format(filename, sizeof(filename), PROJECT_DIRECTORY, CurrentProject);
    
    format(string, sizeof(string), "%dT_Created", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Text", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_X", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Y", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Alignment", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_BackColor", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_UseBox", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_BoxColor", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_TextSizeX", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_TextSizeY", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Color", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Font", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_XSize", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_YSize", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Outline", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Proportional", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Shadow", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Selectable", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_Mode", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dT_PreviewModel", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dPMRotX", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dPMRotY", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dPMRotZ", tdid);
    dini_Unset(filename, string);
    format(string, sizeof(string), "%dPMZoom", tdid);
    dini_Unset(filename, string);
}

stock ExportProject(playerid, type) {
	/*  Exports a project.
	    @playerid:          ID of the player exporting the project.
	    @type:              Type of export requested:
            - Type 0:       Classic export type
            - Type 1:       Show all the time export type (FS)
            - Type 2:       Show on class selection export type (FS)
            - Type 3:       Show while in vehicle export type (FS)
            - Type 4:       Use command export type (FS)
            - Type 5:       Every X time export type (FS)
            - Type 6:       After kill exporte type (FS)
            - Type 7:       Player TextDraw export type by adri1.
            - Type 8:       Mixed export type
 	*/
 	ScriptMessage(playerid, "[ZTDE]: The project is now being exported, please wait...");
 	
 	new filedirectory[256 + 128], filename[128], tmpstring[1350];
    strmid(filename, CurrentProject, 0, strlen(CurrentProject) - 4, sizeof(filename));
 	if(type == 0 || type == 7 || type == 8) format(filedirectory, sizeof(filedirectory), EXPORT_DIRECTORY".txt", filename);
 	else format(filedirectory, sizeof(filedirectory), EXPORT_DIRECTORY".pwn", filename);

 	new File:File = fopen(filedirectory, io_write);
 	if(!File) {
        ScriptMessage(playerid, "[ZTDE]: Failed to open the file for exporting.");
        return false;
    }
    
    // Debugging output to trace the export process
    #if ZTDE_DEBUG == true
        new pname[MAX_PLAYER_NAME]; GetPlayerName(playerid, pname, sizeof(pname));
        printf("[ZTDE DEBUG]: %s(%d) | Exporting project: %s, type: %d", pname, playerid, CurrentProject, type);
    #endif

	switch(type){
		case 0: { // Classic export
	        fwrite(File, "// TextDraw developed using Zamaroht's Textdraw Editor "#ZTDE_VERSION"\r\n\r\n");
	        fwrite(File, "// On top of script:\r\n");
	        foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\n// In OnGameModeInit prefferably, we procced to create our textdraws:\r\n");
	        foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);
				
					format(tmpstring, sizeof(tmpstring), "TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);
                    
                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					if(tData[i][T_PreviewModel] > -1) {
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetPreviewModel(Textdraw%d, %d);\r\n", i, tData[i][T_PreviewModel]);
					    fwrite(File, tmpstring);
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetPreviewRot(Textdraw%d, %f, %f, %f, %f);\r\n", i, tData[i][PMRotX], tData[i][PMRotY], tData[i][PMRotZ], tData[i][PMZoom]);
					    fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "// You can now use TextDrawShowForPlayer(-ForAll), TextDrawHideForPlayer(-ForAll) and\r\n");
	        fwrite(File, "// TextDrawDestroy functions to show, hide, and destroy the textdraw.");

			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.txt in scriptfiles directory.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }

	    case 1: { // Show all the time
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version "#ZTDE_VERSION".\r\n");
	        fwrite(File, "Designed for SA-MP 0.3.7.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);
                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	for(new i; i < MAX_PLAYERS; i ++) // Use foreach\r\n");
	        fwrite(File, "	{\r\n");
	        fwrite(File, "		if(IsPlayerConnected(i))\r\n");
	        fwrite(File, "		{\r\n");
	        foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawShowForPlayer(i, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            foreach(new i : zTextList) {
                if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerConnect(playerid)\r\n");
			fwrite(File, "{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
			
			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.pwn in scriptfiles directory as a filterscript.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }
	    
	    case 2: { // Show on class selection
            fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version "#ZTDE_VERSION".\r\n");
	        fwrite(File, "Designed for SA-MP 0.3.7.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            foreach(new i : zTextList) {
                if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerRequestClass(playerid, classid)\r\n");
			fwrite(File, "{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerSpawn(playerid)\r\n");
			fwrite(File, "{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			
			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.pwn in scriptfiles directory as a filterscript.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }
	    
	    case 3: { // Show while in vehicle
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version "#ZTDE_VERSION".\r\n");
	        fwrite(File, "Designed for SA-MP 0.3.7.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            foreach(new i : zTextList) {
                if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerStateChange(playerid, newstate, oldstate)\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)\r\n");
			fwrite(File, "	{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "		TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	}\r\n");
			fwrite(File, "	else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)\r\n");
			fwrite(File, "	{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "		TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
			
			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.pwn in scriptfiles directory as a filterscript.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }
	    
	    case 4: { // Use command
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version "#ZTDE_VERSION".\r\n");
	        fwrite(File, "Designed for SA-MP 0.3.7.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
			fwrite(File, "new Showing[MAX_PLAYERS];\r\n\r\n");
            foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            foreach(new i : zTextList) {
                if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerConnect(playerid)\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	Showing[playerid] = 0;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerCommandText(playerid, cmdtext[])\r\n");
			fwrite(File, "{\r\n");
			if(pData[playerid][P_Aux] != 0) {
			    format(tmpstring, sizeof(tmpstring), "	if(!strcmp(cmdtext, \"%s\") && Showing[playerid] == 0)\r\n", pData[playerid][P_ExpCommand]);
			    fwrite(File, tmpstring);
			}
			else {
			    format(tmpstring, sizeof(tmpstring), "	if(!strcmp(cmdtext, \"%s\"))\r\n", pData[playerid][P_ExpCommand]);
			    fwrite(File, tmpstring);
			}
			fwrite(File, "	{\r\n");
			fwrite(File, "		if(Showing[playerid] == 1)\r\n");
			fwrite(File, "		{\r\n");
			fwrite(File, "			Showing[playerid] = 0;\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "		else\r\n");
			fwrite(File, "		{\r\n");
			fwrite(File, "			Showing[playerid] = 1;\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			if(pData[playerid][P_Aux] != 0) {
			    format(tmpstring, sizeof(tmpstring), "			SetTimerEx(\"HideTextdraws\", %d, 0, \"i\", playerid);\r\n", pData[playerid][P_Aux]*1000);
				fwrite(File, tmpstring);
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
            if(pData[playerid][P_Aux] != 0) {
			    fwrite(File, "\r\n");
			    fwrite(File, "forward HideTextdraws(playerid);\r\n");
			    fwrite(File, "public HideTextdraws(playerid)\r\n");
			    fwrite(File, "{\r\n");
			    fwrite(File, "	Showing[playerid] = 0;\r\n");
			    foreach(new i : zTextList) {
				    if(tData[i][T_Created]) {
				        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
						fwrite(File, tmpstring);
				    }
				}
				fwrite(File, "}\r\n");
			}
			
			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.pwn in scriptfiles directory as a filterscript.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }
	    
	    case 5: { // Every X time
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version "#ZTDE_VERSION".\r\n");
	        fwrite(File, "Designed for SA-MP 0.3.7.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
			fwrite(File, "new Timer;\r\n\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        format(tmpstring, sizeof(tmpstring), "	Timer = SetTimer(\"ShowMessage\", %d, 1);\r\n", pData[playerid][P_Aux]*1000);
	        fwrite(File, tmpstring);
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            foreach(new i : zTextList) {
                if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
            fwrite(File, "	KillTimer(Timer);\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
	        fwrite(File, "forward ShowMessage( );\r\n");
	        fwrite(File, "public ShowMessage( )\r\n");
	        fwrite(File, "{\r\n");
	        foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			format(tmpstring, sizeof(tmpstring), "	SetTimer(\"HideMessage\", %d, 1);\r\n", pData[playerid][P_Aux2]*1000);
			fwrite(File, tmpstring);
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "forward HideMessage( );\r\n");
	        fwrite(File, "public HideMessage( )\r\n");
	        fwrite(File, "{\r\n");
	        foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
	        fwrite(File, "}");
	        
	        format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.pwn in scriptfiles directory as a filterscript.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }
	    
	    case 6: { // After kill
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version "#ZTDE_VERSION".\r\n");
	        fwrite(File, "Designed for SA-MP 0.3.7.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);
					if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
                        format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
                        fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            foreach(new i : zTextList) {
                if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerDeath(playerid, killerid, reason)\r\n");
			fwrite(File, "{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(killerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			format(tmpstring, sizeof(tmpstring), "	SetTimerEx(\"HideMessage\", %d, 0, \"i\", killerid);\r\n", pData[playerid][P_Aux]*1000);
			fwrite(File, tmpstring);
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "forward HideMessage(playerid);\r\n");
			fwrite(File, "public HideMessage(playerid)\r\n");
			fwrite(File, "{\r\n");
			foreach(new i : zTextList) {
			    if(tData[i][T_Created]) {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "}");
			
		    format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.pwn in scriptfiles directory as a filterscript.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }

	    case 7: { // PlayerTextDraw by adri1.
	        fwrite(File, "// TextDraw developed using Zamaroht's Textdraw Editor "#ZTDE_VERSION"\r\n\r\n");
	        fwrite(File, "// The fuction `PlayerTextDraw add by adri1\r\n");
	        fwrite(File, "// On top of script:\r\n");
	        foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "new PlayerText:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\n// In OnPlayerConnect prefferably, we procced to create our textdraws:\r\n");
	        foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					format(tmpstring, sizeof(tmpstring), "Textdraw%d = CreatePlayerTextDraw(playerid,%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawAlignment(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawBackgroundColor(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawFont(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawLetterSize(playerid,Textdraw%d, %f, %f);\r\n", i, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawColor(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetOutline(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetProportional(playerid,Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetShadow(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawUseBox(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
                    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawBoxColor(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
                    fwrite(File, tmpstring);
                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
                        format(tmpstring, sizeof(tmpstring), "PlayerTextDrawTextSize(playerid,Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
                        fwrite(File, tmpstring);
                    }
					
                    if(tData[i][T_PreviewModel] > -1) {
					    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetPreviewModel(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_PreviewModel]);
					    fwrite(File, tmpstring);
					    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetPreviewRot(playerid, Textdraw%d, %f, %f, %f, %f);\r\n", i, tData[i][PMRotX], tData[i][PMRotY], tData[i][PMRotZ], tData[i][PMZoom]);
					    fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetSelectable(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "// You can now use PlayerTextDrawShow, PlayerTextDrawHide and\r\n");
	        fwrite(File, "// PlayerTextDrawDestroy functions to show, hide, and destroy the textdraw.");

			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.txt in scriptfiles directory.", filename);
	        ScriptMessage(playerid, tmpstring);
	        ScriptMessage(playerid, "[ZTDE]: Fuction `PlayerTextDraw` add by adri1");
	    }

		case 8: { // Mixed export mode
	        fwrite(File, "// TextDraw developed using Zamaroht's Textdraw Editor "#ZTDE_VERSION"\r\n\r\n");
	        fwrite(File, "// On top of script:\r\n");

			new g_count = 0;
			new p_count = 0;

			foreach(new i : zTextList) {
	            if(tData[i][T_Created]) {
					if(tData[i][T_Mode])
						++p_count;
					else
					    ++g_count;
				}
	        }
	        if(g_count){
				format(tmpstring, sizeof(tmpstring), "new Text:Textdraw[%d];\r\n", g_count);
				fwrite(File, tmpstring);
	        }
	        if(p_count){
				format(tmpstring, sizeof(tmpstring), "new PlayerText:PlayerTextdraw[%d];\r\n", p_count);
				fwrite(File, tmpstring);
	        }

	        if(g_count) {
	            fwrite(File, "\r\n// -----------------------------------------------------------------------------");
	            fwrite(File, "\r\n//                            GLOBAL TEXTDRAW'S");
	            fwrite(File, "\r\n// -----------------------------------------------------------------------------");
	            fwrite(File, "\r\n\n// In OnGameModeInit prefferably, we procced to create our textdraws:\r\n");
		        for(new i, count_textdraws; i < MAX_TEXTDRAWS; i++) {
              		if(!tData[i][T_Created] || tData[i][T_Mode] != 0) continue;

					format(tmpstring, sizeof(tmpstring), "Textdraw[%d] = TextDrawCreate(%f, %f, \"%s\");\r\n", count_textdraws, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
				    fwrite(File, tmpstring);
				
                    format(tmpstring, sizeof(tmpstring), "TextDrawAlignment(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Alignment]);
    				fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "TextDrawFont(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Font]);
					fwrite(File, tmpstring);
                    
                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
                        format(tmpstring, sizeof(tmpstring), "TextDrawTextSize(Textdraw[%d], %f, %f);\r\n", count_textdraws, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
                        fwrite(File, tmpstring);
                    }
					
                    format(tmpstring, sizeof(tmpstring), "TextDrawLetterSize(Textdraw[%d], %f, %f);\r\n", count_textdraws, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawColor(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Color]);
					fwrite(File, tmpstring);
                    format(tmpstring, sizeof(tmpstring), "TextDrawBackgroundColor(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_BackColor]);
                    fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetOutline(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetProportional(Textdraw[%d], %s);\r\n", count_textdraws, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);

    				format(tmpstring, sizeof(tmpstring), "TextDrawSetShadow(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Shadow]);
    				fwrite(File, tmpstring);

                    format(tmpstring, sizeof(tmpstring), "TextDrawUseBox(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawBoxColor(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

					if(tData[i][T_PreviewModel] > -1) {
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetPreviewModel(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_PreviewModel]);
					    fwrite(File, tmpstring);
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetPreviewRot(Textdraw[%d], %f, %f, %f, %f);\r\n", count_textdraws, tData[i][PMRotX], tData[i][PMRotY], tData[i][PMRotZ], tData[i][PMZoom]);
					    fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "TextDrawSetSelectable(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");

					++count_textdraws;
				}
	        	fwrite(File, "// You can now use TextDrawShowForPlayer(-ForAll), TextDrawHideForPlayer(-ForAll) and\r\n");
	        	fwrite(File, "// TextDrawDestroy functions to show, hide, and destroy the textdraw.\r\n");
	        }

	        if(p_count) {
	            fwrite(File, "\r\n// -----------------------------------------------------------------------------");
	            fwrite(File, "\r\n//                            PER PLAYER TEXTDRAWS");
	            fwrite(File, "\r\n// -----------------------------------------------------------------------------");
		        fwrite(File, "\r\n// In OnPlayerConnect prefferably, we procced to create our textdraws:\r\n");
		        for(new i, count_textdraws; i < MAX_TEXTDRAWS; i++) {
		            if(!tData[i][T_Created] || tData[i][T_Mode] != 1) continue;

					format(tmpstring, sizeof(tmpstring), "PlayerTextdraw[%d] = CreatePlayerTextDraw(playerid, %f, %f, \"%s\");\r\n", count_textdraws, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
                    
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawAlignment(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Alignment]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawBackgroundColor(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawFont(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawLetterSize(playerid, PlayerTextdraw[%d], %f, %f);\r\n", count_textdraws, tData[i][T_Size][0], tData[i][T_Size][1]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawColor(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetOutline(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetProportional(playerid, PlayerTextdraw[%d], %s);\r\n", count_textdraws, tData[i][T_Proportional] == true ? ("true") : ("false"));
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetShadow(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawUseBox(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_UseBox]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawBoxColor(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);
					if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
                        format(tmpstring, sizeof(tmpstring), "PlayerTextDrawTextSize(playerid, PlayerTextdraw[%d], %f, %f);\r\n", count_textdraws, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
                        fwrite(File, tmpstring);
                    }

					if(tData[i][T_PreviewModel] > -1) {
					    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetPreviewModel(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_PreviewModel]);
					    fwrite(File, tmpstring);
					    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetPreviewRot(playerid, PlayerTextdraw[%d], %f, %f, %f, %f);\r\n", count_textdraws, tData[i][PMRotX], tData[i][PMRotY], tData[i][PMRotZ], tData[i][PMZoom]);
					    fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetSelectable(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Selectable]);
					fwrite(File, tmpstring);
					fwrite(File, "\r\n");

					++count_textdraws;
				}
	        	fwrite(File, "// You can now use PlayerTextDrawShow, PlayerTextDrawHide and\r\n");
	        	fwrite(File, "// PlayerTextDrawDestroy functions to show, hide, and destroy the textdraw.");
	        }

			format(tmpstring, sizeof(tmpstring), "[ZTDE]: Project exported to %s.txt in scriptfiles directory.", filename);
	        ScriptMessage(playerid, tmpstring);
	    }
	}
	fclose(File);
	
	ShowTextDrawDialog(playerid, DIALOG_MAIN_EDITION_MENU, pData[playerid][P_DialogPage]);
	return true;
}

#include "src/modules/import.pwn" // Import TextDraws

function ShowTextDrawDialogEx(playerid, dialogid){
	return ShowTextDrawDialog(playerid, dialogid);
}

function KeyEdit(playerid) {
	/*  Handles the edition by keyboard.
		@playerid:          	Player editing.
	*/
	if(pData[playerid][P_KeyEdition] == EDIT_NONE) 
        return false;
	
	new string[256]; // Buffer for all gametexts and other messages.
	new keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);
    
    #if ZTDE_EXPERIMENTAL == true
        new bool:AllTD_updated = false;
    #endif

	if(updown < 0) { // He's pressing up
	    switch(pData[playerid][P_KeyEdition]) {
	        case EDIT_POSITION: {
                if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 10.0;
                else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 0.1;
                else tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }

            #if ZTDE_EXPERIMENTAL == true
                case EDIT_ALL_TD_POSITION: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;

                        tData[i][T_Y] -= size;
                        if(tData[i][T_UseBox] && tData[i][T_Alignment] != ALIGN_CENTER && tData[i][T_Font] != 4 && tData[i][T_PreviewModel] == -1)
                           tData[i][T_TextSize][1] -= size;
                    }
                    AllTD_updated = true;
                }

                case EDIT_ALL_TD_SIZE: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;
                        tData[i][T_Size][1] -= size;

                        if(tData[i][T_UseBox] || tData[i][T_Selectable]){
                            tData[i][T_TextSize][1] -= size;
                        }
                    }
                    AllTD_updated = true;
                }
            #endif
	        
	        case EDIT_SIZE: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] -= 1.0;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] -= 0.01;
				else tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] -= 0.1;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_Size][0], tData[pData[playerid][P_CurrentTextdraw]][T_Size][1]);
	        }
	        
	        case EDIT_BOX: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1] -= 10.0;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1] -= 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0], tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1]);
	        }
	    }
	}
	else if(updown > 0) { // He's pressing down
	    switch(pData[playerid][P_KeyEdition]) {
	        case EDIT_POSITION: {
                if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 10.0;
                else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }

            #if ZTDE_EXPERIMENTAL == true
                case EDIT_ALL_TD_POSITION: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;

                        tData[i][T_Y] += size;
                        if(tData[i][T_UseBox] && tData[i][T_Alignment] != ALIGN_CENTER && tData[i][T_Font] != 4 && tData[i][T_PreviewModel] == -1)
                            tData[i][T_TextSize][1] += size;
                    }
                    AllTD_updated = true;
                }

                case EDIT_ALL_TD_SIZE: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;
                        tData[i][T_Size][1] += size;

                        if(tData[i][T_UseBox] || tData[i][T_Selectable]){
                            tData[i][T_TextSize][1] += size;
                        }
                    }
                    AllTD_updated = true;
                }
            #endif
	        
	        case EDIT_SIZE: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] += 1.0;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] += 0.01;
				else tData[pData[playerid][P_CurrentTextdraw]][T_Size][1] += 0.1;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_Size][0], tData[pData[playerid][P_CurrentTextdraw]][T_Size][1]);
	        }
	        
	        case EDIT_BOX: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1] += 10.0;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1] += 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0], tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1]);
	        }
	    }
	}

	if(leftright < 0) { // He's pressing left
        switch(pData[playerid][P_KeyEdition]) {
	        case EDIT_POSITION: {
                if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 10.0;
                else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }

            #if ZTDE_EXPERIMENTAL == true
                case EDIT_ALL_TD_POSITION: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;

                        tData[i][T_X] -= size;
                        if(tData[i][T_UseBox] && tData[i][T_Alignment] != ALIGN_CENTER && tData[i][T_Font] != 4 && tData[i][T_PreviewModel] == -1)
                            tData[i][T_TextSize][0] -= size;
                    }
                    AllTD_updated = true;
                }

                case EDIT_ALL_TD_SIZE: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;
                        tData[i][T_Size][0] -= size;

                        if(tData[i][T_UseBox] || tData[i][T_Selectable]){
                            tData[i][T_TextSize][0] -= size;
                        }
                    }
                    AllTD_updated = true;
                }
            #endif
	        
	        case EDIT_SIZE: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] -= 0.1;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] -= 0.001;
				else tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] -= 0.01;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_Size][0], tData[pData[playerid][P_CurrentTextdraw]][T_Size][1]);
	        }
	        
	        case EDIT_BOX: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0] -= 10.0;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0] -= 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0], tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1]);
	        }
	    }
	}
	else if(leftright > 0) { // He's pressing right
        switch(pData[playerid][P_KeyEdition]) {
	        case EDIT_POSITION: {
                if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_X] += 10.0;
                else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_X] += 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_X] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }

            #if ZTDE_EXPERIMENTAL == true
                case EDIT_ALL_TD_POSITION: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 10.0;
                        else if(keys == KEY_WALK) size = 0.1;
                        else size = 1.0;

                        tData[i][T_X] += size;
                        if(tData[i][T_UseBox] && tData[i][T_Alignment] != ALIGN_CENTER && tData[i][T_Font] != 4 && tData[i][T_PreviewModel] == -1)
                            tData[i][T_TextSize][0] += size;
                    }
                    AllTD_updated = true;
                }
                
                case EDIT_ALL_TD_SIZE: {
                    new Float:size;
                    foreach(new i : zTextList){
                        if(keys == KEY_SPRINT) size = 0.1;
                        else if(keys == KEY_WALK) size = 0.001;
                        else size = 0.01;
                        tData[i][T_Size][0] += size;

                        if(tData[i][T_UseBox] || tData[i][T_Selectable]){
                            tData[i][T_TextSize][0] += size;
                        }
                    }
                    AllTD_updated = true;
                }
            #endif
	        
	        case EDIT_SIZE: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] += 0.1;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] += 0.001;
				else tData[pData[playerid][P_CurrentTextdraw]][T_Size][0] += 0.01;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_Size][0], tData[pData[playerid][P_CurrentTextdraw]][T_Size][1]);
	        }
	        
	        case EDIT_BOX: {
	            if(keys == KEY_SPRINT) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0] += 10.0;
	            else if(keys == KEY_WALK) tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0] += 0.1;
				else tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][0], tData[pData[playerid][P_CurrentTextdraw]][T_TextSize][1]);
	        }
	    }
	}

    SetTimerEx("KeyEdit", 100, 0, "i", playerid);

    #if ZTDE_EXPERIMENTAL == true
        if(pData[playerid][P_KeyEdition] == EDIT_ALL_TD_POSITION) {
            if(AllTD_updated){
                /*foreach(new i : zTextList){
                    SaveTDData(i, "T_X");
                    SaveTDData(i, "T_Y");
                    if((tData[i][T_UseBox] || tData[i][T_Selectable]) && (tData[i][T_PreviewModel] == -1)){
                        SaveTDData(i, "T_TextSizeX");
                        SaveTDData(i, "T_TextSizeY");
                    }
                }*/
                UpdateAllTextDraws();
            }
            AllTD_updated = false;
            return true;
        }
        else if(pData[playerid][P_KeyEdition] == EDIT_ALL_TD_SIZE) {
            if(AllTD_updated){
                /*foreach(new i : zTextList){
                    SaveTDData(i, "T_SizeX");
                    SaveTDData(i, "T_SizeY");
                    if((tData[i][T_UseBox] || tData[i][T_Selectable]) && (tData[i][T_PreviewModel] == -1)){
                        SaveTDData(i, "T_TextSizeX");
                        SaveTDData(i, "T_TextSizeY");
                    }
                }*/
                UpdateAllTextDraws();
            }
            AllTD_updated = false;
            return true;
        }
    #endif

    GameTextForPlayer(playerid, string, 999999999, 3);
    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
    
    if(pData[playerid][P_KeyEdition] == EDIT_POSITION) {
        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_X");
        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Y");
    }
	else if(pData[playerid][P_KeyEdition] == EDIT_SIZE) {
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_XSize");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_YSize");
	}
	else if(pData[playerid][P_KeyEdition] == EDIT_BOX) {
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_TextSizeX");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_TextSizeY");
	}
    return true;
}

// ================================================================================================================================
// ->						AUXILIAR FUNCTIONS
// ================================================================================================================================

stock ContainsIllegalCharacters(const inputtext[]) { //By BitSain
    for(new i = 0; i < strlen(inputtext); i++) {
        if(inputtext[i] == '/' || inputtext[i] == '\\' || inputtext[i] == ':' || 
           inputtext[i] == '*' || inputtext[i] == '?' || inputtext[i] == '"' || 
           inputtext[i] == '<' || inputtext[i] == '>' || inputtext[i] == '|') {
            return true;
        }
    }
    return false;
}

stock GetFileNameFromLst(const file[], line) {
	/*  Returns the line in the specified line of the specified file.
	    @file[]:            File to return the line from.
	    @line:              Line number to return.
	*/
	new string[150];

	new CurrLine,
		File:Handler = fopen(file, io_read);

	if(line >= 0 && CurrLine != line){
        while(CurrLine != line) {
			fread(Handler, string);
            CurrLine ++;
        }
	}

	// Read the next line, which is the asked one.
	fread(Handler, string);
	fclose(Handler);

	// Cut the last two characters (\n)
	strmid(string, string, 0, strlen(string) - 2, 150);
	return string;
}

stock DeleteLineFromFile(const file[], line) {
	/*  Deletes a specific line from a specific file.
	    @file[]:        File to delete the line from.
	    @line:          Line number to delete.
	*/

	if(line < 0) return false;

	new tmpfile[140];
	format(tmpfile, sizeof(tmpfile), "%s.tmp", file);
	fcopytextfile(file, tmpfile);
	// Copied to a temp file, now parse it back.

	new CurrLine,
		File:FileFrom 	= fopen(tmpfile, io_read),
		File:FileTo		= fopen(file, io_write);

	new tmpstring[200];
	if(CurrLine != line) {
		while(CurrLine != line) {
		    fread(FileFrom, tmpstring);
			fwrite(FileTo, tmpstring);
			CurrLine ++;
		}
	}

	// Skip a line
	fread(FileFrom, tmpstring);

	// Write the rest
	while(fread(FileFrom, tmpstring)) {
	    fwrite(FileTo, tmpstring);
	}

	fclose(FileTo);
	fclose(FileFrom);
	// Remove tmp file.
	fremove(tmpfile);
	return true;
}

/** BY DRACOBLUE
 *  Strips Newline from the end of a string.
 *  Idea: Y_Less, Bugfixing (when length=1) by DracoBlue
 *  @param   string
 */
stock StripNewLine(string[]) {
	new len = strlen(string);
	if(string[0] == 0) return false;
	if((string[len - 1] == '\n') || (string[len - 1] == '\r')) {
		string[len - 1] = 0;
		if(string[0] == 0) return false;
		if((string[len - 2] == '\n') || (string[len - 2] == '\r')) string[len - 2] = 0;
	}
	return true;
}

/** BY DRACOBLUE
 *  Copies a textfile (Source file won't be deleted!)
 *  @param   oldname
 *           newname
 */
stock fcopytextfile(const oldname[], const newname[]) {
	new File:ohnd,File:nhnd;
	if(!fexist(oldname)) 
        return false;

	ohnd = fopen(oldname,io_read);
	nhnd = fopen(newname,io_write);
	new tmpres[256];
	while(fread(ohnd,tmpres)) {
		StripNewLine(tmpres);
		format(tmpres,sizeof(tmpres),"%s\r\n",tmpres);
		fwrite(nhnd,tmpres);
	}

	fclose(ohnd);
	fclose(nhnd);
	return true;
}

stock RGB(red, green, blue, alpha) {
	/*  Combines a color and returns it, so it can be used in functions.
	    @red:           Amount of red color.
	    @green:         Amount of green color.
	    @blue:          Amount of blue color.
	    @alpha:         Amount of alpha transparency.

		-Returns:
		A integer with the combined color.
	*/
	return (red * 16777216) + (green * 65536) + (blue * 256) + alpha;
}

stock IsNumeric2(const string[]) {
    // Is Numeric Check 2
	// ------------------
	// By DracoBlue... handles negative numbers

	new length = strlen(string);
	if(length == 0) return false;
	for(new i = 0; i < length; i++) {
		if((string[i] > '9' || string[i] < '0' && string[i] != '-' && string[i] != '+' && string[i] != '.') // Not a number,'+' or '-' or '.'
	        || (string[i] == '-' && i != 0) // A '-' but not first char.
	        || (string[i] == '+' && i != 0) // A '+' but not first char.
	    ) return false;
	}
	if(length == 1 && (string[0] == '-' || string[0] == '+' || string[0] == '.')) return false;
	return true;
}

/** BY DRACOBLUE
 *  Return the value of an hex-string
 *  @param string
 */
stock HexToInt(const string[]) {
	if(string[0]==0) return 0;
	new i;
	new cur=1;
	new res=0;
	for(i=strlen(string); i>0; i--) {
		if(string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
		cur=cur*16;
	}
	return res;
}

stock IsPlayerMinID(playerid) {
    /*  Checks if the player is the minimum ID in the server.
        @playerid:              ID to check.
        
        -Returns:
        true if he is, false if he isn't.
    */
    for(new i = 0; i < playerid; i++) {
        if(IsPlayerConnected(i) && !IsPlayerNPC(i)) {
            return false;
        }
    }
    return true;
}

// ================================================================================================================================
// ----------------------------------------------------- END OF AUXULIAR FUNCTIONS ------------------------------------------------
// ================================================================================================================================

//EOF.