/*
    ZTDEditor Functions.
*/

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
                    tData[i][T_UseBox] = dini_Bool(filedirectory, string);

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
                    tData[i][T_Selectable] = dini_Bool(filedirectory, string);
                    
                format(string, sizeof(string), "%dT_Mode", i);
                if(dini_Isset(filedirectory, string))
                    tData[i][T_Mode] = dini_Bool(filedirectory, string);
                    
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
	        format(info, sizeof(info), "%sCurrent mode: %s\n", info, tData[p_current][T_Mode] == false ? ("{00AAFF}GLOBAL") : ("{00AAFF}PLAYER"));
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
	        format(info, sizeof(info), "Selectable TextDraw. The current selectable is: %s\n",tData[pData[playerid][P_CurrentTextdraw]][T_Selectable] ? "ON" : "OFF");
	        
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
	        format(info, sizeof(info), "Mode TextDraw. The current mode is: %s\n", tData[pData[playerid][P_CurrentTextdraw]][T_Mode] == false ? ("Global") : ("Player"));

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
    tData[tdid][T_UseBox] = false;
    tData[tdid][T_BoxColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_Color] = RGB(255, 255, 255, 255);
    tData[tdid][T_Font] = 1;
    tData[tdid][T_Outline] = 0;
    tData[tdid][T_Proportional] = true;
    tData[tdid][T_Shadow] = 1;
    tData[tdid][T_Selectable] = false;
    tData[tdid][T_Mode] = false;
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
		dini_BoolSet(filename, string, tData[tdid][T_UseBox]);
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
		dini_BoolSet(filename, string, tData[tdid][T_Selectable]);
    else if(!strcmp("T_Mode", data))
		dini_BoolSet(filename, string, tData[tdid][T_Mode]);
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