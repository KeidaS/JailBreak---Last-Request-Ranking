#pragma semicolon 1


#include <sourcemod>
#include <sdktools>


public Plugin myinfo = 
{
	name = "Lr Ranking",
	author = "KeidaS",
	description = "Ranking for LRs (sm_hosties & MyJailbreak)",
	version = "1.0",
	url = "foro.hermandadfenix.es"
};

Handle db = INVALID_HANDLE;

bool playerReaded[MAXPLAYERS + 1] = false;

char queryBuffer[3096];

int lrs[MAXPLAYERS + 1];

ConVar gc_minPlayersLrRank;

public void OnPluginStart()
{
	gc_minPlayersLrRank = CreateConVar("min_players", "10", "Minimum players online to count the LR on Ranking");
	AutoExecConfig(true, "lr_rank");
	RegConsoleCmd("lrrank", Show_rank, "Shows LR ranking");
	ConnectDB();
}

public void ConnectDB() {
	char error[255];
	db = SQL_Connect("lr_rank", true, error, sizeof(error));
	
	if (db == INVALID_HANDLE) {
		LogError("ERROR CONNECTING TO THE DB"); 
	} else {
		Format(queryBuffer, sizeof(queryBuffer), "CREATE TABLE IF NOT EXISTS lr_rank (steamid VARCHAR(32) PRIMARY KEY NOT NULL, name varchar(64) NOT NULL, lrs INTEGER)");
		SQL_TQuery(db, ConnectDBCallback, queryBuffer);
	}
}
public void ConnectDBCallback(Handle owner, Handle hndl, char[] error, any data) {
	if (hndl == INVALID_HANDLE) {
		LogError("ERROR CREATING THE TABLE");
		LogError("%s", error);
	}
}

public void OnClientPostAdminCheck(int client) {
	char query[254];
	char steamID[32];
	if (!IsFakeClient(client)) {
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
		Format(query, sizeof(query), "SELECT lrs FROM lr_rank WHERE steamid = '%s'", steamID);
		SQL_TQuery(db, OnClientPostAdminCheckCallback, query, GetClientUserId(client));
	}
}

public void OnClientPostAdminCheckCallback(Handle owner, Handle hndl, char[] error, any data) {
	int client = GetClientOfUserId(data);
	if (hndl == INVALID_HANDLE) {
		LogError("ERROR GETING THE LRs");
		LogError("%i", error);
	} else if (!SQL_GetRowCount(hndl) || !SQL_FetchRow(hndl)) {
		lrs[client] = 0;
		playerReaded[client] = true;
	} else {
		lrs[client] = SQL_FetchInt(hndl, 0);
		playerReaded[client] = true;
	}
}

public int OnAvailableLR(int Announced) {
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i) && (!IsFakeClient(i)) && IsPlayerAlive(i)) if (GetClientTeam(i) == 2)
	{
		if (GetAllPlayersCount() >= gc_minPlayersLrRank.IntValue) 
		{
			if (lrs[i] == 0) {
				InsertClientToTable(i);
			} else {
				UpdateClientToTable(i);
			}
		}
	}
}

public void InsertClientToTable(client) {
	char query[254];
	char steamID[32];
	char name[64];
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	GetClientName(client, name, sizeof(name));
	Format(query, sizeof(query), "INSERT INTO lr_rank VALUES ('%s', '%s', 1)", steamID, name);
	SQL_TQuery(db, InsertClientToTableCallback, query, GetClientUserId(client));
}

public void InsertClientToTableCallback(Handle owner, Handle hndl, char[] error, any data) {
	int client = GetClientOfUserId(data);
	if (hndl == INVALID_HANDLE) {
		LogError("ERROR ADDING USER ON TABLE");
		LogError("%i", error);
	} else {
		lrs[client] = 1;
	}
}

public void UpdateClientToTable(client) {
	char query[254];
	char steamID[32];
	char name[64];
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	GetClientName(client, name, sizeof(name));
	Format(query, sizeof(query), "UPDATE lr_rank SET lrs = '%i', name= '%s' WHERE steamid = '%s'" , lrs[client] + 1, name, steamID);
	SQL_TQuery(db, UpdateClientToTableCallback, query, GetClientUserId(client));
}

public void UpdateClientToTableCallback(Handle owner, Handle hndl, char[] error, any data) {
	int client = GetClientOfUserId(data);
	if (hndl == INVALID_HANDLE) {
		LogError("ERROR UPDATING USER ON TABLE");
		LogError("%i", error);
	} else {
		lrs[client] = lrs[client] + 1;
	}
}

public Action Show_rank(int client, int args) {
	char query[254];
	PrintToChat(client, "You won: %i LRs", lrs[client]);
	Format(query, sizeof(query), "SELECT name, lrs FROM lr_rank ORDER BY lrs DESC LIMIT 999");
	SQL_TQuery(db, ShowRankCallback, query, GetClientUserId(client));
}

public void ShowRankCallback(Handle owaner, Handle hndl, char[] error, any data) {
	int client = GetClientOfUserId(data);
	if (hndl == INVALID_HANDLE) {
		LogError("ERROR SHOWING THE RANK");
		LogError("%s", error);
	} else {
		int rankPosition;
		int lr_count;
		char name[64];
		char rank[128];
		Menu menu = new Menu(MenuHandler_ShowRank, MenuAction_Start | MenuAction_Select | MenuAction_End);
		menu.SetTitle("LR Ranking");
		while (SQL_FetchRow(hndl)) {
			rankPosition++;
			SQL_FetchString(hndl, 0, name, sizeof(name));
			lr_count = SQL_FetchInt(hndl, 1);
			Format(rank, sizeof(rank), "%i %s - %i LRs", rankPosition, name, lr_count);
			menu.AddItem("Rank", rank);
		}
		menu.ExitButton = true;
		menu.Display(client,MENU_TIME_FOREVER);
	}
}

public int MenuHandler_ShowRank(Menu menu, MenuAction action, int param1, int param2) {
}

public int GetAllPlayersCount() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
	    if (IsClientInGame(i)) {
	        count = count + 1;
	    }
	}
	return count;
}