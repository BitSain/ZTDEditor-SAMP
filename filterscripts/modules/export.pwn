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
					format(tmpstring, sizeof(tmpstring), "TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);
                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);
					
					format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

                    if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
    					format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
    					fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);
					if(tData[i][T_UseBox] || tData[i][T_Selectable]) {
                        format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSize][0], tData[i][T_TextSize][1]);
                        fwrite(File, tmpstring);
                    }

					format(tmpstring, sizeof(tmpstring), "	TextDrawSetSelectable(Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetProportional(playerid,Textdraw%d, %s);\r\n", i, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetShadow(playerid,Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawUseBox(playerid,Textdraw%d, %s);\r\n", i, tData[i][T_UseBox] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetSelectable(playerid,Textdraw%d, %s);\r\n", i, tData[i][T_Selectable] ? "true" : "false");
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
              		if(!tData[i][T_Created] || tData[i][T_Mode] != false) continue;

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
					format(tmpstring, sizeof(tmpstring), "TextDrawSetProportional(Textdraw[%d], %s);\r\n", count_textdraws, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);

    				format(tmpstring, sizeof(tmpstring), "TextDrawSetShadow(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Shadow]);
    				fwrite(File, tmpstring);

                    format(tmpstring, sizeof(tmpstring), "TextDrawUseBox(Textdraw[%d], %s);\r\n", count_textdraws, tData[i][T_UseBox] ? "true" : "false");
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawBoxColor(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_BoxColor]);
					fwrite(File, tmpstring);

					if(tData[i][T_PreviewModel] > -1) {
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetPreviewModel(Textdraw[%d], %d);\r\n", count_textdraws, tData[i][T_PreviewModel]);
					    fwrite(File, tmpstring);
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetPreviewRot(Textdraw[%d], %f, %f, %f, %f);\r\n", count_textdraws, tData[i][PMRotX], tData[i][PMRotY], tData[i][PMRotZ], tData[i][PMZoom]);
					    fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "TextDrawSetSelectable(Textdraw[%d], %s);\r\n", count_textdraws, tData[i][T_Selectable] ? "true" : "false");
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
		            if(!tData[i][T_Created] || tData[i][T_Mode] != true) continue;

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
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetProportional(playerid, PlayerTextdraw[%d], %s);\r\n", count_textdraws, tData[i][T_Proportional] ? "true" : "false");
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetShadow(playerid, PlayerTextdraw[%d], %d);\r\n", count_textdraws, tData[i][T_Shadow]);
					fwrite(File, tmpstring);

				    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawUseBox(playerid, PlayerTextdraw[%d], %s);\r\n", count_textdraws, tData[i][T_UseBox] ? "true" : "false");
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
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetSelectable(playerid, PlayerTextdraw[%d], %s);\r\n", count_textdraws, tData[i][T_Selectable] ? "true" : "false");
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