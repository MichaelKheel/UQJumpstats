/*
v2.39 = Borjomi edited
v1.00 = Переделаны пункты меню, убраны лишние.
v1.01 = Добавлены Block Top / Weapon Top
v1.02 = Вырезано, Map top, my top
v1.03 = Вырезано, все связанное с kz_sql = 0
v1.04 = Уничтожены все квары
v1.05 = Координальное переделывание главного меню и побочного (иммитирование 2 страницы), но на самом деле, отдельное меню, нового типа
v1.06 = Чтобы не писать для каждого пункта меню кнопку, создан отсек default
v1.07 = Чтобы везде было одинаково, создан Cosy_TypeList в _const.inc
v1.08 = Все лишние вырезано, все, что возможно, было оптимизировано.
*/

#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <sqlx>
#include <uq_jumpstats_stocks.inc>

#define PLUGIN "UQJT"
#define VERSION "1.10"
#define AUTHOR "MichaelKheel"

#define NTOP 20 //Num of places in dat tops
#define NSHOW 9 //Num of places to show in top

new sz_Menu_Weapon[33], bool:sz_Menu_Block[33];
new Trie:JumpData,Trie:JumpData_Block;
new bool:loading_tops[33];
new sv_airaccelerate;

new Cosy_TypeList[24][] = {
	"lj",
	"cj",
	"dcj",
	"mcj",
	"bj",
	"sbj",
	"wj",
	"bhopinduck",
	"ladder",
	"ldbhop",
	"realldbhop",
	"scj",
	"dscj",
	"mscj",
	"dropcj",
	"dropdcj",
	"dropmcj",
	"dropbj",
	"dropscj",
	"dropdscj",
	"dropmscj",
	"upbj",
	"upsbj",
	"upbhopinduck"
};

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_menucmd(register_menuid("StatsTopMenu1"), 1023, "TopMenu1");
	register_clcmd( "say /ljtop",	"LjTopMenu" );

	sv_airaccelerate = get_cvar_pointer("sv_airaccelerate");
	set_task(0.3, "stats_sql");
}

public plugin_cfg()
{
	JumpData = TrieCreate();
	JumpData_Block = TrieCreate();
}

public client_connect(id)
{
	loading_tops[id]=false;
}

public read_tops(id, type[], type_num, show_mode, wpn_rank, bool:block)
{
	new sql_query[512],cData[25];
	formatex(cData,17,type);
	cData[19]=id;
	cData[20]=show_mode;

	if(weapon_maxspeed(wpn_rank) == 250)
		cData[21]=0;
	else
		cData[21]=1;

	cData[22]=weapon_maxspeed(wpn_rank);
	
	if(block)
		cData[23]=1;
	else
		cData[23]=0;

	formatex(sql_query, 511, "SELECT pid FROM `%s%s` WHERE type='%s' and pspeed=%d LIMIT 10", block ? "uq_block_tops" : "uq_jumps", get_pcvar_num(sv_airaccelerate) == 100 ? "_100aa" : "", type, weapon_maxspeed(wpn_rank));
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle_type_place", sql_query, cData, 24);
}

public QueryHandle_type_place(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	
	if(iFailState != TQUERY_SUCCESS)
	{
		log_amx("uq_jumpstats: SQL Error #%d - %s", iErrnum, szError);
		return PLUGIN_HANDLED;
	}
	
	new id=cData[19];
	new mode=cData[20];
	new pspeed=cData[22];
	new block=cData[23];
	
	formatex(cData,17,cData);
	
	new i=0;
	while(SQL_MoreResults(hQuery))
	{
		i++;
		SQL_NextRow(hQuery);
	}
	
	SQL_FreeHandle(hQuery);
	
	new sql_query[512],bData[26];
	formatex(bData,17,cData);
	bData[19]=id;
	bData[20]=i;
	bData[21]=mode;
	bData[23]=pspeed;
	if(block)
		bData[24]=1;
	else
		bData[24]=0;
	
	set_hudmessage(255, 0, 109, 0.05, 0.5, 0, 6.0, 0.3);
	show_hudmessage(id, "Loading %s %s for Weapon with maxspeed: %d - 0%%", cData, block ? "Block Top" : "Top", pspeed);
	
	formatex(sql_query, 511, "SELECT * FROM %s%s WHERE type='%s' and pspeed=%d ORDER BY %sdistance DESC LIMIT 10", block ? "uq_block_tops" : "uq_jumps", get_pcvar_num(sv_airaccelerate) == 100 ? "_100aa" : "", cData,pspeed, block ? "block DESC," : "", NSHOW);
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle_LoadTops", sql_query, bData, 25);
	
	return PLUGIN_CONTINUE;
}

public QueryHandle_LoadTops(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_amx("uq_jumpstats: SQL Error #%d - %s", iErrnum, szError);
		return PLUGIN_HANDLED;
	}
	
	new id=cData[19];
	new max_place=cData[20];
	new mode=cData[21];
	new pspeed=cData[23];
	new block_bool=cData[24];
	
	formatex(cData,17,cData);
	
	new t_pspeed[NSHOW+1],pid[NSHOW+1], distance[NSHOW+1], maxspeed[NSHOW+1], prestrafe[NSHOW+1], strafes[NSHOW+1], sync[NSHOW+1], ddbh[NSHOW+1],wpn[NSHOW+1][15], jumpoff[NSHOW+1], block[NSHOW+1];
	new tmp_type;
	
	for(new i = 0; i < 24 ;i++)
	{
		if(equali(cData,Cosy_TypeList[i]))
		{
			tmp_type=i;
		}
	}

	new i=0;
	while(SQL_MoreResults(hQuery))
	{
		pid[i] = SQL_ReadResult(hQuery,0);
		distance[i] = SQL_ReadResult(hQuery,2);
		if(block_bool == 0)
		{
			maxspeed[i] = SQL_ReadResult(hQuery,3);
			prestrafe[i] = SQL_ReadResult(hQuery,4);
			strafes[i] = SQL_ReadResult(hQuery,5);
			sync[i] = SQL_ReadResult(hQuery,6);
			ddbh[i] = SQL_ReadResult(hQuery,7);
			t_pspeed[i] = SQL_ReadResult(hQuery,8);
			SQL_ReadResult(hQuery,9,wpn[i],24);
			pid_in_name(mode,max_place,i,id,cData,t_pspeed[i],tmp_type,pid[i], distance[i], maxspeed[i], prestrafe[i], strafes[i], sync[i], ddbh[i],wpn[i]);
		}
		else
		{
			jumpoff[i] = SQL_ReadResult(hQuery,3);
			block[i] = SQL_ReadResult(hQuery,4);
			t_pspeed[i] = SQL_ReadResult(hQuery,5);
			SQL_ReadResult(hQuery,6,wpn[i],24);
			pid_in_name_block(mode,max_place,i,id,cData,t_pspeed[i],tmp_type,pid[i], distance[i], jumpoff[i], block[i],wpn[i]);
		}
		i++;
		SQL_NextRow(hQuery);
	}
	
	if(i==0)
	{
		if(block_bool == 0)
			tmp_show_tops_weapon(id,cData,tmp_type,weapon_rank(pspeed));
		else
			show_tops_block_weapon_tmp(id,cData,tmp_type, weapon_rank(pspeed));

		switch(mode)
		{
			case 0:
				uqTopmenu1(id,weapon_rank(pspeed), sz_Menu_Block[id]);
			case 1:
				uqTopmenu2(id,weapon_rank(pspeed), sz_Menu_Block[id]);
		}
		loading_tops[id]=false;	
	}
	SQL_FreeHandle(hQuery);
		
	return PLUGIN_CONTINUE;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MENU ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

public LjTopMenu(id)
{
	uqTopmenu1(id, 0, false);
}

public uqTopmenu1(id, weapon, bool:block)
{
	if(weapon > 0)
		sz_Menu_Weapon[id] = weapon;
	else
		sz_Menu_Weapon[id] = 0;

	if(block)
		sz_Menu_Block[id] = true;
	else
		sz_Menu_Block[id] = false;

	new MenuBody[512], len, keys;

	len = format(MenuBody, 511, "\yLongJump Stats ^n");
	len += format(MenuBody[len], 511, "\dType \w/ljsmenu \dto see option menu^n");

	len += format(MenuBody[len], 511-len, "^n\d[\r1\d]\w \wLongJump Top");
	keys |= (1<<0);
	len += format(MenuBody[len], 511-len, "^n\d[\r2\d]\w \wCountJump Top");
	keys |= (1<<1);
	len += format(MenuBody[len], 511-len, "^n\d[\r3\d]\w \wDouble CountJump Top");
	keys |= (1<<2);	
	len += format(MenuBody[len], 511-len, "^n\d[\r4\d]\w \wMulti CountJump Top");
	keys |= (1<<3);		
	len += format(MenuBody[len], 511-len, "^n\d[\r5\d]\w \wBhopJump Top");
	keys |= (1<<4);
	len += format(MenuBody[len], 511-len, "^n\d[\r6\d]\w \wStandUp BhopJump Top");
	keys |= (1<<5);
	if(block)
		len += format(MenuBody[len], 511-len, "^n^n\d[\r7\d]\w \rBlock ON");
	else
		len += format(MenuBody[len], 511-len, "^n^n\d[\r7\d]\w \yBlock OFF");
	keys |= (1<<6);
	if(weapon > 0)
		len += format(MenuBody[len], 511-len, "^n\d[\r8\d]\w \rWeapon %d", weapon_maxspeed(sz_Menu_Weapon[id]));
	else
		len += format(MenuBody[len], 511-len, "^n\d[\r8\d]\w \yWeapon Top");
	keys |= (1<<7);
	len += format(MenuBody[len], 511-len, "^n^n\d[\r9\d]\w \wNext Page");
	keys |= (1<<8);
	len += format(MenuBody[len], 511-len, "^n^n\d[\r0\d]\w \wExit");
	keys |= (1<<9);
	show_menu(id, keys, MenuBody, -1, "StatsTopMenu1");		

	return PLUGIN_HANDLED;
}
public TopMenu1(id, key)
{
	switch((key+1))
	{
		case 7:
		{
			if(sz_Menu_Block[id])
				uqTopmenu1(id, sz_Menu_Weapon[id], false);
			else
				uqTopmenu1(id, sz_Menu_Weapon[id], true);
		}
		case 8:
		{
			uqMainWpnMenu(id);
		}
		case 9:
		{
			uqTopmenu2(id, sz_Menu_Weapon[id], sz_Menu_Block[id]); // next page
		}
		case 10:
		{
			return PLUGIN_HANDLED;
		}
		default:
		{
			read_tops(id,Cosy_TypeList[key], key, 0, sz_Menu_Weapon[id], sz_Menu_Block[id]);
		}
	}
	return PLUGIN_HANDLED;
}

public uqTopmenu2(id, weapon, bool:block)
{
	if(weapon > 0)
		sz_Menu_Weapon[id] = weapon;
	else
		sz_Menu_Weapon[id] = 0;

	if(block)
		sz_Menu_Block[id] = true;
	else
		sz_Menu_Block[id] = false;

	new txt[64];
	formatex(txt, 63, "Weapon: \r%d\w^nBlock: \r%s\w^n^nLongJump Stats ->", weapon_maxspeed(sz_Menu_Weapon[id]), sz_Menu_Block[id] ? "True" : "False");
	new menu = menu_create(txt, "uqTopmenu2Handler");
	

	menu_additem( menu, "WeirdJump Top", "1" );
	menu_additem( menu, "Bhop In Duck Top", "2");
	menu_additem( menu, "LadderJump Top", "3" );
	menu_additem( menu, "Ladder BhopJump Top", "4" );
	menu_additem( menu, "Real Ladder Bhop Top", "5" );
	menu_additem( menu, "StandUp CountJump Top", "6" );
	menu_additem( menu, "Double StandUp CountJump Top", "7" );
	menu_additem( menu, "Multi StandUp CountJump Top", "8");
	menu_additem( menu, "Drop CountJump Top", "10" );
	menu_additem( menu, "Double Drop CountJump Top", "11");
	menu_additem( menu, "Multi Drop CountJump Top", "12");
	menu_additem( menu, "Drop BhopJump Top", "13" );
	menu_additem( menu, "Drop StandUp CountJump Top", "14");
	menu_additem( menu, "Drop Double StandUp CountJump Top", "15");
	menu_additem( menu, "Drop Multi StandUp CountJump Top", "16");
	menu_additem( menu, "Up Bhop Top", "17");
	menu_additem( menu, "Up StandBhop Top", "18");
	menu_additem( menu, "Up Bhop In Duck Top", "19");

	menu_setprop(menu, MPROP_NEXTNAME, "Next");
	menu_setprop(menu, MPROP_BACKNAME, "Back");
	menu_setprop(menu, MPROP_EXITNAME, "Exit");

	menu_display(id, menu, 0);
}

public uqTopmenu2Handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		uqTopmenu1(id, sz_Menu_Weapon[id], sz_Menu_Block[id]);
		return PLUGIN_HANDLED;
	}
	switch(item)
	{
		default: 
		{
			read_tops(id,Cosy_TypeList[item+6], item+6, 1, sz_Menu_Weapon[id], sz_Menu_Block[id]);
		} 
	}
	return PLUGIN_HANDLED;
}

public uqMainWpnMenu(id)
{
	new menu = menu_create("\yStats Top Menu\w", "uqMainWpnMenuHandler");
	
	menu_additem( menu, "Weapon maxspeed - 250", "1" );
	menu_additem( menu, "Weapon maxspeed - 210", "2" );
	menu_additem( menu, "Weapon maxspeed - 220", "3" );
	menu_additem( menu, "Weapon maxspeed - 221", "4" );
	menu_additem( menu, "Weapon maxspeed - 230", "5" );
	menu_additem( menu, "Weapon maxspeed - 235", "6" );
	menu_additem( menu, "Weapon maxspeed - 240", "7" );
	menu_additem( menu, "Weapon maxspeed - 245", "8" );

	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);
}

public uqMainWpnMenuHandler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		default:	
		{
			uqTopmenu1(id, item, sz_Menu_Block[id]);
		}
	}
	return PLUGIN_HANDLED;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Подсчет людей ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

public pid_in_name(mode,max_place,num,id,type[],pspeed,type_num,pid, distance, maxspeed, prestrafe, strafes, sync, ddbh,wpn[])
{
	new sql_query[512],cData[44];
	formatex(cData,17,type);	
	cData[18]=id;
	cData[19]=num;
	cData[20]=pspeed;
	cData[21]=type_num;
	cData[22]=distance;
	cData[23]=maxspeed;
	cData[24]=prestrafe;
	cData[25]=strafes;
	cData[26]=sync;
	cData[27]=ddbh;
	cData[28]=max_place;
	cData[29]=mode;
	
	for(new i=0;i<14;i++)
	{
		formatex(cData[30+i],1,wpn[i]);		
	}
	
	formatex(sql_query, 511, "SELECT name FROM uq_players WHERE id=%d",pid);
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle_pidName", sql_query, cData, 45);
	
}
public QueryHandle_pidName(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_amx("uq_jumpstats: SQL Error #%d - %s", iErrnum, szError);
		return PLUGIN_HANDLED;
	}
	
	new mode,num,type[18],id,type_num,pspeed,max_place,wpn[14];
	new name[33],distance, maxspeed, prestrafe, strafes, sync, ddbh;

	formatex(type,17,cData);
	type_num=cData[21];
	pspeed=cData[20];
	num=cData[19];
	id=cData[18];
	distance=cData[22];
	maxspeed=cData[23];
	prestrafe=cData[24];
	strafes=cData[25];
	sync=cData[26];
	ddbh=cData[27];
	max_place=cData[28];
	mode=cData[29];
	new block;
	for(new i=0;i<14;i++)
	{
		formatex(wpn[i],1,cData[30+i]);
	}
	
	if (!SQL_NumResults(hQuery))
	{
		log_amx("Bug with id=0");
		
		name="unknow";
	}
	else
	{
		SQL_ReadResult(hQuery,0,name,33);
	}

	new Trie:JumpStat;
	JumpStat = TrieCreate();
	
	TrieSetString(JumpStat, "name", name);
	TrieSetCell(JumpStat, "distance", distance);
	TrieSetCell(JumpStat, "maxspeed", maxspeed);
	TrieSetCell(JumpStat, "prestrafe", prestrafe);
	TrieSetCell(JumpStat, "strafes", strafes);
	TrieSetCell(JumpStat, "sync", sync);
	TrieSetCell(JumpStat, "ddbh", ddbh);
	TrieSetCell(JumpStat, "pspeed", pspeed);
	TrieSetString(JumpStat, "wpn", wpn);
	
	new tmp_type[33];
	formatex(tmp_type,32,"%s_%d_%d",type,num,pspeed);
	
	TrieSetCell(JumpData, tmp_type, JumpStat);
	
	SQL_FreeHandle(hQuery);
	
	if(num==max_place-1) 
	{
		tmp_show_tops_weapon(id,type,type_num,weapon_rank(pspeed));
		switch(mode)
		{
			case 0:
				uqTopmenu1(id, weapon_rank(pspeed), sz_Menu_Block[id]);
			case 1:
				uqTopmenu2(id, weapon_rank(pspeed), sz_Menu_Block[id]);
		}
		loading_tops[id]=false;
	}
	else
	{
		new load=100/max_place;
		
		set_hudmessage(255, 0, 109, 0.05, 0.5, 0, 6.0, 0.3);
		show_hudmessage(id, "Loading %s %s for Weapon with maxspeed: %d - %d%%", cData, block ? "Block Top" : "Top", pspeed, (num+2)*load);
	}
	
	return PLUGIN_CONTINUE;
}

public pid_in_name_block(mode,max_place,num,id,type[],pspeed,type_num,pid, distance, jumpoff, block,wpn[])
{
	new sql_query[512],cData[44];
	formatex(cData,17,type);	
	cData[18]=id;
	cData[19]=num;
	cData[20]=pspeed;
	cData[21]=type_num;
	cData[22]=distance;
	cData[23]=jumpoff;
	cData[24]=block;
	cData[25]=max_place;
	cData[26]=mode;
	
	for(new i=0;i<14;i++)
	{
		formatex(cData[27+i],1,wpn[i]);
	}
	
	formatex(sql_query, 511, "SELECT name FROM uq_players WHERE id=%d",pid);
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle_pidName_block", sql_query, cData, 45);
	
}
public QueryHandle_pidName_block(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_amx("uq_jumpstats: SQL Error #%d - %s", iErrnum, szError);
		return PLUGIN_HANDLED;
	}
	
	new block,mode,num,type[18],id,type_num,pspeed,max_place,wpn[14];
	new name[33],distance, Float:jumpoff;

	formatex(type,17,cData);
	type_num=cData[21];
	pspeed=cData[20];
	num=cData[19];
	id=cData[18];
	distance=cData[22];
	jumpoff=cData[23]/1000000.0;
	block=cData[24];
	max_place=cData[25];
	mode=cData[26];
	
	for(new i=0;i<14;i++)
	{
		formatex(wpn[i],1,cData[27+i]);
	}
	
	SQL_ReadResult(hQuery,0,name,33);
	
	new Trie:JumpStat;
	JumpStat = TrieCreate();
	
	TrieSetString(JumpStat, "name", name);
	TrieSetCell(JumpStat, "distance", distance);
	TrieSetCell(JumpStat, "jumpoff", jumpoff);
	TrieSetCell(JumpStat, "block", block);
	TrieSetCell(JumpStat, "pspeed", pspeed);
	TrieSetString(JumpStat, "wpn", wpn);
	
	new tmp_type[33];
	formatex(tmp_type,32,"block_%s_%d_%d",type,num,pspeed);
	
	TrieSetCell(JumpData_Block, tmp_type, JumpStat);
	
	SQL_FreeHandle(hQuery);
	
	if(num==max_place-1) 
	{
		show_tops_block_weapon_tmp(id,type,type_num,weapon_rank(pspeed));
		switch(mode)
		{
			case 0:
				uqTopmenu1(id,weapon_rank(pspeed), sz_Menu_Block[id]);
			case 1:
				uqTopmenu2(id,weapon_rank(pspeed), sz_Menu_Block[id]);
		}
		loading_tops[id]=false;
	}
	else
	{
		new load=100/max_place;
		set_hudmessage(255, 0, 109, 0.05, 0.5, 0, 6.0, 0.3);
		show_hudmessage(id, "Loading %s BlockTop for Weapon with maxspeed: %d - %d%%",type,pspeed,(num+2)*load);
	}
		
	return PLUGIN_CONTINUE;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MOTD ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public show_tops_block_weapon_tmp(id,type[],type_num,wpn_rank)
{	
	static buffer[2368], name[128], len, i;
	new oldblock,Float:find_jumpoff[NTOP+1];
	
	new tmp_oldtype[33];
	new Trie:JS_old, block_for_old;
	
	for( i = 0; i < NSHOW; i++ )
	{
		format(tmp_oldtype, 32, "block_%s_%d_%d", type,i,weapon_maxspeed(wpn_rank));
			
		if(TrieKeyExists(JumpData_Block, tmp_oldtype))
		{	
			TrieGetCell(JumpData_Block, tmp_oldtype, JS_old);
			
			if(i==0) TrieGetCell(JS_old, "block", block_for_old);
			
			TrieGetCell(JS_old, "jumpoff", find_jumpoff[i]);
		}
	}
	
	new Float:minjof=find_min_jumpoff(find_jumpoff);
	oldblock=block_for_old;
	
	len = format(buffer[len], 2367-len,"<STYLE>body{background:#232323;color:#cfcbc2;font-family:sans-serif}table{width:100%%;font-size:12px}</STYLE><table cellpadding=2 cellspacing=0 border=0>");
	len += format(buffer[len], 2367-len, "<tr  align=center bgcolor=#52697B><th width=5%%> # <th width=34%% align=left> Name <th width=20%%> Block <th  width=20%%> Distance <th  width=30%%> Jumpoff <th  width=30%%> Weapon");
	
	new oldjj,jj;
	for( i = 0,jj=1; i < NSHOW; i++ )
	{	
		new Trie:JS;
		new tmp_names[33],tmp_weap_names[33],distance,Float:jumpoff,block;
		new tmp_type[33];
	
		format(tmp_type, 32, "block_%s_%d_%d", type, i,weapon_maxspeed(wpn_rank));
		
		if(TrieKeyExists(JumpData_Block, tmp_type))
		{	
			TrieGetCell(JumpData_Block, tmp_type, JS);
			
			TrieGetCell(JS, "distance", distance);
			TrieGetCell(JS, "jumpoff", jumpoff);
			TrieGetCell(JS, "block", block);
			TrieGetString(JS,"name",tmp_names,32);
			TrieGetString(JS,"wpn",tmp_weap_names,32);
		}
		
		if(oldblock!=block)
		{
			len += format(buffer[len], 2367-len, "<tr><td COLSPAN=9><br></td></tr>");
			
			if((jj%2)==0)
			{
				jj=oldjj;
			}
		}
		if( block == 0)
		{
			len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#2f3030", (i+1), "-", "-", "-", "-", "-");
			i=NSHOW;
		}
		else
		{
			name = tmp_names;
			while( containi(name, "<") != -1 )
				replace(name, 127, "<", "&lt;");
			while( containi(name, ">") != -1 )
				replace(name, 127, ">", "&gt;");
			if(minjof==jumpoff)
			{
				len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d <td> %d.%01d <td><font color=red> %f <td> %s", ((jj%2)==0) ? "" : " bgcolor=#2f3030", (i+1), name,block, (distance/1000000), (distance%1000000/100000), jumpoff,tmp_weap_names);
			}
			else len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d <td> %d.%01d <td> %0.4f <td> %s", ((jj%2)==0) ? "" : " bgcolor=#2f3030", (i+1), name,block, (distance/1000000), (distance%1000000/100000), jumpoff,tmp_weap_names);
		}
		
		oldblock=block;
		oldjj=jj;
		jj++;
	}
	len += format(buffer[len], 2367-len, "</table></body>");
	static strin[34];
	
	if(type_num==9)
	{
		format(strin,33, "Block Top %d hj (maxspeed - %d)",NSHOW,weapon_maxspeed(wpn_rank));
	}
	else format(strin,33, "Block Top %d %s (maxspeed - %d)", NSHOW,type,weapon_maxspeed(wpn_rank));
	
	show_motd(id, buffer, strin);
}

public tmp_show_tops_weapon(id,type[],type_num,wpn_rank)
{	
	static buffer[2368], name[128], len, i;
	
	len = format(buffer[len], 2367-len,"<STYLE>body{background:#232323;color:#cfcbc2;font-family:sans-serif}table{width:100%%;line-height:160%%;font-size:12px}.q{border:1px solid #4a4945}.b{background:#2a2a2a}</STYLE><table cellpadding=2 cellspacing=0 border=0>");
	len += format(buffer[len], 2367-len, "<tr  align=center bgcolor=#52697B><th width=5%%> # <th width=34%% align=left> Name <th width=10%%> Distance <th  width=10%%> MaxSpeed <th  width=11%%> PreStrafe <th  width=9%%> Strafes <th  width=6%%> Sync <th  width=6%%> Weapon");
		
	for( i = 0; i < (NSHOW); i++ )
	{		
		new Trie:JS;
		new tmp_names[33],tmp_weap_names[33],distance,maxspeed,prestrafe,strafes,sync;
		new tmp_type[33];
	
		format(tmp_type, 32, "%s_%d_%d", type, i,weapon_maxspeed(wpn_rank));
		
		if(TrieKeyExists(JumpData, tmp_type))
		{	
			TrieGetCell(JumpData, tmp_type, JS);
			
			TrieGetCell(JS, "distance", distance);
			TrieGetCell(JS, "maxspeed", maxspeed);
			TrieGetCell(JS, "prestrafe", prestrafe);
			TrieGetCell(JS, "strafes", strafes);
			TrieGetCell(JS, "sync", sync);
			TrieGetString(JS,"name",tmp_names,32);
			TrieGetString(JS,"wpn",tmp_weap_names,32);
			//TrieGetCell(JS, "ddbh", ddbh);	
		}
		
		
		if( distance == 0)
		{
			len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %s <td> %s <td> %s <td> %s <td> %s <td> %s", ((i%2)==0) ? "" : " bgcolor=#2f3030", (i+1), "-", "-", "-", "-", "-", "-", "-");			
			i=NSHOW;
		}
		else
		{
			name = tmp_names;
			while( containi(name, "<") != -1 )
				replace(name, 127, "<", "&lt;");
			while( containi(name, ">") != -1 )
				replace(name, 127, ">", "&gt;");
				
			len += format(buffer[len], 2367-len, "<tr align=center%s><td> %d <td align=left> %s <td> %d.%01d <td> %d.%01d <td> %d.%01d <td> %d <td> %d <td> %s", ((i%2)==0) ? "" : " bgcolor=#2f3030", (i+1), name,(distance/1000000), (distance%1000000/100000), (maxspeed/1000000), (maxspeed%1000000/100000), (prestrafe/1000000), (prestrafe%1000000/100000), strafes,sync,tmp_weap_names);
		}
	}
	len += format(buffer[len], 2367-len, "</table></body>");
	
	static strin[64];
	format(strin,63, "Top %d %s (maxspeed - %d)",NSHOW,Cosy_TypeList[type_num],weapon_maxspeed(wpn_rank));
	
	show_motd(id, buffer, strin);
}

public Float:find_min_jumpoff(Float:TmpArray[NTOP+1])
{
	new num_min;
	num_min=0;
	for (new i = 0; i < NSHOW; i++)
	{
		if(TmpArray[num_min]>TmpArray[i] && TmpArray[i]!=0.0)
		{
			num_min=i;
		}
	}
	return TmpArray[num_min];
}

public plugin_end() 
{ 
	if(DB_TUPLE)
		SQL_FreeHandle(DB_TUPLE);
	if(SqlConnection)
		SQL_FreeHandle(SqlConnection);
}