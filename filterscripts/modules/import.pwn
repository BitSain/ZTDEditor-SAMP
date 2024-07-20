/*
	BY BITSAIN
 	*  -> TextDraw Convert
 	*  100% for Textdraw is Converted
	*	THERE MAY BE BUGS, ERRORS OR OTHER LIKE.

	// [Building.]
	* 	NTD files and *Raw TD files are supported!
*/

/*stock ImportProject(playerid){
	new dir:directory = dir_open("./scriptfiles/"IMPORT_DIRECTORY);
	if(!directory){
		ScriptMessage(playerid, "[ZTDE]: Error opening directory to list files");
		return false;
	}
	new item[64], itype,
		filedirectory[64],
		files[1024],
		fcount;

	// Create a load list.
	while(dir_list(directory, item, itype)) {
   		if(itype != FM_DIR) {
   			format(files, sizeof(files), "%s\n%s", item, files);
			fcount++;
	    }
	}
	//strdel(files, strlen(files)-1, strlen(files)); // Delete '\n'

	dir_close(directory);

	// Found import files
	if(fcount > 0) {
        inline Select(spid, sdialogid, sresponse, slistitem, string:stext[]) {
            #pragma unused slistitem, sdialogid, spid
			// Selected a file
            if(sresponse) {
				ScriptMessage(playerid, "[ZTDE]: The import has started, it may take time depending on the number of textdraws.");

				format(filedirectory, sizeof(filedirectory), IMPORT_DIRECTORY2, stext);

				new buffer[750],
						pos = -1,
							tdid = -1,
						gcount = 0,
							pcount = 0;

				if(IsNTDLegacyFile(stext)){
					if(ConvertNTDLegacy(filedirectory)) return true;
					else {
						ScriptMessage(playerid, "[ZTDE]: Unable to import project.");
						ShowTextDrawDialog(playerid, 4);
						return false;
					}
				}
				else if(IsRawTextDrawFile(stext)){
					ImportTextDraws();
				}
			}
		}
	}
	else 
		return ScriptMessage(playerid, "[ZTDE]: There are no Projects to be imported.");
}*/

// [Import System]
//====================================================
/*stock ConvertNTDLegacy(filedirectory[]) { //NTD Legacy File
    new buf[324], 
    		fromFile[324], 
    			toFile[324], 
    				macro[64], 
    			value[258], 
    		len = 0, 
    			tdid = 0, 
    				macroStr[32],
				gcount = 0,
			pcount = 0;

	new File:handle = fopen(filedirectory, io_read);
    if(handle) {
		// Read lines and import data
		if(Iter_Count(zTextList) > 0) 
			return ScriptMessage(playerid, "[ZTDE]: Use the empty project!");

	    Iter_Clear(zTextList);
        while(fread(handle, buf)) {
            len = strlen(buf);
            strdel(buf, (len - 2), len);

            if(!isnull(buf) && sscanf(buf, "P<=>s[64]s[258]", macro, value) == 0) {
                strdel(macro, 0, 3);

                if(!isnull(macro) && sscanf(macro, "P<_>is[32]", tdid, macroStr) == 0 && !isnull(macroStr)) {
                    if(tdid >= 0 && tdid < MAX_TEXTDRAWS)
                        Iter_Add(tData, tdid);
                    else 
                    	continue;

                    if(tdid == (MAX_TEXTDRAWS - 1)) {
                    	ScriptMessage(playerid, "[ZTDE]: TextDraws limit has been reached. The import stopped here.");
						break;
					}

                    if(!strcmp(macroStr, "string", true)) format(tData[tdid][T_Text], 1536, value);
                    else if(!strcmp(macroStr, "data", true)) {
                        sscanf(value, "ffiiiiffiiiiffiiiiiiffffiiis[35]",
                            tData[tdid][T_X], tData[tdid][T_Y], tData[tdid][T_Font], tData[tdid][T_Mode],
                            tData[tdid][T_Outline], tData[tdid][T_Shadow], tData[tdid][T_Size][0], tData[tdid][T_Size][1],
                            tData[tdid][T_Color], tData[tdid][T_BackColor], tData[tdid][T_BoxColor], tData[tdid][T_UseBox], tData[tdid][T_TextSize][0], tData[tdid][T_TextSize][1],
                            tData[tdid][T_Selectable], tData[tdid][T_Alignment], tData[tdid][T_Proportional], tData[tdid][T_PreviewModel], tData[tdid][T_PMColor1], 
                            tData[tdid][T_PMColor2], tData[tdid][PMRotX], tData[tdid][PMRotY], tData[tdid][PMRotZ], tData[tdid][PMZoom],
                            tData[tdid][T_ColorAlpha], tData[tdid][T_BackColorAlpha], tData[tdid][T_BoxColorAlpha]); //, tData[tdid][T_VarName]);

                    	if(tData[tdid][T_Mode])
                    		gcount++;
                    	else pcount++;
                    }
                    else if(!strcmp(macroStr, "bar_data", true)) {
                        //sscanf(value, "fi", tData[tdid][T_BarMaxPercentage], tData[tdid][T_BarDirectory]);
                    }
                }
            }
        }

        fclose(handle);
        UpdateAllTextDraws();

		format(buffer, sizeof(buffer), "[ZTDE]: %i TextDraws were imported from 'Legacy NTD Project'.", (gcount + pcount));
		ScriptMessage(playerid, buffer);

		format(buffer, sizeof(buffer), "[ZTDE]: %i Global TextDraws | %i Player TextDraws", gcount, pcount);
		ScriptMessage(playerid, buffer);

		ScriptMessage(playerid, "[ZTDE]: Saving all textdraws. Wait!");
	    SaveAllTextDraws();
		ScriptMessage(playerid, "[ZTDE]: All textdraws have been saved.");

	    ShowTextDrawDialog(playerid, 4);
        return true;
    }
    else {
		ScriptMessage(playerid, "[ZTDE]: Error opening file for reading");
		return false;
    }
}*/

stock ImportTextDraws(playerid){ //Raw TextDraw file
	new dir:directory = dir_open("./scriptfiles/"IMPORT_DIRECTORY);
	if(!directory){
		ScriptMessage(playerid, "[ZTDE]: Error opening directory to list files");
		return false;
	}
	new item[64], itype,
		filedirectory[64],
		files[1024],
		fcount;

	// Create a load list.
	while(dir_list(directory, item, itype)) {
   		if(itype != FM_DIR) {
   			format(files, sizeof(files), "%s\n%s", item, files);
			fcount++;
	    }
	}
	//strdel(files, strlen(files)-1, strlen(files)); // Delete '\n'

	dir_close(directory);

	// Found import files
	if(fcount > 0) {
        inline Select(spid, sdialogid, sresponse, slistitem, string:stext[]) {
            #pragma unused slistitem, sdialogid, spid
			// Selected a file
            if(sresponse) {
				ScriptMessage(playerid, "[ZTDE]: The import has started, it may take time depending on the number of textdraws.");

				format(filedirectory, sizeof(filedirectory), IMPORT_DIRECTORY2, stext);

				new File:f,
					buffer[750],
						pos = -1,
							tdid = -1,
						gcount = 0,
					pcount = 0;

				f = fopen(filedirectory, io_read);
				if(!f){
					ScriptMessage(playerid, "[ZTDE]: Error opening file for reading");
					return false;
				}

				// Read lines and import data
				if(Iter_Count(zTextList) > 0) return ScriptMessage(playerid, "[ZTDE]: Use the empty project!");

			    Iter_Clear(zTextList);
				while(fread(f, buffer)) {
					if(tdid == (MAX_TEXTDRAWS - 1)){
						ScriptMessage(playerid, "[ZTDE]: TextDraws limit has been reached. The import stopped here.");
						break;
					}
			        StripNewLine(buffer);

			        if((pos = strfind(buffer, "TextDrawCreate", true)) != -1) {
			       	 	tdid++;
	 					static reset[enum_tData];
	 					tData[tdid] = reset;

			            new Float: x, Float: y;
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            pos = strfind(buffer, "(", false), strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1))), sscanf(buffer, "p<,>ff", x, y);
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            pos = strfind(buffer, "\"", false), strdel(buffer, 0, pos + 1);
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            pos = strfind(buffer, "\");", false), strdel(buffer, pos, strlen(buffer));
						//Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            if(isnull(buffer)) buffer[0] = '_', pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
						//Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End

			            CreateDefaultTextDraw(tdid, false, false);
			            ClearTextDraw(tdid);

			            tData[tdid][T_Created] = true;
			            tData[tdid][T_Handler] = Text:-1;
						tData[tdid][T_X] = x, tData[tdid][T_Y] = y;
						format(tData[tdid][T_Text], 1536, buffer);
						tData[tdid][T_Mode] = false;

						#if ZTDE_DEBUG == true
							printf("[IMPORT]: (%d) TextDrawCreate(%.f, %.f, \"%s\");\n", tdid, x, y, buffer);
						#endif

			            gcount++;
			        }

			        if((pos = strfind(buffer, "CreatePlayerTextDraw", true)) != -1) {
			       	 	tdid++;
	 					static reset[enum_tData];
	 					tData[tdid] = reset;

			            new Float: x, Float: y;
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            pos = strfind(buffer, ",", false), strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1))), sscanf(buffer, "p<,>ff", x, y);
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            pos = strfind(buffer, "\"", false), strdel(buffer, 0, pos + 1);
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            pos = strfind(buffer, "\");", false), strdel(buffer, pos, strlen(buffer));
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End
			            if(isnull(buffer)) buffer[0] = '_', pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			            //Debug
			            #if ZTDE_DEBUG_LEVEL != 0
			            	#if ZTDE_DEBUG_LEVEL == 1
			            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
			            	#endif
			            #endif
			            //End

			            CreateDefaultTextDraw(tdid, false, false);
			            ClearTextDraw(tdid);

			            tData[tdid][T_Created] = true;
			            tData[tdid][T_Handler] = Text:INVALID_TEXT_DRAW;
						tData[tdid][T_X] = x, tData[tdid][T_Y] = y;
						format(tData[tdid][T_Text], 1536, buffer);
						tData[tdid][T_Mode] = true;

						#if ZTDE_DEBUG == true
							printf("[IMPORT]: (%d) CreatePlayerTextDraw(all, %.f, %.f, \"%s\");\n", tdid, x, y, buffer);
						#endif

			            pcount++;
			        }

			        if(tdid == -1 || !tData[tdid][T_Created])
			        	continue;

			        Iter_Add(zTextList, tdid);

			        if(!tData[tdid][T_Mode]) { // Global
			            if((pos = strfind(buffer, "TextDrawTextSize", true)) != -1) {
			                new Float: x, Float: y; //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>ff", x, y);

							tData[tdid][T_TextSize][0] = x;
							tData[tdid][T_TextSize][1] = y;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawTextSize(%d, %.f, %.f);\n", tdid, x, y);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawLetterSize", true)) != -1) {
			                new Float: x, Float: y;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>ff", x, y);

			                tData[tdid][T_Size][0] = x;
			                tData[tdid][T_Size][1] = y;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawLetterSize(%d, %.f, %.f);\n", tdid, x, y);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawAlignment", true)) != -1) {
			                new align[32];
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>s[32]", align);

			                if(IsNumeric(align))
					  			tData[tdid][T_Alignment] = strval(align);

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawAlignment(%d, %d);\n", tdid, strval(align));
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawColor", true)) != -1) {
			                new col;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X')) sscanf(buffer, "p<,>h", col);
			                else sscanf(buffer, "p<,>d", col);
			                
			               	tData[tdid][T_Color] = col;

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawColor(%d, %d);\n", tdid, col);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawUseBox", true)) != -1) {
			                new bool:use;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>l", use);

			               	tData[tdid][T_UseBox] = use;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawUseBox(%d, %d);\n", tdid, use);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawBoxColor", true)) != -1) {
			                new color;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X'))
			                    sscanf(buffer, "p<,>h", color);
			                else
			                    sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BoxColor] = color;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawBoxColor(%d, %d);\n", tdid, color);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawSetShadow", true)) != -1) {
			                new size;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Shadow] = size;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetShadow(%d, %d);", tdid, size);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawSetOutline", true)) != -1) {
			                new size;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Outline] = size;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetOutline(%d, %d);\n", tdid, size);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawBackgroundColor", true)) != -1) {
			                new color;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End

			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X'))
			                    sscanf(buffer, "p<,>h", color);
			                else
			                    sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BackColor] = color;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawBackgroundColor(%d, %d);\n", tdid, color);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawFont", true)) != -1) {
			                new font[32];
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>s[32]", font);

			                if(IsNumeric(font))
			                	tData[tdid][T_Font] = strval(font);

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawFont(%d, %d);\n", tdid, strval(font));
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawSetProportional", true)) != -1) {
			                new bool:set = false;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Proportional] = set;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetProportional(%d, %s);\n", tdid, set == true ? ("true") : ("false"));
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawSetSelectable", true)) != -1) {
			                new bool:set;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Selectable] = set;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetSelectable(%d, %d);\n", tdid, set);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawSetPreviewModel", true)) != -1) {
			                new modelindex;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>d", modelindex);

			                tData[tdid][T_PreviewModel] = modelindex;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetPreviewModel(%d, %d);\n", tdid, modelindex);
							#endif
			            }

			            if((pos = strfind(buffer, "TextDrawSetPreviewRot", true)) != -1) {
			                new Float: fRotX, Float: fRotY, Float: fRotZ, Float: fZoom;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>ffff", fRotX, fRotY, fRotZ, fZoom);

							tData[tdid][PMRotX] = fRotX;
							tData[tdid][PMRotY] = fRotY;
							tData[tdid][PMRotZ] = fRotZ;
							tData[tdid][PMZoom] = fZoom;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetPreviewRot(%d, %.f, %.f, %.f, %.f);\n", tdid, fRotX, fRotY, fRotZ, fZoom);
							#endif
			            }

			            /*if((pos = strfind(buffer, "TextDrawSetPreviewVehCol", true)) != -1) {
			                new r1, r2;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>dd", r1, r2);
			                
			                //TDSetPreviewVehCol(tdid, r1, r2);
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: TextDrawSetPreviewVehCol(%d, %d, %d);\n", tdid, r1, r2);
							#endif
			            }*/
			        }
			        else if(tData[tdid][T_Mode]) { // Player
			            if((pos = strfind(buffer, "PlayerTextDrawTextSize", true)) != -1) {
			                new Float: x, Float: y;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>ff", x, y);

							tData[tdid][T_TextSize][0] = x;
							tData[tdid][T_TextSize][1] = y;

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawTextSize(all, %d, %.f, %.f);\n ", tdid, x, y);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawLetterSize", true)) != -1) {
			                new Float: x, Float: y;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>ff", x, y);

							tData[tdid][T_Size][0] = x;
							tData[tdid][T_Size][1] = y;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawLetterSize(all, %d, %.f, %.f);", tdid, x, y);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawAlignment", true)) != -1) {
			                new alignment[32];
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>s[32]", alignment);

			                if(IsNumeric(alignment))
			                	tData[tdid][T_Alignment] = strval(alignment);

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawAlignment(all, %d, %d);\n", tdid, strval(alignment));
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawColor", true)) != -1) {
			                new color;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X'))
			                    sscanf(buffer, "p<,>h", color);
			                else
			                    sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_Color] = color;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawColor(all, %d, %d);\n", tdid, color);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawUseBox", true)) != -1) {
			                new bool:use;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>l", use);

			                tData[tdid][T_UseBox] = use;

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawUseBox(all, %d, %d);\n", tdid, use);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawBoxColor", true)) != -1) {
			                new color;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X')) sscanf(buffer, "p<,>h", color);
			                else sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BoxColor] = color;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawBoxColor(all, %d, %d);\n", tdid, color);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetShadow", true)) != -1) {
			                new size;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Shadow] = size;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetShadow(all, %d, %d);\n", tdid, size);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetOutline", true)) != -1) {
			                new size;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Outline] = size;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetOutline(all, %d, %d);\n", tdid, size);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawBackgroundColor", true)) != -1) {
			                new color;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End

			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X')) sscanf(buffer, "p<,>h", color);
			                else sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BackColor] = color;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawBackgroundColor(all, %d, %d);\n", tdid, color);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawFont", true)) != -1) {
			                new font[32];
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>s[32]", font);

			                if(IsNumeric(font))
			               	 	tData[tdid][T_Font] = strval(font);

							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawFont(all, %d, %d);\n", tdid, strval(font));
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetProportional", true)) != -1) {
			                new bool:set = false;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Proportional] = set;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetProportional(all, %d, %s);\n", tdid, set == true ? ("true") : ("false"));
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetSelectable", true)) != -1) {
			                new bool: set;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Selectable] = set; //== true ? (1) : (0);
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetSelectable(all, %d, %d);\n", tdid, set);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetPreviewModel", true)) != -1) {
			                new modelindex;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>d", modelindex);

			                tData[tdid][T_PreviewModel] = modelindex;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetPreviewModel(all, %d, %d);\n", tdid, modelindex);
							#endif
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetPreviewRot", true)) != -1) {
			                new Float: fRotX, Float: fRotY, Float: fRotZ, Float: fZoom;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>ffff", fRotX, fRotY, fRotZ, fZoom);

							tData[tdid][PMRotX] = fRotX;
							tData[tdid][PMRotY] = fRotY;
							tData[tdid][PMRotZ] = fRotZ;
							tData[tdid][PMZoom] = fZoom;
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetPreviewRot(all, %d, %.f, %.f, %.f, %.f);\n", tdid, fRotX, fRotY, fRotZ, fZoom);
							#endif
			            }

			            /*if((pos = strfind(buffer, "PlayerTextDrawSetPreviewVehCol", true)) != -1){
			                new r1, r2;
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("\n[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                //Debug
				            #if ZTDE_DEBUG_LEVEL != 0
				            	#if ZTDE_DEBUG_LEVEL == 1
				            		printf("[IMPORT (DEBUG 1)]: %d: %s", tdid, buffer);
				            	#endif
				            #endif
				            //End
			                sscanf(buffer, "p<,>dd", r1, r2);

			                // PTDSetPreviewVehCol(playerid, tdid, r1, r2);
							#if ZTDE_DEBUG == true
								printf("[IMPORT]: PlayerTextDrawSetPreviewRot(all, %d, %d, %d);\n", tdid, r1, r2);
							#endif
			            }*/
			        }
			    }
				// Were done importing
				fclose(f);

				UpdateAllTextDraws();

				format(buffer, sizeof(buffer), "[ZTDE]: %i TextDraws were imported.", (gcount + pcount));
				ScriptMessage(playerid, buffer);

				format(buffer, sizeof(buffer), "[ZTDE]: %i Global TextDraws | %i Player TextDraws", gcount, pcount);
				ScriptMessage(playerid, buffer);

				ScriptMessage(playerid, "[ZTDE]: Saving all textdraws. Wait!");
			    SaveAllTextDraws();
				ScriptMessage(playerid, "[ZTDE]: All textdraws have been saved.");

			    ShowTextDrawDialog(playerid, 4);
				return true;
            }
            else
            	return ShowTextDrawDialog(playerid, 4, pData[playerid][P_DialogPage]);
		}
        Dialog_ShowCallback(playerid, using inline Select, DIALOG_STYLE_LIST, "[ZTDEditor] Import TextDraws", files, "Import", "Cancel");
	 	return true;
	}
	else 
		return ScriptMessage(playerid, "[ZTDE]: There are no Textdraws to be imported.");
}