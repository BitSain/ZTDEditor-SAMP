#include <a_samp>

main(){}

public OnGameModeInit(){
	UsePlayerPedAnims();
	EnableStuntBonusForAll(false);
	ShowPlayerMarkers(false);
	ShowNameTags(true);

	SetGameModeText("ZTDEditor SAMP | Continued by BitSain");
	return true;
}