#include <sourcemod>
#include <cstrike>
#include <morecolors>

#pragma semicolon 1

ConVar IsPluginEnabled = null;
ConVar ResetShowToAll = null;

public Plugin myinfo = {
	name = "ResetScore",
	author = "Akash Purandare",
	description = "Plugin for players to allow resetting their score with !rs",
	version = "1.0.0",
	url = "https://fegaming.xyz"
};

public void OnPluginStart(){
	IsPluginEnabled = CreateConVar("sm_resetscore_enabled", "1", "Enable/disable reset score plugin", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	ResetShowToAll = CreateConVar("sm_resetscore_showall", "1", "Print to all when any player resets score", FCVAR_PROTECTED, true, 0.0, true, 1.0);

	// HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy); 
	HookConVarChange(IsPluginEnabled, PluginStatusChanged);
	LoadTranslations("reset-score.phrases");
	RegConsoleCmd("rs", CommandResetScore);

}
public Action CommandResetScore(int client, int args)
{
	if(!GetConVarInt(IsPluginEnabled)) {
		return Plugin_Handled;
	}
	if (client <= 0 || client >= MaxClients) {
		LogError("%t", "ErrClientID", client);
		return Plugin_Handled;
	}

	char playerName[64];
	if (!GetClientName(client, playerName, 64)) {
		LogError("Failed to get client name for ID [%d]", client);
		return Plugin_Handled;
	}

	SetEntProp(client, Prop_Data, "m_iFrags", 0);
	SetEntProp(client, Prop_Data, "m_iDeaths", 0);
	CS_SetMVPCount(client, 0);
	CS_SetClientAssists(client, 0);
	CS_SetClientContributionScore(client, 0);

	
	if (GetConVarInt(ResetShowToAll) == 1) {
		CPrintToChatAll("%t", "PlayerResetScoreAllNotify", playerName);	
	} else {
		CReplyToCommand(client, "%t", "PlayerResetScoreReply");
	}
	return Plugin_Handled;
}

public void PluginStatusChanged(ConVar isPluginEnabled, char[] oldValue, char[] newValue)
{
	int newVal = StringToInt(newValue);

	if (newVal == 1) {
		LogMessage("%t", "PluginEnabledLog");
	}
	else
	{
		LogMessage("%t", "PluginDisabledLog");
	}
}