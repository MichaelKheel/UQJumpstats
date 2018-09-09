#pragma tabsize 0

new bool:g_userConnected[33],bool:g_alive[33];
new Handle:DB_TUPLE;
new Handle:SqlConnection;
new g_error[512];

public stats_sql()
{
	new kz_uq_host[64];
	new kz_uq_user[64];
	new kz_uq_pass[64];
	new kz_uq_db[64];

	new cvarfiles[256];
	kz_get_configsfile(cvarfiles, charsmax(cvarfiles));

	if (file_exists(cvarfiles)) 
    {
        new FileOpen = fopen(cvarfiles, "rt");
        new Text[256], szArg1[64], szArg2[64];

        while(!feof(FileOpen)) 
        {
            fgets(FileOpen, Text, sizeof(Text) - 1);
            strtok(Text, szArg1, charsmax(szArg1), szArg2, charsmax(szArg2), '=');
			replace_all(szArg2, charsmax(szArg2), "[","");
			replace_all(szArg2, charsmax(szArg2), "]","");
			trim(szArg1);
			trim(szArg2);
            if(equali(szArg1, "kz_uq_host")) kz_uq_host = szArg2;
			if(equali(szArg1, "kz_uq_user")) kz_uq_user = szArg2;
			if(equali(szArg1, "kz_uq_pass")) kz_uq_pass = szArg2;
			if(equali(szArg1, "kz_uq_db")) {kz_uq_db = szArg2;break;}
        }
        fclose(FileOpen)
	}
	
	DB_TUPLE = SQL_MakeDbTuple(kz_uq_host, kz_uq_user, kz_uq_pass, kz_uq_db);
	
	new error;
	SqlConnection = SQL_Connect(DB_TUPLE,error,g_error,511);
	
	if(!SqlConnection) 
	{
		server_print("uq_jumpstats: Could not connect to SQL database; Error #%d: %s", error, g_error);
		log_amx("uq_jumpstats: Could not connect to SQL database; Error #%d: %s", error, g_error);
		return pause("a");
	}
	
	new CreateInto[1001];
	
	formatex(CreateInto, 1000, "CREATE TABLE IF NOT EXISTS uq_players (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,name VARCHAR(64) NOT NULL,ip VARCHAR(39) NOT NULL,authid VARCHAR(35) NOT NULL, lastseen INT(10) NOT NULL,INDEX(name,authid))");
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle", CreateInto);
	
	formatex(CreateInto, 1000, "CREATE TABLE IF NOT EXISTS uq_jumps (pid INT(11) NOT NULL,type VARCHAR(32) NOT NULL,distance INT(10) NOT NULL,maxspeed INT(10) NOT NULL,prestrafe INT(10) NOT NULL,strafes INT(2) NOT NULL,sync INT(3) NOT NULL,ddbh INT(3) NOT NULL DEFAULT '0',pspeed INT(3) NOT NULL,wpn VARCHAR(32) NOT NULL,INDEX(pid,type,distance,maxspeed,prestrafe,strafes,sync,ddbh,pspeed,wpn))");
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle", CreateInto);
	
	formatex(CreateInto, 1000, "CREATE TABLE IF NOT EXISTS uq_block_tops (pid INT(11) NOT NULL,type VARCHAR(32) NOT NULL,distance INT(10) NOT NULL,jumpoff INT(10) NOT NULL,block VARCHAR(5) NOT NULL,pspeed INT(3) NOT NULL,wpn VARCHAR(32) NOT NULL,INDEX(pid,type,distance,jumpoff,pspeed,wpn))");
	SQL_ThreadQuery(DB_TUPLE,"QueryHandle", CreateInto);
		
	return PLUGIN_CONTINUE;
}

public QueryHandle(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	if( iFailState != TQUERY_SUCCESS )
	{
		log_amx("uq_jumpstats: SQL Error #%d - %s", iErrnum, szError);
		client_print(0,print_chat, "SQL error. Data has not been not saved.");
	}
	
	SQL_FreeHandle(hQuery);
	return PLUGIN_CONTINUE;
}

stock is_user_spectating_player(spectator, player)
{
	if( !valid_id(spectator) || !valid_id(player) )
		return 0;
	if( g_userConnected[spectator]==false || g_userConnected[player]==false )
		return 0;
	if( g_alive[spectator] || !g_alive[player] )
		return 0;
	
	if( pev(spectator, pev_deadflag) != 2 )
		return 0;
	
	static specmode;
	specmode = pev(spectator, pev_iuser1);
	if( !(specmode == 1 || specmode == 2 || specmode == 4) )
		return 0;
	
	if( pev(spectator, pev_iuser2) == player )
		return 1;
	
	return 0;
}
stock get_spectated_player(spectator)
{
	if( !valid_id(spectator) )
		return 0;
	if( !g_userConnected[spectator] )
		return 0;
	if( g_alive[spectator] )
		return 0;
	if( pev(spectator, pev_deadflag) != 2 )
		return 0;
	
	static player, specmode;
	specmode = pev(spectator, pev_iuser1);
	if( !(specmode == 1 || specmode == 2 || specmode == 4) )
		return 0;
	
	player = pev(spectator, pev_iuser2);
	
	if( !valid_id(player) )
		return 0;
	if( !g_userConnected[player] )
		return 0;
	if( !g_alive[player] )
		return 0;
	
	return player;
}
stock Float:UpBhop_calc(Float:height)
{
	if(height<=8 && height>0)
	{
		return 227.0;
	}
	else if(height<=16 && height>8)
	{
		return 225.0;
	}
	else if(height<=24 && height>16)
	{
		return 223.0;
	}
	else if(height<=32 && height>24)
	{
		return 221.0;
	}
	else if(height<=40 && height>32)
	{
		return 219.0;
	}
	else if(height<=48 && height>40)
	{
		return 217.0;
	}
	else if(height<=56 && height>48)
	{
		return 215.0;
	}
	else if(height<=64 && height>56)
	{
		return 213.0;
	}

	return 0.0;
}

///exolents fail///
stock Float:GetFailedDistance(Float:ExDist, bool:ducking, Float:gravity, Float:jumpoff_origin[3], Float:current_velocity[3], Float:failed_origin[3], Float:failed_velocity[3] )
{
	static Float:airtime, Float:land_origin[3], Float:distance;
	
	if( ducking ) jumpoff_origin[2] -= 18.0;
			
	airtime = ((floatsqroot((failed_velocity[2] * failed_velocity[2]) - (2.0 * -gravity * (failed_origin[2] - jumpoff_origin[2])))*-1) - failed_velocity[2] ) / -gravity;
	
	land_origin[0] = floatabs( failed_origin[0] - jumpoff_origin[0] ) + floatabs( current_velocity[0] * airtime );
	land_origin[1] = floatabs( failed_origin[1] - jumpoff_origin[1] ) + floatabs( current_velocity[1] * airtime );
	
	distance = vector_length(land_origin) + ExDist;
	
	if( ducking ) jumpoff_origin[2] += 18.0;
	
	return distance;
}

stock weapon_rank(maxspeed)
{
	new rank;
	
	switch(maxspeed)
	{
		case 0: rank = -1;
		case 210: rank = 1;
		case 220: rank = 2;
		case 221: rank = 3;
		case 230: rank = 4;
		case 235: rank = 5;
		case 240: rank = 6;
		case 245: rank = 7;
		case 250: rank = 0;
	}
	
	return rank;
}

stock weapon_maxspeed(rank)
{
	new maxspeed;
	
	switch(rank)
	{
		case 0: maxspeed = 250;
		case 1:	maxspeed = 210;
		case 2:	maxspeed = 220;
		case 3:	maxspeed = 221;
		case 4:	maxspeed = 230;
		case 5:	maxspeed = 235;
		case 6:	maxspeed = 240;
		case 7:	maxspeed = 245;
	}
	
	return maxspeed;
}

stock Float:LandingCalculate(id,Float:landing_orig[3], Float:jumpoff_origin[3])
{
	new Float:tmplandorg[3],Float:tmplandorigin[3]; 
	
	for(new i=0,ii=-18;i<3;i++,ii=ii+18)
	{	if(floatabs(landing_orig[0]-jumpoff_origin[0])>floatabs(landing_orig[1]-jumpoff_origin[1]))
		{
			tmplandorigin=landing_orig;
			tmplandorigin[1]=tmplandorigin[1]+ii;
			
			if(landing_orig[0]-jumpoff_origin[0]>0) 
			{
				tmplandorigin[0]=tmplandorigin[0]+16;
				
				
				tmplandorg[0]=landing_orig[0]-330;
				tmplandorg[1]=landing_orig[1]+ii;
				tmplandorg[2]=landing_orig[2];
			}
			else if(landing_orig[0]-jumpoff_origin[0]<0) 
			{
				tmplandorigin[0]=tmplandorigin[0]-16;
				
				
				tmplandorg[0]=landing_orig[0]+330;
				tmplandorg[1]=landing_orig[1]+ii;
				tmplandorg[2]=landing_orig[2];
			}
		}
		else if(floatabs(landing_orig[0]-jumpoff_origin[0])<floatabs(landing_orig[1]-jumpoff_origin[1]))
		{
			tmplandorigin=landing_orig;
			tmplandorigin[0]=tmplandorigin[0]+ii;
			
			if(landing_orig[1]-jumpoff_origin[1]>0) 
			{
				tmplandorigin[1]=tmplandorigin[1]+16;
				
				
				tmplandorg[0]=landing_orig[0]+ii;
				tmplandorg[1]=landing_orig[1]-330;
				tmplandorg[2]=landing_orig[2];
			}
			else if(landing_orig[1]-jumpoff_origin[1]<0) 
			{
				tmplandorigin[1]=tmplandorigin[1]-16;
				
				
				tmplandorg[0]=landing_orig[0]+ii;
				tmplandorg[1]=landing_orig[1]+330;
				tmplandorg[2]=landing_orig[2];
			}
		}
		new Float:Orgland[3],Float:startOrgland[3];

		engfunc(EngFunc_TraceLine,tmplandorigin, tmplandorg, IGNORE_GLASS | IGNORE_MONSTERS, id, 0); 
		get_tr2( 0, TR_vecEndPos, Orgland);
		
		engfunc(EngFunc_TraceLine,Orgland, tmplandorigin, IGNORE_GLASS | IGNORE_MONSTERS, id, 0); 
		get_tr2( 0, TR_vecEndPos, startOrgland);
		
		if(get_distance_f(tmplandorigin,startOrgland)!=0.0)
			return get_distance_f(tmplandorigin,startOrgland);
	}
	return 0.0;
}

stock kz_get_configsfile(name[], len)
{
	new lalin[64];
	get_localinfo("amxx_configsdir", lalin,63);
	
	return formatex(name, len, "%s/uqjumpstats.cfg", lalin);
}