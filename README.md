# JailBreak---Last-Request-Ranking
Last Request Ranking for JailBreak servers - CS:GO. Works with sm_hosties and MyJailBreak Plugins.

For using this plugin you need to add this to your databses.cfg file (the file is located in \csgo\addons\sourcemod\configs\databases.cfg):

```
"lr_rank"
	{
		"driver"			"mysql"
		"host"				"YOUR HOST"
		"database"			"rank" (you can put what you want)
		"user"				"YOUR USER"
		"pass"				"YOUR PASSWORD"
	}
```




By default, player only obtains points if there are minimum 10 players on the server. To change this value create a file lr_rank.cfg on: ./csgo/cfg/sourcemod/hosties_lr.cfg and add:

"min_players" "VALUE"

![LR Ranking image](https://i.gyazo.com/ba3f67bdd3ad3a65976b42cdb23d7251.png)
