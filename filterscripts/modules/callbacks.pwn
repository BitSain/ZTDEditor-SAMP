// ["ENTER / EXIT" OF SCRIPT]
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
        ShowPlayerDialog(i, -1, DIALOG_STYLE_MSGBOX, "ZTDE INFO", "ZTDEditor -> Exit.", "Okay", "");
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

// [Player]
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
                        if(!tData[pData[playerid][P_CurrentTextdraw]][T_UseBox]) {
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
                    new tdid = pData[playerid][P_CurrentTextdraw];
                    tData[tdid][T_UseBox] = true;
                    UpdateTextdraw(tdid);
                    SaveTDData(tdid, "T_UseBox");
        
                    ScriptMessage(playerid, "[ZTDE]: Textdraw box enabled. Proceeding with edition...");
        
                    ShowTextDrawDialog(playerid, DIALOG_ETD_BOX2);
                } else if(listitem == 1) { // He disabled it, nothing more to edit.
                    new tdid = pData[playerid][P_CurrentTextdraw];
                    tData[tdid][T_UseBox] = false;
                    UpdateTextdraw(tdid);
                    SaveTDData(tdid, "T_UseBox");
        
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
                    new tdid = pData[playerid][P_CurrentTextdraw];
                    tData[tdid][T_UseBox] = false;
                    UpdateTextdraw(tdid);
                    SaveTDData(tdid, "T_UseBox");
        
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
                }
                else if(listitem == 2) { // box color
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
                new tdid = pData[playerid][P_CurrentTextdraw];
                tData[tdid][T_Selectable] = true;
                UpdateTextdraw(tdid);
                SaveTDData(tdid, "T_Selectable");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's can selectable ON.", tdid);
                ScriptMessage(playerid, string);
            } else {
                new tdid = pData[playerid][P_CurrentTextdraw];
                tData[tdid][T_Selectable] = false;
                UpdateTextdraw(tdid);
                SaveTDData(tdid, "T_Selectable");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's can selectable OFF.", tdid);
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
                new tdid = pData[playerid][P_CurrentTextdraw];
                tData[tdid][T_Mode] = false;
                UpdateTextdraw(tdid);
                SaveTDData(tdid, "T_Mode");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's mode is GLOBAL.", tdid);
                ScriptMessage(playerid, string);
                ShowTextDrawDialog(playerid, DIALOG_TEXTDRAW_EDIT_MENU);
            } else {
                new tdid = pData[playerid][P_CurrentTextdraw];
                tData[tdid][T_Mode] = true;
                UpdateTextdraw(tdid);
                SaveTDData(tdid, "T_Mode");
        
                new string[128];
                format(string, sizeof(string), "[ZTDE]: Textdraw #%d's mode is PLAYER", tdid);
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
                            tData[i][T_Mode] = false;
                            SaveTDData(i, "T_Mode");
                        }
                    }
                    ScriptMessage(playerid, "[ZTDE]: All TextDraws were set to global mode.");
                }
                case 1:{ //Type Player
                    foreach(new i : zTextList) {
                        if(Iter_Contains(zTextList, i) && tData[i][T_Created]) {
                            tData[i][T_Mode] = true;
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