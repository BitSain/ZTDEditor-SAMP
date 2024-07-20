// [ZTDE Utils]
//====================================================
stock bool:IsProjectFile(const filename[]) { //By BitSain
    new ending[5];
    strmid(ending, filename, strlen(filename) - 4, strlen(filename));
    return (strcmp(ending, ".tde") == 0);
}

stock bool:IsNTDLegacyFile(filedirectory){
	new ending[5];
    strmid(ending, filename, strlen(filename) - 5, strlen(filename));
    return (strcmp(ending, ".ntdp") == 0);
}

stock GetFileExtension(filedirectory){
	new ending[5];
    strmid(ending, filedirectory, strlen(filedirectory) - 5, strlen(filedirectory));
    pos = strfind(ending, ".", false);
    strdel(ending, pos-1, strlen(filedirectory));
}

stock GetFileExtensionType(filedirectory){
	new type = FILE_EXTENSION_UNKNOWN;
	for(new i; i < sizeof FileExtensions; i++){
		if(GetFileExtension(filedirectory) == FileExtensions[i][FILE_EXTENSION]){
			type = FILE_EXTENSION_TYPE;
			break;
		}
	}
	return type;
}

// [OTHERS]
//====================================================
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