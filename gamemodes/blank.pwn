#include <a_samp>

main(){}

public OnGameModeInit(){
	UsePlayerPedAnims();
	EnableStuntBonusForAll(false);
	ShowPlayerMarkers(false);
	ShowNameTags(true);

	SetGameModeText("ZTDEditor SAMP | Continued by BitSain");

	// Player Class
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 270.1425, 0, 0, 24, 300, -1, -1);
	return true;
}

public OnGameModeExit(){
	return true;
}

public OnPlayerConnect(playerid){
	return true;
}

public OnPlayerRequestClass(playerid, classid){
	return true;
}

public OnPlayerRequestSpawn(playerid){
	return true;
}

public OnPlayerDisconnect(playerid){
	return true;
}