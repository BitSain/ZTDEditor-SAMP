/*
	 	BY BITSAIN
 	*  -> TextDraw Convert
 	*  100% for Textdraw is Converted
	*	THIS FILE IS FINALIZED. THERE MAY BE BUGS, ERRORS OR OTHER LIKE.
 */

stock ImportTextDraws(playerid){
	new dir:dHandle = dir_open("./scriptfiles/"IMPORT_DIRECTORY);
	if(!dHandle){
		SendClientMessage(playerid, MSG_COLOR, "[ZTDE]: Error opening directory to list files");
		return false;
	}
	new item[40], itype;
	new tempmap[64];
	new line[1024];
	new fcount;
	new buffer[750], pos = -1, TDType = -1;

	// Create a load list.
	while(dir_list(dHandle, item, itype)) {
   		if(itype != FM_DIR) {
			format(line, sizeof(line), "%s\n%s", item, line);
			fcount++;
	    }
	}
	dir_close(dHandle);

	// Found import files
	if(fcount > 0) {
        inline Select(spid, sdialogid, sresponse, slistitem, string:stext[]) {
            #pragma unused slistitem, sdialogid, spid
			// Selected a file
            if(sresponse) {
				SendClientMessage(playerid, MSG_COLOR, "[ZTDE]: The import has started, it may take time depending on the number of textdraws.");

				format(tempmap, 64, IMPORT_DIRECTORY2, stext);

				new File:f;
				new tdid = 0, 
						icount = 0,
							gcount = 0, 
								pcount = 0;

				f = fopen(tempmap, io_read);
				if(!f){
					SendClientMessage(playerid, MSG_COLOR, "[ZTDE]: Error opening file for reading");
					return false;
				}

				// Read lines and import data
				while(fread(f, buffer)) {
			        StripNewLine(buffer);

			        if((pos = strfind(buffer, "TextDrawCreate", true)) != -1) {
			            new Float: x, Float: y;
			            pos = strfind(buffer, "(", false), strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1))), sscanf(buffer, "p<,>ff", x, y);
			            pos = strfind(buffer, "\"", false), strdel(buffer, 0, pos + 1);
			            pos = strfind(buffer, "\");", false), strdel(buffer, pos, strlen(buffer));
			            TDType = 1;
			            if(isnull(buffer)) buffer[0] = '_', pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));

			            if(icount == 0) CreateTD(playerid, x, y, buffer);
			            else if(icount > 0) tdid++, CreateTD(playerid, x, y, buffer);
			            icount++;

			            gcount++;
			        }

			        if((pos = strfind(buffer, "CreatePlayerTextDraw", true)) != -1) {
			            new Float: x, Float: y;
			            pos = strfind(buffer, ",", false), strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1))), sscanf(buffer, "p<,>ff", x, y);
			            pos = strfind(buffer, "\"", false), strdel(buffer, 0, pos + 1);
			            pos = strfind(buffer, "\");", false), strdel(buffer, pos, strlen(buffer));
			            TDType = 2;
			            if(isnull(buffer)) buffer[0] = '_', pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));

			            if(icount == 0) CreateTD(playerid, x, y, buffer, 1);
			            else if(icount > 0) tdid++, CreateTD(playerid, x, y, buffer, 1);
			            icount++;

			            pcount++;
			        }

			        if(TDType == 1) { // Global
			            if((pos = strfind(buffer, "TextDrawLetterSize", true)) != -1) {
			                new Float: x, Float: y;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>ff", x, y);

			                tData[tdid][T_XSize] = x;
			                tData[tdid][T_YSize] = y;
			            }

			            if((pos = strfind(buffer, "TextDrawTextSize", true)) != -1) {
			                new Float: x, Float: y;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>ff", x, y);

			                tData[tdid][T_TextSizeX] = x;
			                tData[tdid][T_TextSizeY] = y;
			            }

			            if((pos = strfind(buffer, "TextDrawAlignment", true)) != -1) {
			                new align[32];
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>s[32]", align);

			                if(IsNumeric(align))
					  			tData[tdid][T_Alignment] = strval(align);
			            }

			            if((pos = strfind(buffer, "TextDrawColor", true)) != -1) {
			                new col;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X')) sscanf(buffer, "p<,>h", col);
			                else sscanf(buffer, "p<,>d", col);
			                
			               	tData[tdid][T_Color] = col;
			            }

			            if((pos = strfind(buffer, "TextDrawUseBox", true)) != -1) {
			                new use;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>l", use);

			               	tData[tdid][T_UseBox] = use;
			            }

			            if((pos = strfind(buffer, "TextDrawBoxColor", true)) != -1) {
			                new color;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X'))
			                    sscanf(buffer, "p<,>h", color);
			                else
			                    sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BoxColor] = color;
			            }

			            if((pos = strfind(buffer, "TextDrawSetShadow", true)) != -1) {
			                new size;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Shadow] = size;
			            }

			            if((pos = strfind(buffer, "TextDrawSetOutline", true)) != -1) {
			                new size;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Outline] = size;
			            }

			            if((pos = strfind(buffer, "TextDrawBackgroundColor", true)) != -1) {
			                new color ;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));

			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X'))
			                    sscanf(buffer, "p<,>h", color );
			                else
			                    sscanf(buffer, "p<,>d", color );

			                tData[tdid][T_BackColor] = color;
			            }

			            if((pos = strfind(buffer, "TextDrawFont", true)) != -1) {
			                new font[32];
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>s[32]", font);

			                if(IsNumeric(font))
			                	tData[tdid][T_Font] = strval(font);
			            }

			            if((pos = strfind(buffer, "TextDrawSetProportional", true)) != -1) {
			                new set;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Proportional] = set;
			            }

			            if((pos = strfind(buffer, "TextDrawSetSelectable", true)) != -1) {
			                new set;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Selectable] = set;//== true ? (1) : (0);
			            }

			            if((pos = strfind(buffer, "TextDrawSetPreviewModel", true)) != -1) {
			                new modelindex;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", modelindex);

			                tData[tdid][T_PreviewModel] = modelindex;
			            }

			            if((pos = strfind(buffer, "TextDrawSetPreviewRot", true)) != -1) {
			                new Float: fRotX, Float: fRotY, Float: fRotZ, Float: fZoom;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>ffff", fRotX, fRotY, fRotZ, fZoom);

							tData[tdid][PMRotX] = fRotX;
							tData[tdid][PMRotY] = fRotY;
							tData[tdid][PMRotZ] = fRotZ;
							tData[tdid][PMZoom] = fZoom;
			            }

			            /*if((pos = strfind(buffer, "TextDrawSetPreviewVehCol", true)) != -1) {
			                new r1, r2;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>dd", r1, r2);
			                
			                //TDSetPreviewVehCol(tdid, r1, r2);
			            }*/
			        }
			        else if(TDType == 2) { // Player
			            if((pos = strfind(buffer, "PlayerTextDrawLetterSize", true)) != -1) {
			                new Float: x, Float: y;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>ff", x, y);

							tData[tdid][T_XSize] = x;
							tData[tdid][T_YSize] = y;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawTextSize", true)) != -1) {
			                new Float: x, Float: y;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>ff", x, y);

							tData[tdid][T_TextSizeX] = x;
							tData[tdid][T_TextSizeY] = y;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawAlignment", true)) != -1) {
			                new alignment[32];
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>s[32]", alignment);

			                if(IsNumeric(alignment))
			                	tData[tdid][T_Alignment] = strval(alignment);
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawColor", true)) != -1) {
			                new color;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X'))
			                    sscanf(buffer, "p<,>h", color);
			                else
			                    sscanf(buffer, "p<,>d", color);
			                
			                tData[tdid][T_Color] = color;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawUseBox", true)) != -1) {
			                new use;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>l", use);

			                tData[tdid][T_UseBox] = use;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawBoxColor", true)) != -1) {
			                new color;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                
			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X')) sscanf(buffer, "p<,>h", color);
			                else sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BoxColor] = color;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetShadow", true)) != -1) {
			                new size;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Shadow] = size;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetOutline", true)) != -1) {
			                new size;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", size);

			                tData[tdid][T_Outline] = size;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawBackgroundColor", true)) != -1) {
			                new color;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));

			                if(buffer[0] == '0' && (buffer[1] == 'x' || buffer[1] == 'X')) sscanf(buffer, "p<,>h", color);
			                else sscanf(buffer, "p<,>d", color);

			                tData[tdid][T_BackColor] = color;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawFont", true)) != -1) {
			                new font[32];
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>s[32]", font);

			                if(IsNumeric(font))
			               	 	tData[tdid][T_Font] = strval(font);
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetProportional", true)) != -1) {
			                new set;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Proportional] = set;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetSelectable", true)) != -1) {
			                new set;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>l", set);

			                tData[tdid][T_Selectable] = set; //== true ? (1) : (0);
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetPreviewModel", true)) != -1) {
			                new modelindex;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>d", modelindex);

			                tData[tdid][T_PreviewModel] = modelindex;
			            }

			            if((pos = strfind(buffer, "PlayerTextDrawSetPreviewRot", true)) != -1) {
			                new Float: fRotX, Float: fRotY, Float: fRotZ, Float: fZoom;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>ffff", fRotX, fRotY, fRotZ, fZoom);

							tData[tdid][PMRotX] = fRotX;
							tData[tdid][PMRotY] = fRotY;
							tData[tdid][PMRotZ] = fRotZ;
							tData[tdid][PMZoom] = fZoom;
			            }

			            /*if((pos = strfind(buffer, "PlayerTextDrawSetPreviewVehCol", true)) != -1){
			                new r1, r2;
			                pos = strfind(buffer, ",", false),  strdel(buffer, 0, pos + ((buffer[pos + 1] == ' ') ? (2) : (1)));
			                pos = strfind(buffer, ");", false), strdel(buffer, pos, strlen(buffer));
			                sscanf(buffer, "p<,>dd", r1, r2);

			                // PTDSetPreviewVehCol(playerid, tdid, r1, r2);
			            }*/
			        }
			    }

				Convert_UpdateTextDraws();
				Convert_SaveAll();

				format(buffer, sizeof(buffer), "[ZTDE]: %d TextDraws were imported.", icount);
				SendClientMessage(playerid, MSG_COLOR, buffer);

				format(buffer, sizeof(buffer), "[ZTDE]: %d Global TextDraws | %d Player TextDraws", gcount, pcount);
				SendClientMessage(playerid, MSG_COLOR, buffer);

				// Were done importing
				fclose(f);
            }
		}
        Dialog_ShowCallback(playerid, using inline Select, DIALOG_STYLE_LIST, "[ZTDEditor] Import TextDraws", line, "Select", "Cancel");
	}
	else {
		SendClientMessage(playerid, MSG_COLOR, "[ZTDE]: There are no Textdraws to be imported.");
	}
	return true;
}

stock CreateTD(playerid, Float:x, Float:y, const text[], mode = 0) {
	for(new i = 0; i < MAX_TEXTDRAWS; i++){
		if(!tData[i][T_Created]) {
			ClearTextdraw(i);
			CreateDefaultTextdraw(i);
            pData[playerid][P_CurrentTextdraw] = i;
			tData[i][T_X] = x; tData[i][T_Y] = y;
			tData[i][T_Mode] = mode;
			format(tData[i][T_Text], 1536, "%s", text);
			UpdateTextdraw(i);
            break;
        }
    }
    return true;
}

stock Convert_UpdateTextDraws(){
	for(new i; i < MAX_TEXTDRAWS; i++)
		if(tData[i][T_Created]) UpdateTextdraw(i);
	return true;
}

stock Convert_SaveAll(){
	for(new tdid = 0; tdid < MAX_TEXTDRAWS; tdid++){
		if(!tData[tdid][T_Created]) continue;

	 	SaveTDData(tdid, "T_Text");
		SaveTDData(tdid, "T_Alignment");
		SaveTDData(tdid, "T_Color");
		SaveTDData(tdid, "T_Font");
		SaveTDData(tdid, "T_X"); 
		SaveTDData(tdid, "T_Y");
		SaveTDData(tdid, "T_XSize"); 
		SaveTDData(tdid, "T_YSize");
		SaveTDData(tdid, "T_TextSizeX"); 
		SaveTDData(tdid, "T_TextSizeY");
		SaveTDData(tdid, "T_UseBox");
		SaveTDData(tdid, "T_BoxColor");
		SaveTDData(tdid, "T_Shadow");
		SaveTDData(tdid, "T_Outline");
		SaveTDData(tdid, "T_BackColor");
		SaveTDData(tdid, "T_Proportional");
		SaveTDData(tdid, "T_Selectable");
	}
}