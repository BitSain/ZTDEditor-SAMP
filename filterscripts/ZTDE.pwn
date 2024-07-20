/*
 *     Zamaroht's TextDraw Editor Continued by BitSain
 *     Designed for SA-MP 0.3.7
 *     (C) 2024 BitSain | All right reserved. 
 *
 *     Release of Project: v1.0.0
 *     Last Update Date: 20.07.2024 - 18:03h (day.month.year - hours:minutes)
 *
 *     [!] Compiled with Zeex's Compiler
 *     [!] Link of Compiler: https://github.com/pawn-lang/compiler/releases/                 
 *     [!] Compiler version: 3.10.10+
 *
 *     =================================================================
 *
 *     Original Author: Zamaroht (Nicolás Laurito)
 *     Continuity Author: BitSain (bitsaindeveloper@gmail.com)
 *
 *     Start of Development (Old): 25 December 2009, 22:16 (GMT-3)
 *     End of Development (Old): 01 January 2010, 23:31 (GMT-3)
 *     Start of Continuation: 24 February 2024, 11:15 (GMT-3) [BRAZIL]
 *
 *     [ Credits ]:
 *        - 'Zamaroht' Nicolás Laurito (Author and Creator of version v1.0.0)
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

// [Project Defines]
//====================================================

//Configs
#define ZTDE_VERSION "v1.0.0"

// Avoid use experimental features in production projects to prevent potential bugs. 
   // I'm still testing these features.
#define ZTDE_EXPERIMENTAL false // false = DISABLE | true = ENABLE

//Debug
#define ZTDE_DEBUG false         // true = enable | false = disable
#define ZTDE_DEBUG_LEVEL 0   // 0 = None | 1 = mínim details | 2 = medium details | 3 = max details

#if ZTDE_DEBUG_LEVEL > 0 && ZTDE_DEBUG == false
    #error [ZTDE ERROR]: 'ZTDE_DEBUG' is disabled! Activate it. (Line 76 | false to true)
#endif


// [Macros]
#define function%0(%1) forward%0(%1); public%0(%1)

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

// [Standardize Messages]
#define ScriptMessage(%0,%1)    SendClientMessage(%0, MSG_COLOR, %1)
#define ScriptMessageToAll(%1)   SendClientMessageToAll(MSG_COLOR, %1)

// [Limits]
#define MAX_TEXTDRAWS       	256					 // Max textdraws shown on client screen.
#define MAX_GROUPS                20                     // Max Groups
#define MSG_COLOR           		0xFAF0CEFF	 	 // Color to be shown in the messages.
#define PREVIEW_CHARS       	    35					 // Amount of characters that show on the textdraw's preview.

// [Directories]
#define PROJECT_DIRECTORY "ztdeditor/Projects/%s"
#define EXPORT_DIRECTORY "ztdeditor/ExportProjects/%s"
#define IMPORT_DIRECTORY "ztdeditor/ImportTextDraws/"
#define IMPORT_DIRECTORY2 IMPORT_DIRECTORY"%s"

// [ENUMERATORS]
//====================================================
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
    // DIALOG_MOVE_ALL_TEXTS
};

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
    EDIT_BOX,
    #if ZTDE_EXPERIMENTAL == true
        EDIT_GROUP_POS
    #endif
};

// Used with P_ColorEdition
enum {
    COLOR_TEXT,
    COLOR_OUTLINE,
    COLOR_BOX
};

// TextDraws Alignments
enum {
    ALIGN_Unknown, // ?
    ALIGN_LEFT,
    ALIGN_CENTER,
    ALIGN_RIGHT
};

// ["STRUCTS" in Pawn]
enum enum_tGroup{ // Grou p data.
    g_ID,
    g_Name[32],
    bool:g_Visible
};
new gData[MAX_GROUPS][enum_tGroup];

enum enum_tData{ // Textdraw data.
	bool:T_Created, // Wheter the textdraw ID is created or not.
    T_Group,
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
    T_Shadow,
	bool:T_Proportional,
	bool:T_UseBox,
	bool:T_Selectable,
	bool:T_Mode,
    T_PreviewModel,
	Float:PMRotX,
	Float:PMRotY,
	Float:PMRotZ,
	Float:PMZoom,
    T_PMColor1,
    T_PMColor2/*,
    T_ColorAlpha,
    T_BackColorAlpha,
    T_BoxColorAlpha
    */
};
new tData[MAX_TEXTDRAWS][enum_tData];

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
    bool:P_ReorderingIDs // Used precisely when reordering textdraws, making it impossible to use /text during the process.
};
new pData[MAX_PLAYERS][enum_pData];

// IMPORTANT DETAIL ABOUT THIS ISSUE OF TEXTDRAWS IMPORTS (NOW, PROJECTS).
// I spoke to the creator of Nick's Textdraw Editor, and yes, I will do a project conversion (here and there, by the way)
// I will make a "Revolution" in my own textdraws importer (RAW files) for importing *PROJECTS*.
enum{
    FILE_EXTENSION_UNKNOWN,
    FILE_EXTENSION_ZTDE,
    FILE_EXTENSION_OLD_ZTDE,
    FILE_EXTENSION_NTD,
    FILE_EXTENSION_ITD,
};
enum enum_fExtensions{
    FILE_EXTENSION,
    FILE_EXTENSION_NAME,
    FILE_EXTENSION_TYPE
};
new FileExtensions[][enum_fExtensions] = {
    {"", "Unknown", FILE_EXTENSION_UNKNOWN},
    //{".tde", "Zamaroht's TextDraw Editor", FILE_EXTENSION_ZTDE},
    {".tde", "Zamaroht's TextDraw Editor (old)", FILE_EXTENSION_OLD_ZTDE},
    {".ntd", "Nickk's TextDraw Editor", FILE_EXTENSION_NTD},
    {".itd", "iPLEOMAX's TextDraw Editor", FILE_EXTENSION_ITD},
};

new CurrentProject[128]; // String containing the location of the current opened project file.
new groupsCount; // Total of created groups
// new DB:TDProject; // Database for the edit textdraws
new Iterator:zTextList<MAX_TEXTDRAWS>;

// Modules
#include "modules/utils.pwn"
#include "modules/functions.pwn"
#include "modules/export.pwn"
#include "modules/import.pwn" // in the process of "revolution"
#include "modules/callbacks.pwn"