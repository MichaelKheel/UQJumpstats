#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <fakemeta>
#include <engine>
#include <cstrike>
#include <hamsandwich>
#include <celltrie>
#include <sqlx>
#include <uq_jumpstats_stocks.inc>

#define PLUGIN "UQJS"
#define VERSION "1.10"
#define AUTHOR "MichaelKheel"

new g_ClFilterStuffCmd[33];
#define prefix "[CC]"
#define min_pre "60"
#define FPS_TASK_ID 927560
#define GRAVITY	800.0
#define NSTRAFES 14 //How many Strafes to show
#define SQLCVARSNUM 4 //Num of cvars to goes in sql DB
#define NTECHNUM 26 //Num of techniques
////////////////////////////////////Some shit varibeles////////////////////////////////////
new angles_arry[33],Float:old_angles[33][3],lost_frame_count[33][NSTRAFES],line_lost[33][NSTRAFES][160],FullJumpFrames[33],heystats,max_players,bool:duckbhop_bug_pre[33],bool:dropupcj[33],Float:first_duck_z[33],Float:checkladdertime[33],bool:ladderbug[33],bool:login[33];
new uq_istrafe,kz_uq_istrafe,bug_check[33],bool:bug_true[33],bool:find_ladder[33],bool:Checkframes[33],type_button_what[33][100];
new beam_type[33],min_prestrafe[33],dropbhop[33],ddnum[33],bool:dropaem[33],bool:ddforcj[33];
new kz_uq_min_other,bool:slide_protec[33],bool:UpcjFail[33],bool:upBhop[33],Float:upheight[33];
new beam_entity[33][160],ent_count[33],g_sql_pid[33];

new bool:height_show[33],bool:firstfall_ground[33],framecount[33],bool:firstladder[33];
new Float:FallTime[33],Float:FallTime1[33],multiscj[33],multidropcj[33],bool:enable_sound[33];
new jumpblock[33],Float:edgedist[33];
new bool:failed_jump[33],bhop_num[33],bool:Show_edge_Fail[33],bool:Show_edge[33],bool:fps_hight[33],bool:first_ground_bhopaem[33];

new line_erase[33][NSTRAFES],line_erase_strnum[33];

new max_edge,min_edge,NSTRAFES1,max_strafes,Float:nextbhoptime[33],Float:bhopaemtime[33],Float:ground_bhopaem_time[33],Float:SurfFrames[33],Float:oldSurfFrames[33],bool:first_air[33];
new bool:preessbutton[33],button_what[33],bool:gBeam_button[33][100],gBeam_button_what[33][100];
new bool:h_jumped[33],Float:heightoff_origin[33],Float:x_heightland_origin[33],bool:x_jump[33],Float:laddertime[33],bool:edgedone[33];
new schetchik[33],Float:changetime[33],bool:edgeshow[33],bool:slide[33],pre_type[33][33];

new bool:ingame_strafe[33],bool:ljpre[33],Float:distance[33],detecthj[33],bool:doubleduck[33];
new Float:doubletime[33],bool:multibhoppre[33],kz_uq_fps,bool:duckbhop[33],MAX_DISTANCE,Float:upbhop_koeff[33];
new Float:rDistance[3],Float:frame2time,bool:touch_ent[33],bool:ddbeforwj[33],bool:gHasColorChat[33],Float:old_angle1[33];
new bool:g_lj_stats[33],strafe_num[33],bool:g_Jumped[33],bool:g_reset[33],Float:gBeam_points[33][100][3],gBeam_duck[33][100],gBeam_count[33];

new gBeam,waits[33],waits1[33],Float:slideland[33],bool:backwards[33],bool:hookcheck[33],Float:timeonground[33];
new kz_uq_lj,kz_uq_cj,kz_uq_dcj,kz_uq_mcj ,kz_uq_ladder,kz_uq_ldbj,kz_uq_bj,kz_uq_sbj,kz_uq_drbj,kz_uq_drsbj,kz_uq_drcj,kz_uq_wj;	

new oldpre[33],oldljpre[33],oldfail[33],Float:starthj[33][3],Float:stophj[33][3], Float:endhj[33][3];
new bool:landslide[33],strafecounter_oldbuttons[33],Float:Fulltime,Float:needslide[33],Float:groundslide[33];
new jj,sync_[33],goodSyncTemp,badSyncTemp,strafe_lost_frame[33][NSTRAFES],Float:time_,Float:strafe_stat_time[33][NSTRAFES],Float:strafe_stat_speed[33][NSTRAFES][2];
new strafe_stat_sync[33][NSTRAFES][2],strLen,strMess[40*NSTRAFES],strMessBuf[40*NSTRAFES];

new strL,strM[40*NSTRAFES],strMBuf[40*NSTRAFES],Float:firstvel[33],Float:secvel[33],Float:firstorig[33][3],Float:secorig[33][3];
new Float:fSpeed, Float:speed, Float:TempSpeed[33],Float:velocity[3],Float:statsduckspeed[33][100]; 
new bool:slidim[33],Float:slidedist[33],edgefriction,mp_footsteps,sv_cheats,sv_maxspeed,sv_stepsize,sv_maxvelocity;

new kz_min_dcj,kz_stats_x,kz_stats_y,Float:stats_x,Float:stats_y,taskslide[33],taskslide1[33],bool:failslide[33];
new Float:failslidez[33],kz_strafe_x,kz_strafe_y,Float:strafe_x,Float:strafe_y,Float:laddist[33],kz_duck_x;
new kz_duck_y,Float:duck_x,Float:duck_y,bool:bhopaem[33],bool:nextbhop[33],kz_stats_red,kz_stats_green, kz_stats_blue, kz_failstats_red,kz_failstats_green;
new kz_failstats_blue, kz_sounds, kz_airaccelerate,kz_legal_settings;

new kz_uq_dscj,kz_uq_mscj,kz_uq_dropscj,kz_uq_dropdscj,kz_uq_dropmscj,kz_uq_duckbhop,kz_uq_bhopinduck,kz_uq_realldbhop,kz_uq_multibhop,kz_uq_upbj,kz_uq_upbhopinduck,kz_uq_upsbj,kz_uq_dropdcj,kz_uq_dropmcj;

new user_block[33][2],Float:slidez[33][4][3];

new CjafterJump[33],bool:ddafterJump[33],bool:cjjump[33],bool:serf_reset[33],entlist[256],ent,nLadder,Float:ladderxyz[256][3],Float:ladderminxyz[256][3], Float:laddersize[256][3], nashladder,bool:ladderjump[33];
new bool:kz_stats_pre[33], bool:kz_beam[33],bool:showpre[33],bool:showjofon[33],bool:speedon[33],bool:jofon[33];

new Float:dropbjorigin[33][3], Float:falloriginz[33],Float:origin[3],ducks[33], movetype[33];
static Float:maxspeed[33], Float:prestrafe[33],JumpType:jump_type[33],JumpType:old_type_dropbj[33], frames[33], frames_gained_speed[33], bool:turning_left[33];
static bool:turning_right[33],bool:started_cj_pre[33],bool:in_duck[33], bool:in_bhop[33],bool:in_air[33],bool:in_ladder[33];
new bool:failearly[33],bool:firstshow[33],bool:first_onground[33],bool:notjump[33],bool:OnGround[33],bool:donehook[33];

new bool:streifstat[33],Jtype[33][33],Jtype1[33][33],Jtype_old_dropbj[33][33],Jtype_old_dropbj1[33][33],Float:weapSpeed[33],Float:weapSpeedOld[33];
new airacel[33][33],bool:firstfr[33],kz_speed_x,kz_speed_y,hud_stats,hud_streif,hud_pre,hud_duck,hud_speed; 
new kz_uq_connect,bool:duckstring[33],bool:showduck[33],Float:surf[33];
new bool:first_surf[33],oldjump_type[33],oldjump_typ1[33],jump_typeOld[33],mapname[33],Float:duckstartz[33],direct_for_strafe[33];
new Float:height_difference[33],bool:jumpoffirst[33],bool:posibleScj[33];
new kz_uq_noslow,kz_prest_x,kz_prest_y,kz_speed_r,kz_speed_g,kz_speed_b,kz_prest_r,kz_prest_g,kz_prest_b;

new bool:touch_somthing[33],record_start[33];
new showtime_st_stats[33];

new Float:jof[33],Float:speedshowing[33];

new g_playername[33][64], g_playersteam[33][35], g_playerip[33][16];
new sql_JumpType[33];
new Float:oldjump_height[33],Float:jheight[33],bool:jheight_show[33];

new uq_lj,uq_cj,uq_dcj,uq_mcj,uq_ladder,uq_ldbj,uq_bj,uq_sbj,uq_drbj,uq_drsbj,uq_drcj;	
new uq_wj,uq_dscj,uq_mscj,uq_dropscj,uq_dropdscj,uq_dropmscj,uq_duckbhop,uq_bhopinduck;
new uq_realldbhop,uq_upbj,uq_upbhopinduck,uq_upsbj,uq_multibhop,uq_dropdcj,uq_dropmcj;
new max_distance,min_distance_other,min_distance,uq_airaccel,leg_settings,uq_sounds;
new uq_maxedge,uq_minedge,uq_min_pre,speed_r,speed_g,speed_b,Float:speed_x,Float:speed_y,h_speed;
new prest_r,prest_g,prest_b,Float:prest_x,Float:prest_y,h_prest,h_stats,h_duck,h_streif;
new uq_noslow,uq_fps,stats_r,stats_b,stats_g,f_stats_r,f_stats_b,f_stats_g;
new uq_bug,kz_uq_bug,kz_uq_script_detection,uq_script_detection;
new logs_path[128];
new sv_airaccelerate, sv_gravity;

new Trie:JumpPlayers;

enum JumpType
{
	Type_LongJump = 0,
	Type_HighJump = 1,
	Type_CountJump = 2,
	Type_BhopLongJump = 3,
	Type_Slide = 4, //worked only on 2 maps
	Type_StandupBhopLongJump = 5,
	Type_WeirdLongJump = 6,
	Type_Drop_BhopLongJump = 7,
	Type_Nothing = 8, //??
	Type_Double_CountJump = 9,
	Type_Multi_CountJump = 11,
	Type_DuckBhop = 12,
	Type_ladder = 13,
	Type_None = 14,
	Type_ladderBhop =15,
	Type_Nothing2 = 16, //??
	Type_Real_ladder_Bhop = 17,
	Type_Drop_CountJump = 18, 
	Type_StandUp_CountJump = 19,
	Type_Multi_Bhop = 20,
	Type_Up_Bhop = 21,
	Type_Up_Stand_Bhop = 22,
	Type_Up_Bhop_In_Duck = 23,
	Type_Bhop_In_Duck = 24,
	Type_Null = 25
};

new Type_List[NTECHNUM][] = { 		//For Top_
	"lj",			//0
	"scj",			//1
	"cj",			//2
	"wj",			//3
	"bj",			//4
	"sbj",			//5
	"ladder",		//6
	"ldbhop",		//7
	"dropcj",		//8
	"dropbj",		//9
	"dcj",			//10
	"dscj",			//11
	"dropscj",		//12
	"dropdscj",		//13
	"duckbhop",		//14
	"bhopinduck",		//15
	"realldbhop",		//16
	"upbj",			//17
	"upsbj",		//18
	"upbhopinduck",		//19
	"dropdcj",		//20
	"mcj",			//21
	"mscj",			//22
	"dropmscj",		//23
	"multibhop",		//24
	"dropmcj"		//25
};

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
		
	kz_min_dcj          = register_cvar("kz_uq_min_dist",            "215");
	MAX_DISTANCE         = register_cvar("kz_uq_max_dist",            "290");
	
	kz_stats_red        = register_cvar("kz_uq_stats_red",        "0");		
	kz_stats_green      = register_cvar("kz_uq_stats_green",      "255");
	kz_stats_blue       = register_cvar("kz_uq_stats_blue",       "159");
	kz_failstats_red        = register_cvar("kz_uq_failstats_red",        "255");		
	kz_failstats_green      = register_cvar("kz_uq_failstats_green",      "0");
	kz_failstats_blue       = register_cvar("kz_uq_failstats_blue",       "109");
	
	kz_sounds 	     = register_cvar("kz_uq_sounds",           "1");
	kz_legal_settings     = register_cvar("kz_uq_legal_settings",     "1");
	kz_airaccelerate     = register_cvar("kz_uq_airaccelerate",     "0");
	
	kz_stats_x        = register_cvar("kz_uq_stats_x",        "-1.0");		
	kz_stats_y      = register_cvar("kz_uq_stats_y",      "0.70");
	kz_strafe_x        = register_cvar("kz_uq_strafe_x",        "0.70");		
	kz_strafe_y      = register_cvar("kz_uq_strafe_y",      "0.35");
	kz_duck_x        = register_cvar("kz_uq_duck_x",        "0.6");		
	kz_duck_y      = register_cvar("kz_uq_duck_y",      "0.78");
	kz_speed_x        = register_cvar("kz_uq_speed_x",        "-1.0");		
	kz_speed_y      = register_cvar("kz_uq_speed_y",      "0.83");
	kz_prest_x        = register_cvar("kz_uq_prestrafe_x",        "-1.0");		
	kz_prest_y      = register_cvar("kz_uq_prestrafe_y",      "0.65");
	
	kz_speed_r        = register_cvar("kz_uq_speed_red",        "255");		
	kz_speed_g        = register_cvar("kz_uq_speed_green",      "255");
	kz_speed_b          = register_cvar("kz_uq_speed_blue",        "255");		
	kz_prest_r        = register_cvar("kz_uq_prestrafe_red",        "255");		
	kz_prest_g      = register_cvar("kz_uq_prestrafe_green",      "255");
	kz_prest_b        = register_cvar("kz_uq_prestrafe_blue",        "255");
	
	hud_stats       = register_cvar("kz_uq_hud_stats",        "3");		
	hud_streif    = register_cvar("kz_uq_hud_strafe",      "4");
	hud_pre      = register_cvar("kz_uq_hud_pre",        "1");		
	hud_duck     = register_cvar("kz_uq_hud_duck",      "1");
	hud_speed     = register_cvar("kz_uq_hud_speed",      "2");
	
	kz_uq_lj       = register_cvar("kz_uq_lj",        "1");	
	kz_uq_cj       = register_cvar("kz_uq_cj",        "1");	
	kz_uq_dcj       = register_cvar("kz_uq_dcj",        "1");	
	kz_uq_mcj       = register_cvar("kz_uq_mcj",        "1");	
	kz_uq_ladder       = register_cvar("kz_uq_ladder",        "1");	
	kz_uq_ldbj       = register_cvar("kz_uq_ldbj",        "1");	
	kz_uq_bj       = register_cvar("kz_uq_bj",        "1");	
	kz_uq_sbj       = register_cvar("kz_uq_sbj",        "1");	
	kz_uq_drbj       = register_cvar("kz_uq_drbj",        "1");	
	kz_uq_drsbj       = register_cvar("kz_uq_scj",        "1");	
	kz_uq_drcj       = register_cvar("kz_uq_drcj",        "1");	
	kz_uq_wj       = register_cvar("kz_uq_wj",        "1");	
	
	kz_uq_dscj       = register_cvar("kz_uq_dscj",        "1");	
	kz_uq_mscj       = register_cvar("kz_uq_mscj",        "1");
	kz_uq_dropscj       = register_cvar("kz_uq_dropscj",        "1");
	kz_uq_dropdscj       = register_cvar("kz_uq_dropdscj",        "1");
	kz_uq_dropmscj       = register_cvar("kz_uq_dropmscj",        "1");
	kz_uq_duckbhop       = register_cvar("kz_uq_duckbhop",        "1");
	kz_uq_bhopinduck      = register_cvar("kz_uq_bhopinduck",        "1");
	kz_uq_realldbhop       = register_cvar("kz_uq_realldbhop",        "1");
	kz_uq_upbj      = register_cvar("kz_uq_upbj",        "1");
	kz_uq_upbhopinduck      = register_cvar("kz_uq_upbhopinduck",        "1");
	kz_uq_upsbj       = register_cvar("kz_uq_upsbj",        "1");
	kz_uq_multibhop      = register_cvar("kz_uq_multibhop",        "1");
	kz_uq_dropdcj      = register_cvar("kz_uq_dropdcj",        "1");
	kz_uq_dropmcj     = register_cvar("kz_uq_dropmcj",        "1");
	
	kz_uq_connect = register_cvar("kz_uq_connect", "abdehklmn");
	kz_uq_fps = register_cvar("kz_uq_fps", "1");	
	kz_uq_istrafe = register_cvar("kz_uq_istrafes", "0");
	
	max_edge = register_cvar("kz_uq_max_block", "290");
	min_edge = register_cvar("kz_uq_min_block", "100");
	kz_uq_min_other = register_cvar("kz_uq_min_dist_other",            "120");
	max_strafes = register_cvar("kz_uq_max_strafes", "14");
	
	kz_uq_bug=register_cvar("kz_uq_bug_check", "1");
	kz_uq_noslow=register_cvar("kz_uq_noslowdown", "0");
	
	kz_uq_script_detection = register_cvar("kz_uq_script_detection", "1");
	
	register_cvar( "uq_jumpstats", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
		
	register_clcmd( "say /strafe",	"streif_stats" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /strafes",	"streif_stats" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /strafestat",	"streif_stats" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /strafestats",	"streif_stats" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /showpre",	"show_pre" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /duck",	"pre_stats" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /ducks",	"pre_stats" ,         ADMIN_ALL, "- enabled/disables");
	register_clcmd( "say /uqstats",		"cmdljStats",         ADMIN_ALL, "- enabled/disables" );
	register_clcmd( "say /ljstats",		"cmdljStats",         ADMIN_ALL, "- enabled/disables" );
	register_clcmd( "say /stats",		"cmdljStats",         ADMIN_ALL, "- enabled/disables" );
	register_clcmd( "say /height",		"heightshow",         ADMIN_ALL, "- enabled/disables" );
	register_clcmd( "say /fall",		"heightshow",         ADMIN_ALL, "- enabled/disables" );
	
	register_clcmd("say /uqbeam",     "cmdljbeam",         ADMIN_ALL);
	register_clcmd("say /beam",     "cmdljbeam",         ADMIN_ALL);
	register_clcmd("say /ljbeam",     "cmdljbeam",         ADMIN_ALL);
	//register_clcmd("say /speed",     "show_speed",         ADMIN_ALL);
	//register_clcmd("say speed",     "show_speed",         ADMIN_ALL);
	register_clcmd("say /colorchat",     "cmdColorChat",         ADMIN_ALL);
	register_clcmd("say colorchat",     "cmdColorChat",         ADMIN_ALL);
	register_clcmd("say /bhopwarn",     "show_early",         ADMIN_ALL);
	register_clcmd("say /multibhop",     "multi_bhop",         ADMIN_ALL);
	register_clcmd("say /duckspre",     "duck_show",         ADMIN_ALL);
	register_clcmd("say /duckpre",     "duck_show",         ADMIN_ALL);
	register_clcmd("say /ljpre",     "lj_show",         ADMIN_ALL);
	register_clcmd("say /prelj",     "lj_show",         ADMIN_ALL);
	register_clcmd("say /uqsound",     "enable_sounds",         ADMIN_ALL);
	register_clcmd("say /uqsounds",     "enable_sounds",         ADMIN_ALL);
	
	register_clcmd("say /failedge",     "ShowedgeFail",         ADMIN_ALL);
	register_clcmd("say /failedg",     "ShowedgeFail",         ADMIN_ALL);
	register_clcmd("say /edgefail",     "ShowedgeFail",         ADMIN_ALL);
	register_clcmd("say /edgfail",     "ShowedgeFail",         ADMIN_ALL);
	register_clcmd("say /edge",     "Showedge",         ADMIN_ALL);
	register_clcmd("say /edg",     "Showedge",         ADMIN_ALL);
	
	register_clcmd("say /joftrainer",     "trainer_jof",         ADMIN_ALL);
	register_clcmd("say joftrainer",     "trainer_jof",         ADMIN_ALL);
	register_clcmd("say /joftr",     "trainer_jof",         ADMIN_ALL);
	register_clcmd("say joftr",     "trainer_jof",         ADMIN_ALL);
	
	register_clcmd("say /jof",     "show_jof",         ADMIN_ALL);
	register_clcmd("say jof",     "show_jof",         ADMIN_ALL);
	
	register_clcmd("say /jheight",     "show_jheight",         ADMIN_ALL);
	register_clcmd("say jheight",     "show_jheight",         ADMIN_ALL);
	
	register_clcmd("say /istrafe",     "ingame_st_stats",         ADMIN_ALL);
	register_clcmd("say istrafe",     "ingame_st_stats",         ADMIN_ALL);
	
	register_clcmd("say /options",     "Option",         ADMIN_ALL);
	register_clcmd("say /ljsmenu",     "Option",         ADMIN_ALL);
	register_clcmd("say /ljsmenu2",     "Option2",         ADMIN_ALL);
	register_clcmd("say /uqmenu",     "Option",         ADMIN_ALL);
	register_clcmd("say /option",     "Option",         ADMIN_ALL);

	register_menucmd(register_menuid("StatsOptionMenu1"),          1023, "OptionMenu1");
	register_menucmd(register_menuid("StatsOptionMenu2"),          1023, "OptionMenu2");
	register_menucmd(register_menuid("StatsOptionMenu3"),          1023, "OptionMenu3");
	
	edgefriction          = get_cvar_pointer("edgefriction");
	mp_footsteps          = get_cvar_pointer("mp_footsteps");
	sv_cheats             = get_cvar_pointer("sv_cheats");
	sv_maxspeed           = get_cvar_pointer("sv_maxspeed");
	sv_stepsize           = get_cvar_pointer("sv_stepsize");
	sv_maxvelocity        = get_cvar_pointer("sv_maxvelocity");
	sv_airaccelerate      = get_cvar_pointer("sv_airaccelerate");
	sv_gravity            = get_cvar_pointer("sv_gravity");

	register_forward(FM_Touch, "fwdTouch", 1);
	register_forward(FM_PlayerPreThink, "fwdPreThink", 0 );
	register_forward(FM_PlayerPostThink, "fwdPostThink", 0 );
	
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1);
	RegisterHam(Ham_Killed, "player", "FwdPlayerDeath", 1);
	RegisterHam(Ham_Touch, "player",	"HamTouch");
	
	register_event("ResetHUD","ResetHUD","b");
	
	
	max_players=get_maxplayers()+1;
	
	ent=find_ent_by_class(-1,"func_ladder");
	while( ent > 0 )
	{
		entity_get_vector ( ent, EV_VEC_maxs, ladderxyz[nLadder] );
		entity_get_vector ( ent, EV_VEC_mins, ladderminxyz[nLadder] );
		entity_get_vector ( ent, EV_VEC_size, laddersize[nLadder] );
		entlist[nLadder]=ent;
		
		ent = find_ent_by_class(ent,"func_ladder");
		nLadder++;
	}
	
	get_mapname(mapname, 32);
	
	// Logs
	new logs[64];
	get_localinfo("amxx_logs", logs, 63);
	formatex(logs_path, 127, "%s\uq_jumpstats.txt", logs);
}

public plugin_cfg()
{
	new cvarfiles[256];
	kz_get_configsfile(cvarfiles, charsmax(cvarfiles));
	
	if( file_exists(cvarfiles) )
	{
		server_cmd("exec %s", cvarfiles);
		server_exec();
	}

	uq_min_pre=str_to_num(min_pre);
	uq_maxedge=get_pcvar_num(max_edge);
	uq_minedge=get_pcvar_num(min_edge);
	uq_istrafe=get_pcvar_num(kz_uq_istrafe);
	NSTRAFES1=get_pcvar_num(max_strafes);
	stats_x=get_pcvar_float(kz_stats_x);
	stats_y=get_pcvar_float(kz_stats_y);
	strafe_x=get_pcvar_float(kz_strafe_x);
	strafe_y=get_pcvar_float(kz_strafe_y);
	duck_x=get_pcvar_float(kz_duck_x);
	duck_y=get_pcvar_float(kz_duck_y);
	prest_r=get_pcvar_num(kz_prest_r);
	prest_g=get_pcvar_num(kz_prest_g);
	prest_b=get_pcvar_num(kz_prest_b);
	prest_x=get_pcvar_float(kz_prest_x);
	prest_y=get_pcvar_float(kz_prest_y);
	h_prest=get_pcvar_num(hud_pre);
	h_stats=get_pcvar_num(hud_stats);
	h_duck=get_pcvar_num(hud_duck);
	h_streif=get_pcvar_num(hud_streif);
	stats_r=get_pcvar_num(kz_stats_red);
	stats_b=get_pcvar_num(kz_stats_blue);
	stats_g=get_pcvar_num(kz_stats_green);
	f_stats_r=get_pcvar_num(kz_failstats_red);
	f_stats_b=get_pcvar_num(kz_failstats_blue);
	f_stats_g=get_pcvar_num(kz_failstats_green);
	uq_lj=get_pcvar_num(kz_uq_lj);	
	uq_cj=get_pcvar_num(kz_uq_cj);	
	uq_dcj=get_pcvar_num(kz_uq_dcj);	
	uq_mcj=get_pcvar_num(kz_uq_mcj);	
	uq_ladder=get_pcvar_num(kz_uq_ladder);	
	uq_ldbj=get_pcvar_num(kz_uq_ldbj);	
	uq_bj=get_pcvar_num(kz_uq_bj);	
	uq_sbj=get_pcvar_num(kz_uq_sbj);	
	uq_drbj=get_pcvar_num(kz_uq_drbj);	
	uq_drsbj=get_pcvar_num(kz_uq_drsbj);	
	uq_drcj=get_pcvar_num(kz_uq_drcj);	
	uq_wj=get_pcvar_num(kz_uq_wj);
	uq_dscj=get_pcvar_num(kz_uq_dscj);	
	uq_mscj=get_pcvar_num(kz_uq_mscj);
	uq_dropscj=get_pcvar_num(kz_uq_dropscj);
	uq_dropdscj=get_pcvar_num(kz_uq_dropdscj);
	uq_dropmscj=get_pcvar_num(kz_uq_dropmscj);
	uq_duckbhop=get_pcvar_num(kz_uq_duckbhop);
	uq_bhopinduck=get_pcvar_num(kz_uq_bhopinduck);
	uq_realldbhop=get_pcvar_num(kz_uq_realldbhop);
	uq_upbj=get_pcvar_num(kz_uq_upbj);
	uq_upbhopinduck=get_pcvar_num(kz_uq_upbhopinduck);
	uq_upsbj=get_pcvar_num(kz_uq_upsbj);
	uq_multibhop=get_pcvar_num(kz_uq_multibhop);
	uq_dropdcj=get_pcvar_num(kz_uq_dropdcj);
	uq_dropmcj=get_pcvar_num(kz_uq_dropmcj);
	leg_settings=get_pcvar_num(kz_legal_settings);	
	uq_airaccel=get_pcvar_num( kz_airaccelerate );
	min_distance=get_pcvar_num(kz_min_dcj);
	min_distance_other=get_pcvar_num(kz_uq_min_other);
	max_distance=get_pcvar_num(MAX_DISTANCE);
	uq_sounds=get_pcvar_num(kz_sounds);
	uq_fps=get_pcvar_num(kz_uq_fps);
	speed_r=get_pcvar_num(kz_speed_r);
	speed_g=get_pcvar_num(kz_speed_g);
	speed_b=get_pcvar_num(kz_speed_b);
	speed_x=get_pcvar_float(kz_speed_x);
	speed_y=get_pcvar_float(kz_speed_y);
	h_speed=get_pcvar_num(hud_speed);
	uq_bug=get_pcvar_num(kz_uq_bug);
	uq_noslow=get_pcvar_num(kz_uq_noslow);
	uq_script_detection=get_pcvar_num(kz_uq_script_detection);
		
	new plugin_id=find_plugin_byfile("uq_jumpstats_tops.amxx");
	
	if(plugin_id==-1)
	{
		log_amx("Can't find uq_jumpstats_tops.amxx");
		server_print("[uq_jumpstats] Can't find uq_jumpstats_tops.amxx");
	}

	if( leg_settings )
	{
		set_cvar_string("edgefriction", "2");
		set_cvar_string("mp_footsteps", "1");
		set_cvar_string("sv_cheats", "0");
		set_cvar_string("sv_gravity", "800");
		
		if( uq_airaccel ) set_cvar_string("sv_airaccelerate", "100");
		else set_cvar_string("sv_airaccelerate", "10");
		
		set_cvar_string("sv_maxspeed", "320");
		set_cvar_string("sv_stepsize", "18");
		set_cvar_string("sv_maxvelocity", "2000");
	}
				
	set_task(0.2, "stats_sql");
	JumpPlayers = TrieCreate();
}

#include <uq_jumpstats_sql.inc>

public plugin_precache()
{
	gBeam = precache_model( "sprites/zbeam6.spr" );
	precache_sound( "misc/impressive.wav" );
	precache_sound( "misc/perfect.wav" );
	precache_sound( "misc/mod_godlike.wav" );
	precache_sound( "misc/holyshit.wav" );
	precache_sound( "misc/mod_wickedsick.wav" );
	precache_sound( "misc/dominatingkz.wav" );
	
	precache_model( "models/hairt.mdl" );
	heystats = precache_model( "sprites/zbeam6.spr" );
}

bool:valid_id(id)
{
	if(id>0 && id<33)
	{
		return true;
	}
	
	return false;
}

bool:check_for_bug_distance(Float:check_distance,type,mSpeed)
{
	new minys=floatround((250.0-mSpeed)*0.73,floatround_floor);
	if(type==1 && check_distance>(260-minys))
	{
		return true;
	}
	else if(type==2 && check_distance>(277-minys))
	{
		return true;
	}
	else if(type==3 && check_distance>(253-minys))
	{
		return true;
	}
	else if(type==4 && check_distance>200)
	{
		return true;
	}
	else if(type==5 && check_distance>225-minys)
	{
		return true;
	}
	else if(type==6 && check_distance>180-minys)
	{
		return true;
	}
	
	return false;
}

bool:is_user_ducking( id ) {
	if( !valid_id( id )  )
		return false;
	
	new Float:abs_min[3], Float:abs_max[3];
	
	pev( id, pev_absmin, abs_min );
	pev( id, pev_absmax, abs_max );
	
	abs_min[2] += 64.0;
	
	if( abs_min[2] < abs_max[2] )
		return false;
	
	return true;
}

stock IsOnGround(id) 
{    
	new flags = pev(id, pev_flags);
	if((flags & FL_ONGROUND) || (flags & FL_PARTIALGROUND) ||( flags & FL_INWATER ) ||( flags & FL_CONVEYOR ) ||( flags & FL_FLOAT)) 
	{
		return true;
	}
	return false;
}

public Log_script(f_frames,cheated_frames,id,Float:log_dist,Float:log_max,Float:log_pre,log_str,log_sync,jump_type_str[],wpn_str[],punishments[],t_str[40*NSTRAFES])
{
	new Date[20];
	get_time("%m/%d/%y %H:%M:%S", Date, 19)	;
	new username[33];
	get_user_name(id, username, 32);
	new userip[16];
	get_user_ip(id, userip, 15, 1);
	new authid[35];
	get_user_authid(id, authid, 34);
	new main_text[512];
	
	write_file(logs_path, "---------------------------------------------------", -1);
	formatex(main_text, 511, "%s |%s |%s |%s |%s |%s ^n", Date,username, authid, userip, "Script",punishments);
	write_file(logs_path, main_text, -1);
	formatex(main_text, 511, "Type: %s ::: Weapon: %s^nDistance: %.03f Maxspeed: %.03f Prestrafe: %.03f Strafes: %d Sync: %d^n",jump_type_str,wpn_str,log_dist,log_max,log_pre,log_str,log_sync);
	write_file(logs_path, main_text, -1);
	formatex(main_text, 511, "Total Frames: %d^nCheated Frames: %d^n",f_frames,cheated_frames);
	write_file(logs_path, main_text, -1);
	
	new strf[40];
	for(new ll=1; (ll <= log_str) && (ll < NSTRAFES);ll++)
	{
		strtok(t_str,strf,40,t_str,40*NSTRAFES,'^n');
		replace(strf,40,"^n","");
		write_file(logs_path, strf, -1);
	}
	write_file(logs_path, "---------------------------------------------------", -1);

}

public fnClientCvarResult(id, const szCvar[], const szValue[]) 
{
	if(equali(szCvar, "cl_filterstuffcmd") && szValue[0] != 'B') g_ClFilterStuffCmd[id] = str_to_num(szValue);
}

public tskFps(id)
{
	if( leg_settings)
	{
		id-=434490;
	new authid[32];
	get_user_authid(id, authid, 31);
	client_cmd(id, ";^"gl_vsync^" 0;^"fps_override^" 0;^"cl_forwardspeed^" 400;^"cl_backspeed^" 400;^"cl_sidespeed^" 400");
	query_client_cvar(id, "cl_filterstuffcmd", "fnClientCvarResult");
	if(!g_ClFilterStuffCmd[id]) {
		client_cmd(id, ";^"developer^" 0;^"fps_max^" 99.5");
	}
	if(equal(authid, "VALVE_ID_LAN") || equal(authid, "STEAM_ID_LAN") || strlen(authid) > 18) {
	client_cmd(id, ";^"developer^" 0;^"fps_max^" 101");
	} else {
	client_cmd(id, ";^"fps_max^" 99.5");
	}
	}
}
public server_frame()
{
	if( leg_settings )
	{
		if( get_pcvar_num(edgefriction) != 2 ) set_pcvar_num(edgefriction, 2);
		if( get_pcvar_num(mp_footsteps) != 1 ) set_pcvar_num(mp_footsteps, 1);
		if( get_pcvar_num(sv_cheats) != 0 )	set_pcvar_num(sv_cheats, 0);
		if( get_pcvar_num(sv_gravity)!= 800 ) set_pcvar_num(sv_gravity, 800);
		
		if( uq_airaccel ) if( get_pcvar_num(sv_airaccelerate) != 100 ) set_pcvar_num(sv_airaccelerate, 100);
		else if( get_pcvar_num(sv_airaccelerate) != 10 ) set_pcvar_num(sv_airaccelerate, 10);
		
		if( get_pcvar_num(sv_maxspeed) != 320 )	set_pcvar_num(sv_maxspeed, 320);
		if( get_pcvar_num(sv_stepsize) != 18 ) set_pcvar_num(sv_stepsize, 18);
		if( get_pcvar_num(sv_maxvelocity) != 2000 ) set_pcvar_num(sv_maxvelocity, 2000);
	}
}
public client_putinserver(id)
{
	if(speedon[id] && !is_user_hltv(id))// && is_user_alive(id) && is_user_bot(id) && is_user_hltv())
	{
		set_task(0.1, "DoSpeed", id+212299, "", 0, "b", 0);
	}
	
	get_user_name(id, g_playername[id], 63);
	get_user_ip(id, g_playerip[id], 15, 1);
	get_user_authid(id, g_playersteam[id], 35);

	player_load_info(id);
}
public Dojof(taskid)
{
	taskid-=212398;
	
	static alive, spectatedplayer;
	alive = g_alive[taskid];
	spectatedplayer = get_spectated_player(taskid);
	
	if( (alive || spectatedplayer > 0))
	{
		new show_id;
		
		if( alive )
		{
			show_id=taskid;
		}
		else
		{
			show_id=spectatedplayer;
		}
		
		if(jof[show_id]!=0.0)
		{	
			if(jof[show_id]>5.0)
			{
				set_hudmessage(255, 255, 255, -1.0, 0.6, 0, 0.0, 0.7, 0.0, 0.0, h_speed);
			}
			else
			{
				set_hudmessage(255, 0, 0, -1.0, 0.6, 0, 0.0, 0.7, 0.0, 0.0, h_speed);
			}
			show_hudmessage(taskid, "JumpOff: %f", jof[show_id]);
		}
	}
}


public DoSpeed(taskid)
{
	taskid-=212299;
	
	static alive, spectatedplayer;
	alive = g_alive[taskid];
	spectatedplayer = get_spectated_player(taskid);
	
	if( (alive || spectatedplayer > 0))
	{
		new show_id;
		
		if( alive )
		{
			show_id=taskid;
		}
		else
		{
			show_id=spectatedplayer;
		}
		
		set_hudmessage(speed_r, speed_g, speed_b, speed_x, speed_y, 0, 0.0, 0.2, 0.0, 0.0, h_speed);
		show_hudmessage(taskid, "%d units/sec", floatround(speedshowing[show_id], floatround_floor));		
	}
}
public wait(id)
{
	id-=3313;
	waits[id]=1;

}

public wait1(id)
{
	id-=3214;
	waits1[id]=1;

}

public client_command(id)
{
	static command[32];
	read_argv( 0, command, 31 );

	static const forbidden[][] = {
		"tele", "tp", "gocheck", "gc", "stuck", "unstuck", "start", "reset", "restart",
		"spawn", "respawn"
	};

	if(record_start[id]==0 && equali( command, "fullupdate" ))
	{
		record_start[id]=1;
	}
	else if(record_start[id]==1 && equali( command, "specmode" ))
	{
		set_hudmessage(255, 255, 255, 0.72, 0.0, 0, 6.0, 1.0);
		show_hudmessage(id, "%L",LANG_SERVER,"UQSTATS_INFOSTS",VERSION);
			
		record_start[id]=0;
	}
	if(is_user_alive(id))
	{
		if( equali( command, "say" ) )
		{
			read_args( command, 31 );
			remove_quotes( command );
		}
		
		if( equali( command, "+hook" ) )
		{
			JumpReset(id);
			donehook[id]=true;
			hookcheck[id]=false;
		}
		else if( command[0] == '/' || command[0] == '.' )
		{
			copy( command, 31, command[1] );
			
			for( new i ; i < sizeof( forbidden ) ; i++ )
			{
				if( equali( command, forbidden[i] ) )
				{
					//set_task(0.1,"freeze",id); // HINZUGEFÜGT fix cp exploits
					JumpReset(id);
					break;
				}
			}
		}
	}
}

public freeze(id)
{
	if(IsOnGround(id))
	return PLUGIN_HANDLED;

	set_pev( id, pev_velocity, { 0.0 , 0.0 , 0.0 } );
	set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );

	new flags = pev( id, pev_flags );
	if( flags & FL_FROZEN )
	{
		set_pev(id, pev_flags, flags & ~FL_FROZEN);
	}
	return PLUGIN_HANDLED;
}

public remove_beam_ent(id)
{
	for(new i=0;i<ent_count[id];i++)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(99);
		write_short(beam_entity[id][i]);
		message_end();
		
		remove_entity(beam_entity[id][i]);
	}
	ent_count[id]=0;
}
public epta(id,Float:or[3],direct_strafe,l_lost[NSTRAFES][160],full,ducked,str_num,strafe_frame1[NSTRAFES],strafe_frame2[NSTRAFES],strafe_lost[NSTRAFES])
{	
	new Float:os_start,Float:temp_or[3],direct[2];
	
	switch(direct_strafe)
	{
		case 1:
		{
			temp_or[0]=or[0];
			temp_or[1]=or[1]+48.0;
			
			if(ducked)
			{
				temp_or[2]=or[2]+16+18;
			}
			else temp_or[2]=or[2]+18;
		}
		case 2:
		{
			temp_or[0]=or[0];
			temp_or[1]=or[1]-48.0;
			
			if(ducked)
			{
				temp_or[2]=or[2]+16+18;
			}
			else temp_or[2]=or[2]+18;
			
			direct[1]=1;
		}
		case 3:
		{
			temp_or[0]=or[1];
			temp_or[1]=or[0]+48.0;
			
			if(ducked)
			{
				temp_or[2]=or[2]+16+18;
			}
			else temp_or[2]=or[2]+18;
			
			direct[0]=1;
			direct[1]=1;
		}
		case 4:
		{
			temp_or[0]=or[1];
			temp_or[1]=or[0]-48.0;
			
			if(ducked)
			{
				temp_or[2]=or[2]+16+18;
			}
			else temp_or[2]=or[2]+18;
			
			direct[0]=1;
		}
	}
	
	os_start=temp_or[0]-(full/2);

	if(direct[1])
	{
		new Float:temp_start=os_start+full;
			
		beam_entity[id][ent_count[id]] = create_entity("info_target");
		
		//entity_set_int(beam_entity[id][ent_count[id]], EV_INT_solid, SOLID_NOT);
		entity_set_model(beam_entity[id][ent_count[id]], "models/hairt.mdl");
		
		new Float:ent_or[3];
		if(direct[0])
		{
			ent_or[0]=temp_or[1];
			ent_or[1]=temp_start;
		}
		else 
		{
			ent_or[0]=temp_start;
			ent_or[1]=temp_or[1];
		}
		ent_or[2]=temp_or[2];
		
		entity_set_origin(beam_entity[id][ent_count[id]], ent_or);
		
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
		
		write_byte(TE_BEAMENTPOINT);
		write_short(beam_entity[id][ent_count[id]]);
	
///////////////////////////////////////////	
		if(direct[0])
		{
			write_coord(floatround(temp_or[1]));
			write_coord(floatround(temp_start-full));
		}
		else 
		{
			write_coord(floatround(temp_start-full));
			write_coord(floatround(temp_or[1]));
		}
		write_coord(floatround(temp_or[2]));
///////////////////////////////////////////	
		write_short(heystats);
		write_byte(0);
		write_byte(5);
		write_byte(showtime_st_stats[id]);
		write_byte(1);
		write_byte(0);
			
		
		write_byte(0);
		write_byte(0);
		write_byte(255);
	
		write_byte(150);
		write_byte(1);
		message_end();
		
		ent_count[id]++;
		
		for(new i=0;i<2;i++)
		{
			beam_entity[id][ent_count[id]] = create_entity("info_target");
			
			//entity_set_int(beam_entity[id][ent_count[id]], EV_INT_solid, SOLID_NOT);
			entity_set_model(beam_entity[id][ent_count[id]], "models/hairt.mdl");
			
			new Float:ent_org[3];
			if(direct[0])
			{
				ent_org[0]=temp_or[1];
				
				if(i==1)
					ent_org[1]=temp_start-full;
				else
					ent_org[1]=temp_start;
			}
			else 
			{
				if(i==1)
					ent_org[0]=temp_start-full;
				else
					ent_org[0]=temp_start;
					
				ent_org[1]=temp_or[1];
			}
			ent_org[2]=temp_or[2]-10.0;
			
			entity_set_origin(beam_entity[id][ent_count[id]], ent_org);
			
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
			
			write_byte(TE_BEAMENTPOINT);
			write_short(beam_entity[id][ent_count[id]]);
			
	///////////////////////////////////////////	
			if(direct[0])
			{
				write_coord(floatround(temp_or[1]));
				
				if(i==1)
					write_coord(floatround(temp_start-full));
				else
					write_coord(floatround(temp_start));
			}
			else 
			{
				if(i==1)
					write_coord(floatround(temp_start-full));
				else
					write_coord(floatround(temp_start));
					
				write_coord(floatround(temp_or[1]));
			}
			write_coord(floatround(temp_or[2]+10.0));
	///////////////////////////////////////////	
			write_short(heystats);
			write_byte(0);
			write_byte(5);
			write_byte(showtime_st_stats[id]);
			write_byte(5);
			write_byte(0);
				
			
			write_byte(0);
			write_byte(0);
			write_byte(255);
		
			write_byte(150);
			write_byte(1);
			message_end();
			
			ent_count[id]++;
		}
		
		for(new i=1;i<=str_num;i++)
		{
			new Float:st_start,Float:st_finish;
			
			st_finish=temp_start-strafe_lost[i]-strafe_frame1[i]-strafe_frame2[i];
			st_start=temp_start-strafe_lost[i];
			
			for(new Float:j=st_start,count_l=0;j>st_finish;j=j-1.0)
			{
				beam_entity[id][ent_count[id]] = create_entity("info_target");
		
				//entity_set_int(beam_entity[id][ent_count[id]], EV_INT_solid, SOLID_NOT);
				entity_set_model(beam_entity[id][ent_count[id]], "models/hairt.mdl");
				
				new Float:ent_org[3];
				if(direct[0])
				{
					ent_org[0]=temp_or[1];
					ent_org[1]=j;
				}
				else 
				{
					ent_org[0]=j;
					ent_org[1]=temp_or[1];
				}
				
				if(i%2!=0)
					ent_org[2]=temp_or[2];
				else 
					ent_org[2]=temp_or[2]-4.0;
				
				entity_set_origin(beam_entity[id][ent_count[id]], ent_org);
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				
				write_byte(TE_BEAMENTPOINT);
				write_short(beam_entity[id][ent_count[id]]);
				
		///////////////////////////////////////////	
				if(direct[0])
				{
					write_coord(floatround(temp_or[1]));
					write_coord(floatround(j));
				}
				else 
				{
					write_coord(floatround(j));
					write_coord(floatround(temp_or[1]));
				}
				
				if(i%2!=0)
					write_coord(floatround(temp_or[2]+4.0));
				else 
					write_coord(floatround(temp_or[2]));
		///////////////////////////////////////////	
				write_short(heystats);
				write_byte(0);
				write_byte(5);
				write_byte(showtime_st_stats[id]);
				write_byte(5);
				write_byte(0);
					
				if(l_lost[i][count_l])
				{
					write_byte(255);
					write_byte(0);
					write_byte(0);
					line_lost[id][i][count_l]=0;
				}
				else
				{
					write_byte(0);
					write_byte(255);
					write_byte(0);
				}
				
				write_byte(200);
				write_byte(1);
				message_end();
				count_l++;
				ent_count[id]++;
			}
			temp_start=st_finish;
			
		}
	}
	else
	{
		new Float:temp_start=os_start;
		
		beam_entity[id][ent_count[id]] = create_entity("info_target");
		
	//	entity_set_int(beam_entity[id][ent_count[id]], EV_INT_solid, SOLID_NOT);
		entity_set_model(beam_entity[id][ent_count[id]], "models/hairt.mdl");
		
		new Float:ent_or[3];
		if(direct[0])
		{
			ent_or[0]=temp_or[1];
			ent_or[1]=temp_start;
		}
		else 
		{
			ent_or[0]=temp_start;
			ent_or[1]=temp_or[1];
		}
		ent_or[2]=temp_or[2];
		
		entity_set_origin(beam_entity[id][ent_count[id]], ent_or);
		
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
		
		write_byte(TE_BEAMENTPOINT);
		write_short(beam_entity[id][ent_count[id]]);
		
///////////////////////////////////////////	
		if(direct[0])
		{
			write_coord(floatround(temp_or[1]));
			write_coord(floatround(temp_start+full));
		}
		else 
		{
			write_coord(floatround(temp_start+full));
			write_coord(floatround(temp_or[1]));
		}
		write_coord(floatround(temp_or[2]));
///////////////////////////////////////////	
		write_short(heystats);
		write_byte(0);
		write_byte(5);
		write_byte(showtime_st_stats[id]);
		write_byte(1);
		write_byte(0);
			
		
		write_byte(0);
		write_byte(0);
		write_byte(255);
	
		write_byte(150);
		write_byte(1);
		message_end();
		
		ent_count[id]++;
		
		for(new i=0;i<2;i++)
		{
			beam_entity[id][ent_count[id]] = create_entity("info_target");
		
			//entity_set_int(beam_entity[id][ent_count[id]], EV_INT_solid, SOLID_NOT);
			entity_set_model(beam_entity[id][ent_count[id]], "models/hairt.mdl");
			
			new Float:ent_org[3];
			if(direct[0])
			{
				ent_org[0]=temp_or[1];
				
				if(i==1)
					ent_org[1]=temp_start+full;
				else
					ent_org[1]=temp_start;
			}
			else 
			{
				if(i==1)
					ent_org[0]=temp_start+full;
				else
					ent_org[0]=temp_start;
					
				ent_org[1]=temp_or[1];
			}
			ent_org[2]=temp_or[2]-10.0;
			
			entity_set_origin(beam_entity[id][ent_count[id]], ent_org);
			
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
			
			write_byte(TE_BEAMENTPOINT);
			write_short(beam_entity[id][ent_count[id]]);
	///////////////////////////////////////////	
			if(direct[0])
			{
				write_coord(floatround(temp_or[1]));
				
				if(i==1)
					write_coord(floatround(temp_start+full));
				else
					write_coord(floatround(temp_start));
			}
			else 
			{
				if(i==1)
					write_coord(floatround(temp_start+full));
				else
					write_coord(floatround(temp_start));
					
				write_coord(floatround(temp_or[1]));
			}
			write_coord(floatround(temp_or[2]+10.0));
	///////////////////////////////////////////	
			write_short(heystats);
			write_byte(0);
			write_byte(5);
			write_byte(showtime_st_stats[id]);
			write_byte(5);
			write_byte(0);
				
			
			write_byte(0);
			write_byte(0);
			write_byte(255);
		
			write_byte(150);
			write_byte(1);
			message_end();
			
			ent_count[id]++;
		}
		
		for(new i=1;i<=str_num;i++)
		{
			new Float:st_start,Float:st_finish;
			
			st_finish=temp_start+strafe_lost[i]+strafe_frame1[i]+strafe_frame2[i];
			st_start=temp_start+strafe_lost[i];
			//ColorChat(id,RED,"start=%f tempstart=%f st_start=%f st_finish=%f",os_start,temp_start, st_start,st_finish);
			
			for(new Float:j=st_start,count_l=0;j<st_finish;j++)
			{
				beam_entity[id][ent_count[id]] = create_entity("info_target");
		
			//	entity_set_int(beam_entity[id][ent_count[id]], EV_INT_solid, SOLID_NOT);
				entity_set_model(beam_entity[id][ent_count[id]], "models/hairt.mdl");
				
				new Float:ent_org[3];
				if(direct[0])
				{
					ent_org[0]=temp_or[1];
					ent_org[1]=j;
				}
				else 
				{
					ent_org[0]=j;
					ent_org[1]=temp_or[1];
				}
				
				if(i%2!=0)
					ent_org[2]=temp_or[2];
				else 
					ent_org[2]=temp_or[2]-4.0;
				
				entity_set_origin(beam_entity[id][ent_count[id]], ent_org);
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
				
				write_byte(TE_BEAMENTPOINT);
				write_short(beam_entity[id][ent_count[id]]);

		///////////////////////////////////////////	
				if(direct[0])
				{
					write_coord(floatround(temp_or[1]));
					write_coord(floatround(j));
				}
				else 
				{
					write_coord(floatround(j));
					write_coord(floatround(temp_or[1]));
				}
				
				if(i%2!=0)
					write_coord(floatround(temp_or[2]+4.0));
				else 
					write_coord(floatround(temp_or[2]));
		///////////////////////////////////////////	
				write_short(heystats);
				write_byte(0);
				write_byte(5);
				write_byte(showtime_st_stats[id]);
				write_byte(5);
				write_byte(0);
					
				if(l_lost[i][count_l])
				{
					write_byte(255);
					write_byte(0);
					write_byte(0);
					line_lost[id][i][count_l]=0;
				}
				else
				{
					write_byte(0);
					write_byte(255);
					write_byte(0);
				}
				
				write_byte(200);
				write_byte(1);
				message_end();
				count_l++;
				ent_count[id]++;
			}
			temp_start=st_finish;
		}
	}
}


public fwdPreThink( id )
{
	if(g_userConnected[id]==true)
	{	
		new tmpTeam[33],dead_flag;	
			get_user_team(id,tmpTeam,32);
			dead_flag=pev(id, pev_deadflag);
			
			if(equali(tmpTeam,"TERRORIST") || equali(tmpTeam,"CT") || equali(tmpTeam,"SPECTATOR"))
			{
				if(dead_flag==2 && g_alive[id])
				{
					g_alive[id]=false;
					
					if( task_exists(id, 0) )
					remove_task(id, 0);
					
					if( task_exists(id+434490, 0) )
					remove_task(id+434490, 0);
					
					if( task_exists(id, 0) )
					remove_task(id, 0);
					
					if( task_exists(id+89012, 0) )
					remove_task(id+89012, 0);
					
					if( task_exists(id+3313, 0) )
					remove_task(id+3313, 0);
					
					if( task_exists(id+3214, 0) )
					remove_task(id+3214, 0);
					
					if( task_exists(id+15237, 0) )
					remove_task(id+15237, 0);
					
					if( task_exists(id+212398, 0) )
					remove_task(id+212398, 0);
				}
				else if(dead_flag==0 && g_alive[id]==false)
				{
					g_alive[id]=true;
				}
						
			if( g_alive[id])
			{
				static bool:failed_ducking[33];
				static bool:first_frame[33],bool:started_multicj_pre[33];
				static Float:duckoff_time[33];
				static Float:duckoff_origin[33][3], Float:pre_jumpoff_origin[33][3];
				static Float:jumpoff_foot_height[33];	
				static Float:prest[33],Float:prest1[33],Float:jumpoff_origin[33][3],Float:failed_velocity[33][3],Float:failed_origin[33][3];
				static Float:frame_origin[33][2][3], Float:frame_velocity[33][2][3], Float:jumpoff_time[33], Float:last_land_time[33];
				
				new entlist1[1];
				
				weapSpeedOld[id] = weapSpeed[id];
				
				if( g_reset[id] ==true)
				{
					angles_arry[id]=0;
					g_reset[id]	= false;
					g_Jumped[id]	= false;
					cjjump[id] =false;
					in_air[id]	= false;
					in_duck[id]	= false;
					in_bhop[id]	= false;
					ducks[id]=0;
					first_duck_z[id]=0.0;
					backwards[id]=false;
					dropaem[id]=false;
					failed_jump[id] = false;
					prest[id]=0.0;
					bug_true[id]=false;
					detecthj[id]=0;
					edgedone[id]=false;
					jumpblock[id]=1000;
					schetchik[id]=0;
					CjafterJump[id]=0;
					upBhop[id]=false;
					old_type_dropbj[id]=Type_Null;
					first_surf[id]=false;
					surf[id]=0.0;
					ddbeforwj[id]=false;
					duckstring[id]=false;
					notjump[id]=false;
					frames_gained_speed[id] = 0;
					frames[id]	= 0;
					strafe_num[id] = 0;
					ladderjump[id]=false;
					started_multicj_pre[id]	= false;
					started_cj_pre[id]		= false;
					jumpoffirst[id]=false;
					jump_type[id]	= Type_None;
					gBeam_count[id] = 0;
					edgedist[id]=0.0;
					oldjump_height[id]=0.0;
					jheight[id]=0.0;
					duckbhop_bug_pre[id]=false;
					FullJumpFrames[id]=0;
					direct_for_strafe[id]=0;
					
					for( new i = 0; i < 100; i++ )
					{
						gBeam_points[id][i][0]	= 0.0;
						gBeam_points[id][i][1]	= 0.0;
						gBeam_points[id][i][2]	= 0.0;
						gBeam_duck[id][i]	= false;
						gBeam_button[id][i]=false;
						
					}
					Checkframes[id]=false;
					for(new i=0;i<NSTRAFES;i++)
					{
						type_button_what[id][i]=0;
						if(uq_istrafe)
							lost_frame_count[id][i]=0;						
					}
					
					if(uq_istrafe)
					{
						for(new i=0;i<=line_erase_strnum[id];i++)
						{
							for( new j = 0; j <= line_erase[id][i]; j++ )
							{
								line_lost[id][i][j]=0;
							}
						}
					}
				}
				
				static button, oldbuttons, flags;
				pev(id, pev_maxspeed, weapSpeed[id]);
				pev(id, pev_origin, origin);
				button = pev(id, pev_button );
				flags = pev(id, pev_flags );
				oldbuttons = pev( id, pev_oldbuttons );
				
				static Float:fGravity,Pmaxspeed;
				pev(id, pev_gravity, fGravity);
				Pmaxspeed=pev( id, pev_maxspeed );
				new Float:velocity[3];
				pev(id, pev_velocity, velocity);
				movetype[id] = pev(id, pev_movetype);
				
				if( flags&FL_ONGROUND && flags&FL_INWATER )  
						velocity[2] = 0.0;
				
				fSpeed = vector_length(velocity);
				
				if( velocity[2] != 0 )
					velocity[2]-=velocity[2];
					
				speed = vector_length(velocity);	
				speedshowing[id]=speed;
				
				new is_spec_user[33];
				for( new i = 1; i < max_players; i++ )
				{
					is_spec_user[i]=is_user_spectating_player(i, id);
				}
				if(strafe_num[id]>NSTRAFES1)
				{
					g_reset[id]=true;
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{
							set_hudmessage( 255, 255, 255, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
							show_hudmessage(i,"You have exceeded the maximum number of strafes^n(Server max value ^"%d^", You Strafes is ^"%d^")",NSTRAFES1,strafe_num[id]);	
						}
					}
					return FMRES_IGNORED;
				}
				
				
				if((button&IN_RIGHT || button&IN_LEFT) && !(flags&FL_ONGROUND))
				{
					for(new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{
							client_print(i,print_center,"Script or you use left(right) key");
							JumpReset(id);
							return FMRES_IGNORED;
						}
					}
				}
				new airace,aircj;
				if( uq_airaccel )
				{
					airace=100;
					formatex(airacel[id],32,"(100aa)");
					aircj=10;
				}
				else
				{
					airace=10;
					aircj=0;
					formatex(airacel[id],32,"");
				}
				new spd;
				if(equali(mapname,"slide_gs_longjumps") || equali(mapname,"b2j_slide_longjumps"))
				{
					spd=1400;
				}
				else spd=385;
				
				if(speed> spd || weapSpeedOld[id] != weapSpeed[id])
				{
					if(weapSpeedOld[id] != weapSpeed[id])
					{
						
						changetime[id]=get_gametime();
					}
					JumpReset(id);
					return FMRES_IGNORED;
				}
				
				if(leg_settings==1 && (get_pcvar_num(edgefriction) != 2 || fGravity != 1.0 || get_pcvar_num(mp_footsteps) != 1
					|| get_pcvar_num(sv_cheats) != 0
					|| get_pcvar_num(sv_gravity) != 800
					|| get_pcvar_num(sv_airaccelerate) != airace
					|| get_pcvar_num(sv_maxspeed) != 320
					|| get_pcvar_num(sv_stepsize) != 18
					|| get_pcvar_num(sv_maxvelocity) != 2000
					|| pev(id, pev_waterlevel) >= 2 ))
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
			
				if(!(button&IN_MOVELEFT)
				&& oldbuttons&IN_MOVELEFT)
				{
					preessbutton[id]=false;
					button_what[id]=0;
				}
				else if(oldbuttons&IN_MOVERIGHT
				&& !(button&IN_MOVERIGHT))
				{
					button_what[id]=0;
					preessbutton[id]=false;
				}
				else if(oldbuttons&IN_BACK
				&& !(button&IN_BACK))
				{
					preessbutton[id]=false;
					button_what[id]=0;
				}
				else if(oldbuttons&IN_FORWARD
				&& !(button&IN_FORWARD))
				{
					preessbutton[id]=false;
					button_what[id]=0;
				}
					
				if( !(flags&FL_ONGROUND) )
				{
					last_land_time[id] = get_gametime();
					jof[id]=0.0;
				}
					
				
				if(bhopaem[id]==true && !(flags&FL_ONGROUND) && movetype[id] != MOVETYPE_FLY)
				{
					bhopaemtime[id]=get_gametime();
				}
				else if(bhopaem[id]==true && flags&FL_ONGROUND && get_gametime()-bhopaemtime[id]>0.1 && movetype[id] != MOVETYPE_FLY)
				{
			
					bhopaem[id]=false;
				}
				
				if(nextbhop[id]==true && flags&FL_ONGROUND && first_ground_bhopaem[id]==false)
				{
					first_ground_bhopaem[id]=true;
					ground_bhopaem_time[id]=get_gametime();
				}
				else if(nextbhop[id]==true && !(flags&FL_ONGROUND) && first_ground_bhopaem[id]==true && movetype[id] != MOVETYPE_FLY)
				{
					first_ground_bhopaem[id]=false;
				}
				
				if(nextbhop[id]==true && flags&FL_ONGROUND && first_ground_bhopaem[id]==true && (get_gametime()-ground_bhopaem_time[id]>0.1) && movetype[id] != MOVETYPE_FLY)
				{
					first_ground_bhopaem[id]=false;
					bhopaem[id]=false;
					nextbhop[id]=false;
				}
				
				if(nextbhop[id]==true && !(flags&FL_ONGROUND) && movetype[id] != MOVETYPE_FLY)
				{
					nextbhoptime[id]=get_gametime();
				}
				if(nextbhop[id]==true && flags&FL_ONGROUND && get_gametime()-nextbhoptime[id]>0.1 && movetype[id] != MOVETYPE_FLY)
				{
			
					nextbhop[id]=false;
				}
				if(flags & FL_ONGROUND && h_jumped[id]==false && movetype[id] != MOVETYPE_FLY)
				{
					heightoff_origin[id]=0.0;
				}
				
				if(flags & FL_ONGROUND && button&IN_BACK && backwards[id]==false)
				{
					backwards[id]=true;
				}
				else if(flags & FL_ONGROUND && button&IN_FORWARD && backwards[id])
				{
					backwards[id]=false;
				}
				
				if(flags & FL_ONGROUND && button&IN_JUMP && !(oldbuttons&IN_JUMP) && movetype[id] != MOVETYPE_FLY)
				{
					if(is_user_ducking(id))
					{
						heightoff_origin[id]=origin[2]+18;
					}
					else heightoff_origin[id]=origin[2];
					
					h_jumped[id]=true;
				}
				else if(flags & FL_ONGROUND && h_jumped[id] && movetype[id] != MOVETYPE_FLY)
				{
					new Float:heightland_origin;
					if(is_user_ducking(id))
					{
						heightland_origin=origin[2]+18;
					}
					else heightland_origin=origin[2];
					
					
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{	
							if(height_show[i]==true )
							{
								if(heightland_origin-heightoff_origin[id]==0.0)
								{
									set_hudmessage(prest_r,prest_g, prest_b, stats_x, stats_y, 0, 0.0, 0.7, 0.1, 0.1, h_stats);
									show_hudmessage(i, "Jump realise at the same height");
								}
								else if(heightland_origin-heightoff_origin[id]>0.0)
								{
									set_hudmessage(prest_r,prest_g, prest_b, stats_x, stats_y, 0, 0.0, 0.7, 0.1, 0.1, h_stats);
									show_hudmessage(i, "Height distance: %.03f",heightland_origin-heightoff_origin[id]);
								}
								else if(heightland_origin-heightoff_origin[id]<0.0)
								{
									set_hudmessage(prest_r,prest_g, prest_b, stats_x, stats_y, 0, 0.0, 0.7, 0.1, 0.1, h_stats);
									show_hudmessage(i, "Fall distance: %.03f",floatabs(heightland_origin-heightoff_origin[id]));
								}
							}
						}
					}
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{
							if(height_show[i]==true )
							{
								if(heightland_origin-heightoff_origin[id]==0.0)
								{
									client_print( i, print_console,"Jump realise at the same height");
								}
								else if(heightland_origin-heightoff_origin[id]>0.0)
								{
									client_print( i, print_console,"Height distance: %.03f",heightland_origin-heightoff_origin[id]);
								}
								else if(heightland_origin-heightoff_origin[id]<0.0)
								{
									client_print( i, print_console,"Fall distance: %.03f",floatabs(heightland_origin-heightoff_origin[id]));
								}
							}
						}
					}
					h_jumped[id]=false;
				}
				
				if((movetype[id] != MOVETYPE_FLY))	
				{
					if(firstfr[id]==false)
					{
						firstfr[id]=true;
						pev(id, pev_velocity, velocity);
						pev(id, pev_origin, origin);
						if((g_Jumped[id]==true || !(flags&FL_ONGROUND)))
						{
							firstvel[id]=velocity[2];
						}
						firstorig[id]=origin;
					}
					else if(firstfr[id]==true )
					{
						pev(id, pev_origin, origin);
						pev(id, pev_velocity, velocity);
			
						secorig[id]=origin;
						if((g_Jumped[id]==true || !(flags&FL_ONGROUND)))
						{
							secvel[id]=velocity[2];
						}
						firstfr[id]=false;	
					}
					if(!(flags&FL_ONGROUND) && first_air[id]==false)
					{
						framecount[id]++;
						if(framecount[id]==2)
						{
							first_air[id]=true;
						}
						
						SurfFrames[id]=floatabs(firstvel[id]-secvel[id]);
						
						if(floatabs(firstvel[id]-secvel[id])>41)
						{
							SurfFrames[id]=oldSurfFrames[id];
						}
						oldSurfFrames[id]=SurfFrames[id];
					}
					if(flags&FL_ONGROUND && first_air[id]==true)
					{
						first_air[id]=false;
						framecount[id]=0;
					}
					if(!(flags&FL_ONGROUND) && SurfFrames[id]<7.9 && uq_fps==1 && fps_hight[id]==false)
					{
						fps_hight[id]=true;
					}
					if((flags&FL_ONGROUND) && SurfFrames[id]>7.9 && fps_hight[id])
					{
						fps_hight[id]=false;
					}
			
					if(!(flags&FL_ONGROUND) && 1.7*floatabs(firstvel[id]-secvel[id])<SurfFrames[id] && floatabs(firstvel[id]-secvel[id])!=4.0)
					{
						if(equali(mapname,"slide_gs_longjumps") || equali(mapname,"b2j_slide_longjumps"))
						{
							slide[id]=true;
						}
						else if(!ladderjump[id] && movetype[id] != MOVETYPE_FLY)
						{
							JumpReset(id);
							slide_protec[id]=true;
							return FMRES_IGNORED;
						}
					}
					else 
					{
						if(slide[id]==true && ((oldbuttons&IN_MOVELEFT && button&IN_MOVERIGHT) || (oldbuttons&IN_MOVERIGHT && button&IN_MOVELEFT)))
						{
							if(touch_ent[id])
							{
								JumpReset(id);
							}
							
							if(task_exists(id)) remove_task(id);
							
							set_task(1.5,"JumpReset", id);
							
							pev(id, pev_origin, origin);
							
							slidim[id]=true;
							jump_type[id]=Type_Slide;
							
							g_Jumped[id]	= true;
							prestrafe[id]	= speed;
			
							if(showpre[id]==true)
							{
								set_hudmessage(255,255, 255, -1.0, 0.85, 0, 0.0, 0.7, 0.1, 0.1, 2);
								show_hudmessage(id, "Slide pre: %.03f",speed);
							}
							slide[id]=false;
						}
					}
					
					firstorig[id][2]=0.0;
					secorig[id][2]=0.0;
					
					if((slidim[id]==true || slide[id]==true) && get_distance_f(firstorig[id],secorig[id])>20.0)
					{
						groundslide[id]=0.0;
						waits[id]=0;
						slidim[id]=false;
						taskslide[id]=0;
						failslide[id]=false;
						slide[id]=false;
						g_Jumped[id]	= false;
						
						return FMRES_IGNORED;
					}
					
					if((g_Jumped[id]==true || h_jumped[id]) && get_distance_f(firstorig[id],secorig[id])>6.0)
					{
						h_jumped[id]=false;
						JumpReset(id);
						return FMRES_IGNORED;
					}
				}
				if(slidim[id]==true)
				{
					
					//if(Pmaxspeed != 250.0)
					//{
					//	client_print(id,print_center,"Slide works only withs weapons 250.0 speed"); 
					//	return FMRES_IGNORED;
					//}
					
					pev(id, pev_origin, origin);
					new Float:start[33][3],Float:end[33][3];
					
				
					start[id][0]=origin[0];
					start[id][1]=origin[1]+16.0;
					start[id][2]=origin[2];
					end[id][0]=origin[0];
					end[id][1]=origin[1]+16.0;
					end[id][2]=origin[2]-500.0;
					
					engfunc(EngFunc_TraceLine, start[id], end[id], IGNORE_GLASS, id, 0); 
					get_tr2( 0, TR_vecEndPos, slidez[id][0]);
			
					start[id][0]=origin[0];
					start[id][1]=origin[1]-16.0;
					start[id][2]=origin[2];
					end[id][0]=origin[0];
					end[id][1]=origin[1]-16.0;
					end[id][2]=origin[2]-500.0;
					
					engfunc(EngFunc_TraceLine, start[id], end[id], IGNORE_GLASS, id, 0); 
					get_tr2( 0, TR_vecEndPos, slidez[id][1]);
					
					start[id][0]=origin[0]+16.0;
					start[id][1]=origin[1];
					start[id][2]=origin[2];
					end[id][0]=origin[0]+16.0;
					end[id][1]=origin[1];
					end[id][2]=origin[2]-500.0;
					
					engfunc(EngFunc_TraceLine, start[id], end[id], IGNORE_GLASS, id, 0); 
					get_tr2( 0, TR_vecEndPos, slidez[id][2]);
					
					start[id][0]=origin[0]-16.0;
					start[id][1]=origin[1];
					start[id][2]=origin[2];
					end[id][0]=origin[0]-16.0;
					end[id][1]=origin[1];
					end[id][2]=origin[2]-500.0;
					
					engfunc(EngFunc_TraceLine, start[id], end[id], IGNORE_GLASS, id, 0); 
					get_tr2( 0, TR_vecEndPos, slidez[id][3]);
					
					for(new i=0;i<4;i++)
					{		
						if(i!=3)
						{
							if(slidez[id][i][2]>slidez[id][i+1][2])
							{
								needslide[id]=slidez[id][i][2];
								groundslide[id]=slidez[id][i+1][2];
							
								if(needslide[id]-groundslide[id]>149.0 && landslide[id]==false)
								{
									landslide[id]=true;
									pev(id, pev_origin, origin);
									if( !(is_user_ducking(id)) )
									{
										origin[2]-=36.0;
									}
									else origin[2]-=18.0;
									
									slideland[id]=origin[2];
									slidedist[id]=slideland[id]-groundslide[id];
									maxspeed[id]=speed;
								}
							}
						}
					}
				
					if(taskslide[id]==0)
					{
						set_task(0.4,"wait", id+3313);
						taskslide[id]=1;
					}
					
					pev(id, pev_velocity, velocity);
					if(velocity[1]==0.0 && failslide[id]==false && !(flags&FL_ONGROUND) && waits[id]==1 )
					{
						if( !(is_user_ducking(id)) )
						{
							origin[2]-=36.0;
						}
						else origin[2]-=18.0;
						failslidez[id]=origin[2];
						failslide[id]=true;			
					}
				}
				
				if(flags&FL_ONGROUND && slidim[id]==true && Pmaxspeed == 250.0)
				{
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]) && g_lj_stats[i]==true)
						{
							if(needslide[id]-groundslide[id]==slidedist[id])
							{
								client_print(i, print_console, "Slide Distance: %d.xxx",floatround(slidedist[id], floatround_floor));
								set_hudmessage( stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );	
								show_hudmessage( i, "Slide Distance: %d.xxx",floatround(slidedist[id], floatround_floor));
							}
							else
							{
								client_print(i, print_console, "Slide Distance: %f",slidedist[id]);
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );	
								show_hudmessage( i, "Slide Distance: %f",slidedist[id]);
							
							}
						}
					}
									
					new iPlayers[32],iNum; 
					get_players ( iPlayers, iNum,"ch") ;
					for(new i=0;i<iNum;i++) 
					{ 
						new ids=iPlayers[i]; 
						if(gHasColorChat[ids] ==true || ids==id)
						{
							if(needslide[id]-groundslide[id]==slidedist[id])
							{
								ColorChat(ids, GREY, "%s %s jumped %d.xxx units with Slide lj!^x01%s",prefix, g_playername[id], floatround(slidedist[id], floatround_floor),airacel[id]);
							}
							else 
							ColorChat(ids, GREY, "%s %s jumped %.3f units with Slide lj!^x01%s",prefix, g_playername[id], slidedist[id],airacel[id]);				
						}
					}
										
					slidim[id]=false;
					groundslide[id]=0.0;
					waits[id]=0;
					slidim[id]=false;
					taskslide[id]=0;
					taskslide1[id]=0;
					
					message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
					write_byte ( TE_BEAMPOINTS );
					write_coord(floatround(origin[0]));
					write_coord(floatround(origin[1]));
					write_coord(floatround(slideland[id]));
					write_coord(floatround(origin[0]));
					write_coord(floatround(origin[1]+52.0));
					write_coord(floatround(slideland[id]));
				
					write_short(gBeam);
					write_byte(1);
					write_byte(5);
					write_byte(1130);
					write_byte(20);
					write_byte(0);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					
					write_byte(200);
					write_byte(200);
					message_end();
					landslide[id]=false;
				}
				if((failslide[id]==true) && slidim[id]==true)
				{
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]) && g_lj_stats[i]==true)
						{
							client_print(i, print_console, "Slide Distance: %f Prestrafe: %f",failslidez[id]-groundslide[id],prestrafe[id]);
					
							set_hudmessage( f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
							show_hudmessage( i, "Slide Distance: %f^nPrestrafe: %f",failslidez[id]-groundslide[id],prestrafe[id]);
						}
					}
					
					message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
					write_byte ( TE_BEAMPOINTS );
					write_coord(floatround(origin[0]));
					write_coord(floatround(origin[1]));
					write_coord(floatround(failslidez[id]));
					write_coord(floatround(origin[0]));
					write_coord(floatround(origin[1]+52.0));
					write_coord(floatround(failslidez[id]));
					
					write_short(gBeam);
					write_byte(1);
					write_byte(5);
					write_byte(1130);
					write_byte(20);
					write_byte(0);
					write_byte(255);
					write_byte(0);
					write_byte(0);
					
					write_byte(200);
					write_byte(200);
					message_end();
			
					failslide[id]=false;
					slidim[id]=false;
					groundslide[id]=0.0;
					waits[id]=0;
					taskslide[id]=0;
					taskslide1[id]=0;
				}
			
				if( (in_air[id]==true || in_bhop[id] == true) && !(flags&FL_ONGROUND) )
				{
					static i;
					for( i = 0; i < 2; i++ )
					{
						if( (i == 1) 
						|| (frame_origin[id][i][0] == 0
						&& frame_origin[id][i][1] == 0
						&& frame_origin[id][i][2] == 0 
						&& frame_velocity[id][i][0] == 0
						&& frame_velocity[id][i][1] == 0
						&& frame_velocity[id][i][2] == 0 )) 
						{
							frame_origin[id][i][0] = origin[0];
							frame_origin[id][i][1] = origin[1];
							frame_origin[id][i][2] = origin[2];
							
							pev(id, pev_velocity, velocity);
							frame_velocity[id][i][0] = velocity[0];
							frame_velocity[id][i][1] = velocity[1];
							frame_velocity[id][i][2] = velocity[2];
							i=2;
						}
					}
					
				}
				
				if( (in_air[id]) && !( flags & FL_ONGROUND ) && !failed_jump[id])
				{	
					if(uq_script_detection)
					{
						new Float:angles[3];
						pev(id,pev_angles,angles);
						
						if(floatabs(angles[0]-old_angles[id][0])==0.0)
						{
							angles_arry[id]++;
						}
						
						old_angles[id]=angles;
					}
					
					new Float:jh_origin;
					
					jh_origin=origin[2];
					
					if(floatabs(jumpoff_origin[id][2]-jh_origin)<oldjump_height[id] && jheight[id]==0.0)
					{
						
						if(is_user_ducking(id))
						{
							jheight[id]=oldjump_height[id]+18.0;
						}
						else jheight[id]=oldjump_height[id];
						
						for( new i = 1; i < max_players; i++ )
						{
							if( (i == id || is_spec_user[i]))
							{	
								if(jheight_show[i]==true )
								{
									set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
									show_hudmessage(i, "Jump Height: %.03f",jheight[id]);
									
									client_print( i, print_console,"Jump Height: %.03f",jheight[id]);
								}
							}
						}
						
						if(!direct_for_strafe[id])
						{
							if(velocity[1]>0 && floatabs(velocity[1])>floatabs(velocity[0]))
							{
								direct_for_strafe[id]=1;
							}
							else if(velocity[1]<0 && floatabs(velocity[1])>floatabs(velocity[0]))
							{
								direct_for_strafe[id]=2;
							}
							else if(velocity[0]>0 && floatabs(velocity[0])>floatabs(velocity[1]))
							{
								direct_for_strafe[id]=3;
							}
							else if(velocity[0]<0 && floatabs(velocity[0])>floatabs(velocity[1]))
							{
								direct_for_strafe[id]=4;
							}
						}
					}
					
					
					
					oldjump_height[id]=floatabs(jumpoff_origin[id][2]-origin[2]);
					
					if(bug_check[id]==0 && floatfract(velocity[2])==0)
					{
						bug_check[id]=1;
					}
					else if(bug_check[id]==1 && floatfract(velocity[2])==0)
					{
						bug_true[id]=true;
						bug_check[id]=0;
					}
					if( !in_bhop[id] )
					{
						fnSaveBeamPos( id );
					}
					static Float:old_speed[33];
					if( speed > old_speed[id] )
					{
						frames_gained_speed[id]++;
					}
					frames[id]++;
					
					old_speed[id] = speed;
			
					if( speed > maxspeed[id] )
					{
						if (strafe_num[id] < NSTRAFES)
						{
							strafe_stat_speed[id][strafe_num[id]][0] += speed - maxspeed[id];
						}
						maxspeed[id] = speed;
					}
					if ((speed < TempSpeed[id]) && (strafe_num[id] < NSTRAFES))
					{
						strafe_stat_speed[id][strafe_num[id]][1] += TempSpeed[id] - speed;
						if(strafe_stat_speed[id][strafe_num[id]][1]>5)
						{
							if(floatabs(firstvel[id]-secvel[id])<SurfFrames[id]-0.1)
							{
								Checkframes[id]=true;
							}
							else if(floatabs(firstvel[id]-secvel[id])>SurfFrames[id])
							{
								Checkframes[id]=true;
							}
						}
						
						
					}
					TempSpeed[id] = speed;
					
					if((origin[2] + 18.0 - jumpoff_origin[id][2] < 0))
					{
						failed_jump[id] = true;
					}
					else if( (is_user_ducking(id) ? (origin[2]+18) : origin[2]) >= jumpoff_origin[id][2] )
					{
						failed_origin[id] = origin;
						failed_ducking[id] = is_user_ducking( id );
						failed_velocity[id] = velocity;
						
						origin[2] = pre_jumpoff_origin[id][2];	
					}
					if( first_frame[id] ) 
					{
						first_frame[id] = false;
						frame_velocity[id][0] = velocity;
						
						gBeam_count[id] = 0;
						for( new i = 0; i < 100; i++ )
						{
							gBeam_points[id][i][0]	= 0.0;
							gBeam_points[id][i][1]	= 0.0;
							gBeam_points[id][i][2]	= 0.0;
							gBeam_duck[id][i]	= false;
							gBeam_button[id][i]=false;
						}
						
						if(in_bhop[id] && jump_type[id]!=Type_DuckBhop)
						{
							if(upBhop[id])
							{
								if(jump_type[id]==Type_Up_Bhop_In_Duck)
								{
									formatex(Jtype[id],32,"Up Bhop In Duck");
									formatex(Jtype1[id],32,"ubid");
								}
								else if(velocity[2] < upbhop_koeff[id])
								{
									jump_type[id]=Type_Up_Bhop;
									formatex(Jtype[id],32,"Up BhopJump");
									formatex(Jtype1[id],32,"ubj");
								}
								else
								{
									jump_type[id]=Type_Up_Stand_Bhop;
									formatex(Jtype[id],32,"Up StandUp BhopJump");
									formatex(Jtype1[id],32,"usbj");
								}
								upBhop[id]=false;
							}
							else if(jump_type[id]==Type_Bhop_In_Duck)
							{
								formatex(Jtype[id],32,"Bhop In Duck");
								formatex(Jtype1[id],32,"bid");
							}
							else if( velocity[2] < 229.0)
							{
								jump_type[id] = Type_BhopLongJump;
								formatex(Jtype[id],32,"BhopJump");
								formatex(Jtype1[id],32,"bj");
							}
							else 
							{
							
								jump_type[id] = Type_StandupBhopLongJump;
								formatex(Jtype[id],32,"StandUp BhopJump");
								formatex(Jtype1[id],32,"sbj");
								jumpoff_origin[id][2] = pre_jumpoff_origin[id][2];
							}
							
							for( new i = 1; i < max_players; i++ )
							{
								if( (i == id || is_spec_user[i]))
								{	
									if(showpre[i]==true && prestrafe[id]>min_prestrafe[id])
									{
										if((Pmaxspeed * 1.2)>prestrafe[id] )
										{
											if(jump_type[id]==Type_Up_Bhop_In_Duck && (uq_upbhopinduck==1 ))
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Up Bhop In Duck Pre: %.03f",prestrafe[id]);
											}
											else if(jump_type[id]==Type_Up_Bhop && (uq_upbj==1 ))
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Up Bhop Pre: %.03f",prestrafe[id]);
											}
											else if(jump_type[id]==Type_Up_Stand_Bhop && (uq_upsbj==1 ))
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Up StandUp Bhop Pre: %.03f",prestrafe[id]);
											}
											else if(jump_type[id]==Type_Bhop_In_Duck   &&  uq_bhopinduck==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Bhop In Duck Pre: %.03f",prestrafe[id]);
											}
											else if(jump_type[id]==Type_BhopLongJump   &&  uq_bj==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "BJ Pre: %.03f",prestrafe[id]);
											}
											else if(jump_type[id]==Type_StandupBhopLongJump  && uq_sbj==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "SBJ Pre: %.03f",prestrafe[id]);
											}
										}
										else
										{	
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 1.5, 0.1, 0.1, h_prest);
											show_hudmessage(i, "Your prestrafe %.01f is too high (%.01f)",prestrafe[id],Pmaxspeed * 1.2);
										}
									}
								}
							}
						}
						else if(jump_type[id]==Type_DuckBhop)
						{
							for( new i = 1; i < max_players; i++ )
							{
								if( (i == id || is_spec_user[i]))
								{	
									if(showpre[i]==true && speed>50.0)
									{
										if((Pmaxspeed * 1.2)>speed )
										{
											if(prestrafe[id]<200)
											{
												if(jump_type[id]==Type_DuckBhop && (uq_duckbhop==1))
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Duck Bhop Pre: %.03f",prestrafe[id]);
												}
											}
										}
									}
								}
							}
						}
					} 
					else
					{	
						frame_velocity[id][1] = velocity;
					}
					
					if( in_bhop[id] )
						fnSaveBeamPos( id );
			
					if(detecthj[id]!=1)
					{	
						starthj[id][0] = origin[0];
						starthj[id][1] = origin[1];
						starthj[id][2] = jumpoff_origin[id][2]+28.0;
						stophj[id][0] = origin[0];
						stophj[id][1] = origin[1];
						stophj[id][2] = starthj[id][2] - 133.0; 
							
						engfunc( EngFunc_TraceLine, starthj[id], stophj[id], IGNORE_MONSTERS, id, 0 );
						get_tr2( 0, TR_vecEndPos, endhj[id]);
						
						if(starthj[id][2]-endhj[id][2]<133.0 && (starthj[id][2]-endhj[id][2]-64)!=0 && (starthj[id][2]-endhj[id][2]-64)>0 && detecthj[id]!=1)
						{
							detecthj[id]=2;
						}
						
						if(starthj[id][2]-endhj[id][2]>=133.0 && detecthj[id]!=2)
						{
							detecthj[id]=1;
						}
					}
					
					if(ddafterJump[id])
						ddafterJump[id]=false;	
				}
				
				if(notjump[id] && bhopaem[id])
				{
					notjump[id]=false;
				}
				
				if( flags&FL_ONGROUND )
				{
					surf[id]=0.0;
					if (!pev( id, pev_solid ))
					{
						static ClassName[32];
						pev(pev(id, pev_groundentity), pev_classname, ClassName, 32);
			
						if( equali(ClassName, "func_train")
							|| equali(ClassName, "func_conveyor") 
							|| equali(ClassName, "trigger_push") || equali(ClassName, "trigger_gravity"))
						{
							JumpReset(id);
							set_task(0.4,"JumpReset", id);
						}
						else if(equali(ClassName, "func_door") || equali(ClassName, "func_door_rotating") )
						{
							JumpReset(id);
							set_task(0.4,"JumpReset", id);	
						}
					}
					
					pev(id, pev_origin, origin);
					notjump[id]=true;
					if(is_user_ducking(id))
					{
						falloriginz[id]=origin[2]+18;
					}
					else falloriginz[id]=origin[2];
					
					if( OnGround[id] == false)
					{	
						if (dropbhop[id] || in_ladder[id] || jump_type[id] == Type_WeirdLongJump || jump_type[id]==Type_ladderBhop || jump_type[id]==Type_Drop_BhopLongJump)
						{
							FallTime[id]=get_gametime();
							
						}
						OnGround[id] = true;
					}
				}
				
				if( !(flags&FL_ONGROUND) && notjump[id]==true && (movetype[id] != MOVETYPE_FLY) && jump_type[id]!=Type_ladderBhop )//&& jump_type[id] != Type_Drop_CountJump)
				{	
					pev(id, pev_origin, origin);
			
					OnGround[id] = false;
					
					pev(id, pev_velocity, velocity);
					
					new Float:tempfall;
					
					if(is_user_ducking(id))
					{
						tempfall=origin[2]+18;
					}
					else tempfall=origin[2];
					
					if( falloriginz[id]-tempfall>1.0 && !cjjump[id] && (ddforcj[id] || jump_type[id] == Type_Drop_CountJump || jump_type[id] == Type_StandUp_CountJump || jump_type[id] == Type_None || jump_type[id] == Type_CountJump || jump_type[id] == Type_Multi_CountJump || jump_type[id] == Type_Double_CountJump))
					{
						oldjump_type[id]=0;
			
						formatex(Jtype[id],32,"WeirdJump");
						formatex(Jtype1[id],32,"wj");
						
						if(ddforcj[id])
						ddforcj[id]=false;
						
						jump_type[id] = Type_WeirdLongJump;
					}
					
					if (velocity[2] == -240.0)
					{
							oldjump_type[id]=0;
							ddbeforwj[id]=true;
							jump_type[id] = Type_WeirdLongJump;	
							formatex(Jtype[id],32,"WeirdJump after dd");
							formatex(Jtype1[id],32,"dd+wj");
						
					}
				}
				else if(!(flags&FL_ONGROUND) && notjump[id]==false && (movetype[id] != MOVETYPE_FLY) && in_ladder[id]==false && jump_type[id] != Type_Slide)
				{
					oldjump_type[id]=0;
					OnGround[id] = false;
			
					pev(id, pev_velocity, velocity);
					pev(id, pev_origin, origin);
					
					new Float:drbh;
					if(is_user_ducking(id))
					{
						drbh=origin[2]+18;
					}
					else drbh=origin[2];
			
					if(dropbjorigin[id][2]-drbh>2.0)
					{
						if(dropbjorigin[id][2]-drbh<30 && jump_type[id] != Type_Drop_BhopLongJump && jump_type[id] != Type_None)
						{
							old_type_dropbj[id]=jump_type[id];
							formatex(Jtype_old_dropbj[id],32,Jtype[id]);
							formatex(Jtype_old_dropbj1[id],32,Jtype1[id]);
						}
						
						jump_type[id] = Type_Drop_BhopLongJump;
						formatex(Jtype[id],32,"Drop Bhop");
						formatex(Jtype1[id],32,"drbj");
						nextbhop[id]=false;
						bhopaem[id]=false;
						dropbhop[id]=true;
					}
				}
				
				if( movetype[id] == MOVETYPE_FLY) 
				{
					OnGround[id] = false;
					firstvel[id]=8.0;
					secvel[id]=0.0;
					checkladdertime[id]=get_gametime();
				}
				if( movetype[id] == MOVETYPE_FLY && firstladder[id]==false) 
				{
					firstladder[id]=true;
					nextbhop[id]=false;
					bhopaem[id]=false;
					h_jumped[id]=false;
					JumpReset(id);
					return FMRES_IGNORED;
				}
				if( movetype[id] != MOVETYPE_FLY && firstladder[id]==true && flags&FL_ONGROUND) 
				{
					firstladder[id]=false;
				}
				if( (movetype[id] == MOVETYPE_FLY) &&  (button&IN_FORWARD || button&IN_BACK || button&IN_LEFT || button&IN_RIGHT ) )
				{
					ladderjump[id]=true;
					find_sphere_class (id, "func_ladder",18.0, entlist1, 1);
					
					if(entlist1[0]!=0)
					{
						for(new i=0;i<nLadder;i++)
						{
							if(entlist[i]==entlist1[0])
							{
								nashladder=i;	
							}
						}
					}
			
					prestrafe[id]	= speed;
					maxspeed[id]	= speed;
				}
				
				if( (movetype[id] == MOVETYPE_FLY) &&  button&IN_JUMP )
				{
					jump_type[id]=Type_ladderBhop;
					formatex(Jtype[id],32,"Ladder BhopJump");
					formatex(Jtype1[id],32,"ldbj");
					ladderjump[id]=false;
					in_air[id]=false;
					in_ladder[id]=false;
					bhopaem[id]=false;
					notjump[id]=true;
					dropbhop[id]=false;		
				}
				
				if( movetype[id] != MOVETYPE_FLY && ladderjump[id]==true)
				{
					if(touch_ent[id])
					{
						JumpReset(id);
					}
					notjump[id]=true;
					dropbhop[id]=false;
					pev(id, pev_origin, origin);
					jumpoff_origin[id] = origin;
					jumpoff_origin[id][2]=ladderxyz[nashladder][2]+35.031250;
					
					jumpoff_time[id] = get_gametime( );
					strafecounter_oldbuttons[id] = 0;
					
					jump_type[id]=Type_ladder;
					laddertime[id]=get_gametime();
			
					formatex(Jtype[id],32,"LadderJump");
					formatex(Jtype1[id],32,"ldj");
					
					if(laddersize[nashladder][0]<=laddersize[nashladder][1])
					{
						laddist[id]=laddersize[nashladder][0]+0.03125;
					}
					else if(laddersize[nashladder][0]>laddersize[nashladder][1])
					{
						laddist[id]=laddersize[nashladder][1]+0.03125;
					}
					
					if(laddist[id]>10)
					{
						laddist[id]=4.0;
					}
					ladderjump[id]=false;	
					TempSpeed[id] = 0.0;
					static i;
					for( i = 0; i < NSTRAFES; i++ )
					{
						strafe_stat_speed[id][i][0] = 0.0;
						strafe_stat_speed[id][i][1] = 0.0;
						strafe_stat_sync[id][i][0] = 0;
						strafe_stat_sync[id][i][1] = 0;
						strafe_stat_time[id][i] = 0.0;
						strafe_lost_frame[id][i] = 0;
						
					}
					in_air[id]	= true;
					in_ladder[id]=true;
					g_Jumped[id]	= true;
					first_frame[id] = true;
					
					turning_right[id] = false;
					turning_left[id] = false;
					
					for( i = 0; i < 2; i++ )
					{
						frame_origin[id][i][0] = 0.0;
						frame_origin[id][i][1] = 0.0;
						frame_origin[id][i][2] = 0.0;
						
						frame_velocity[id][i][0] = 0.0;
						frame_velocity[id][i][1] = 0.0;
						frame_velocity[id][i][2] = 0.0;
					}
					for( i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{
							if(showpre[id]==true && uq_ladder==1 )
							{
								set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 1.0, 0.1, 0.1, h_prest);
								show_hudmessage(i, "Ladder Pre: %f",prestrafe[id]);
							}
						}
					}
				}
				
				
				if(button & IN_JUMP && flags & FL_ONGROUND)
				{
					x_jump[id]=true;
					if(is_user_ducking(id))
					{
						x_heightland_origin[id]=origin[2]+18;
					}
					else x_heightland_origin[id]=origin[2];
				}
				
				if((x_jump[id]==true || in_ladder[id]) && button & IN_DUCK && !(oldbuttons &IN_DUCK) && flags & FL_ONGROUND )
				{
					if(x_jump[id])
					{
						x_jump[id]=false;
						
						new Float:heightland_origin;
						if(is_user_ducking(id))
						{
							heightland_origin=origin[2]+18;
						}
						else heightland_origin=origin[2];
						if(heightland_origin-x_heightland_origin[id]>0 )
						{
							JumpReset(id);
							UpcjFail[id]=true;
							return FMRES_IGNORED;
						}
						ddforcj[id]=true;
					}
					else if(in_ladder[id])
					{
						new Float:heightland_origin;
						if(is_user_ducking(id))
						{
							heightland_origin=origin[2]+18;
						}
						else heightland_origin=origin[2];
						
						if(heightland_origin-jumpoff_origin[id][2]>-64)
						{
							JumpReset(id);
							UpcjFail[id]=true;
							in_ladder[id]=false;
							return FMRES_IGNORED;
						}
					}
				}
				
				if(cjjump[id]==false && (button & IN_DUCK || oldbuttons & IN_DUCK) && (jump_type[id] == Type_Drop_CountJump || ddafterJump[id] || jump_type[id]==Type_CountJump || jump_type[id]==Type_Multi_CountJump || jump_type[id]==Type_Double_CountJump))
				{
					if(origin[2]-duckstartz[id]<-1.21 && origin[2]-duckstartz[id]>-2.0)
					{
						if(ddafterJump[id])
						{
							nextbhop[id]=false;
							bhopaem[id]=false;
						}
						if(jump_typeOld[id]==1)
						{
							multiscj[id]=0;	
						}
						else if(jump_typeOld[id]==2)
						{
							multiscj[id]=1;	
						}
						else if(jump_typeOld[id]==3)
						{
							multiscj[id]=2;	
						}
						jump_type[id] = Type_StandUp_CountJump;
						
						formatex(Jtype[id],32,"StandUp CountJump");
						formatex(Jtype1[id],32,"scj");
						
						FallTime[id]=get_gametime();
					}
				}
				
				if( button & IN_DUCK && !(oldbuttons &IN_DUCK) && flags & FL_ONGROUND)
				{
					nextbhop[id]=false;
					bhopaem[id]=false;
					
					doubleduck[id]=true;
					doubletime[id]=get_gametime();
					FallTime1[id]=get_gametime();
					ddnum[id]++;
				}
				
				if(flags & FL_ONGROUND)
				{
					if(duckstartz[id]-origin[2]<18.0 && doubleduck[id]==true && (get_gametime()-doubletime[id]>0.4) && ddbeforwj[id]==false && (jump_type[id]==Type_CountJump || jump_type[id]==Type_Multi_CountJump || jump_type[id]==Type_Double_CountJump))
					{
						JumpReset(id);
						doubleduck[id]=false;
					}	
				}
				pev(id, pev_origin, origin);
				if(slide_protec[id]==false && button & IN_JUMP && !( oldbuttons & IN_JUMP ) && flags & FL_ONGROUND && bhopaem[id]==true && ddafterJump[id]==true && UpcjFail[id]==false)
				{
					if(touch_ent[id])
					{
						JumpReset(id);
					}
					ddnum[id]=0;
					notjump[id]=false;
					strafe_num[id]=0;
						
					if(get_gametime()-changetime[id]<0.5)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					
					if(task_exists(id+2311))
					remove_task(id+2311);
				
					jumpoff_origin[id] = origin;
				
					if(is_user_ducking( id )==true)
					{
						
						jumpoff_origin[id][2] = origin[2]+18.0;
					}
					else jumpoff_origin[id][2] = origin[2];
					
					jumpoff_time[id] = get_gametime( );
					strafecounter_oldbuttons[id] = 0;
			
					pev(id, pev_velocity, velocity);
					secorig[id]=origin;
					
					nextbhop[id]=true;
					if(jump_type[id]==Type_Drop_CountJump || jump_type[id]==Type_StandUp_CountJump || jump_type[id]==Type_CountJump || jump_type[id]==Type_Multi_CountJump || jump_type[id]==Type_Double_CountJump)
					{
						cjjump[id]=true;
					}
					if ( (jump_type[id] == Type_CountJump || jump_type[id] == Type_Multi_CountJump || jump_type[id] == Type_Double_CountJump) && floatabs(duckstartz[id]-jumpoff_origin[id][2])>4.0)
					{
						if(speed<200.0)
						{
							jump_type[id] = Type_LongJump;
							formatex(Jtype[id],32,"LongJump");
							formatex(Jtype1[id],32,"lj");
						}
						else
						{
							jump_type[id] = Type_WeirdLongJump;	
							formatex(Jtype[id],32,"WeirdJump");
							formatex(Jtype1[id],32,"wj");
						}
					}
					
					TempSpeed[id] = 0.0;
					
					static i;
					for( i = 0; i < NSTRAFES; i++ )
					{
						strafe_stat_speed[id][i][0] = 0.0;
						strafe_stat_speed[id][i][1] = 0.0;
						strafe_stat_sync[id][i][0] = 0;
						strafe_stat_sync[id][i][1] = 0;
						strafe_stat_time[id][i] = 0.0;
						strafe_lost_frame[id][i] = 0;
					}
					in_air[id]	= true;
					g_Jumped[id]	= true;
					first_frame[id] = true;
					
					prestrafe[id]	= speed;
					maxspeed[id]	= speed;
					
					turning_right[id] = false;
					turning_left[id] = false;
			
					for( i = 0; i < 2; i++ )
					{
						frame_origin[id][i][0] = 0.0;
						frame_origin[id][i][1] = 0.0;
						frame_origin[id][i][2] = 0.0;
						
						frame_velocity[id][i][0] = 0.0;
						frame_velocity[id][i][1] = 0.0;
						frame_velocity[id][i][2] = 0.0;
					}
					
					for( i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{
							if((Pmaxspeed * 1.2)>prestrafe[id])
							{	
								if(prestrafe[id]>min_prestrafe[id])
								{
									if(jump_type[id] == Type_Double_CountJump && showpre[id]==true && uq_dcj==1)
									{
										if(CjafterJump[id]==2)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "DCJ After Bhop Jump Pre: %.03f",prestrafe[id]);	
										}
									}
									else if(jump_type[id] == Type_CountJump && showpre[id]==true && uq_cj==1)
									{
										if(CjafterJump[id]==1)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "CJ After Bhop Jump Pre: %.03f",prestrafe[id]);	
										}
									}
									else if(jump_type[id] == Type_Multi_CountJump  && showpre[id]==true  && uq_mcj==1)
									{
										if(CjafterJump[id]==3)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "MCJ After Bhop Jump Pre: %.03f",prestrafe[id]);	
										}
									}
								}
			
							}
							else if(showpre[id]==true)
							{
								set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 1.5, 0.1, 0.1, h_prest);
								show_hudmessage(i, "Your prestrafe %.03f is too high (%.01f)",prestrafe[id],Pmaxspeed * 1.2);
							}	
						}
					}
				}
				else if(slide_protec[id]==false && button & IN_JUMP && !( oldbuttons & IN_JUMP ) && flags & FL_ONGROUND && bhopaem[id]==false && UpcjFail[id]==false)
				{	
					bhop_num[id]=0;
					notjump[id]=false;
					if(ddforcj[id]==true)
					{
						ddforcj[id]=false;
						if(nextbhop[id])
						{
							if(ddnum[id]==1)
							{
								jump_type[id]=Type_CountJump;
								CjafterJump[id]=1;
							}
							else if(ddnum[id]==2)
							{
								jump_type[id] = Type_Double_CountJump ;
								CjafterJump[id]=2;
							}
							else if(ddnum[id]>=3)
							{
								jump_type[id] = Type_Multi_CountJump;
								CjafterJump[id]=3;
							}
							ddnum[id]=0;
							nextbhop[id]=false;
							bhopaem[id]=false;
						}
						else if(jump_type[id]==Type_Real_ladder_Bhop)
						{
							jump_type[id]=Type_Drop_CountJump;
						}
					}
					
					oldjump_height[id]=0.0;
					jheight[id]=0.0;
					
					if(nextbhop[id] && ddafterJump[id]==false)
					{
						FullJumpFrames[id]=0;
						direct_for_strafe[id]=0;
						
						if(uq_istrafe)
						{
							for(new i=0;i<=line_erase_strnum[id];i++)
							{
								for( new j = 0; j <= line_erase[id][i]; j++ )
								{
									line_lost[id][i][j]=0;
									lost_frame_count[id][i]=0;
								}
							}
						}
						
						edgedone[id]=false;
						if(get_gametime()-checkladdertime[id]<0.5)
						{
							ladderbug[id]=true;
						}
						
						if(touch_ent[id])
						{
							JumpReset(id);
						}
						ddnum[id]=0;
						
						if(cjjump[id]==true && (get_gametime()-duckoff_time[id])<0.2)
						{
							JumpReset(id);
							return FMRES_IGNORED;
							
						}
					
						if(oldbuttons & IN_DUCK && button & IN_DUCK && duckbhop[id]==true && (jump_type[id]==Type_HighJump || jump_type[id]==Type_LongJump || jump_type[id]==Type_None))
						{
							jump_type[id]=Type_DuckBhop;
							formatex(Jtype[id],32,"DuckBhop");
							formatex(Jtype1[id],32,"dkbj");
							duckbhop[id]=false;
						}
						
						bhopaem[id]=true;
						
						pev(id, pev_origin, origin);
						static bool:ducking;
						ducking = is_user_ducking( id ); 
						strafecounter_oldbuttons[id] = 0;
					
						strafe_num[id] = 0;
						TempSpeed[id] = 0.0;
						in_bhop[id] = true;
						pre_jumpoff_origin[id] = jumpoff_origin[id];
						jumpoff_foot_height[id] = ducking ? origin[2] - 18.0 : origin[2] - 36.0; //todo:think about this gavno
						
						jumpoff_time[id] = get_gametime( );
						
						new Float:checkbhop;
						
						if(is_user_ducking(id)==true)
						{
							checkbhop=jumpoff_origin[id][2]-origin[2]-18.0;
						}
						else checkbhop=jumpoff_origin[id][2]-origin[2];
						
						if(checkbhop<-1.0)
						{
							if(button & IN_DUCK )
							{
								jump_type[id]=Type_Up_Bhop_In_Duck;
							}
							upbhop_koeff[id]=UpBhop_calc(floatabs(checkbhop));
							upheight[id]=floatabs(checkbhop);
							upBhop[id]=true;
						}
						else if(jump_type[id]!=Type_DuckBhop)
						{
							if(button & IN_DUCK )
							{
								jump_type[id]=Type_Bhop_In_Duck;
							}
						}
						
						jumpoff_origin[id] = origin;
						if(is_user_ducking( id )==true)
						{
							
							jumpoff_origin[id][2] = origin[2]+18.0;
						}
						else jumpoff_origin[id][2] = origin[2];
						
						pev(id, pev_velocity, velocity);
						first_frame[id] = true;
						
						prestrafe[id] = speed;
						maxspeed[id] = speed;
						
						static i;
						for( i = 0; i < NSTRAFES; i++ )
						{
							strafe_stat_speed[id][i][0] = 0.0;
							strafe_stat_speed[id][i][1] = 0.0;
							strafe_stat_sync[id][i][0] = 0;
							strafe_stat_sync[id][i][1] = 0;
							strafe_stat_time[id][i] = 0.0;
							strafe_lost_frame[id][i] = 0;
						}
						for( i = 0; i < 2; i++ )
						{
							frame_origin[id][i][0] = 0.0;
							frame_origin[id][i][1] = 0.0;
							frame_origin[id][i][2] = 0.0;
							
							frame_velocity[id][i][0] = 0.0;
							frame_velocity[id][i][1] = 0.0;
							frame_velocity[id][i][2] = 0.0;
						}
						in_air[id]	= true;
						g_Jumped[id]	= true;
						turning_right[id] = false;
						turning_left[id] = false;
					}
					else 
					{
						if(get_gametime()-checkladdertime[id]<0.5 && jump_type[id]!=Type_ladderBhop)
						{
							ladderbug[id]=true;
						}
						
						if(touch_ent[id])
						{
							JumpReset(id);
						}	
						ddnum[id]=0;
						if(in_ladder[id]==true)
						{
							in_ladder[id]=false;
							
							jump_type[id]=Type_Real_ladder_Bhop;
							
							formatex(Jtype[id],32,"Real Ladder bhop");
							formatex(Jtype1[id],32,"rldbj");
							
						}
						
						strafe_num[id]=0;
						
						if(get_gametime()-changetime[id]<0.5)
						{
							JumpReset(id);
							return FMRES_IGNORED;
						}
						
						if(task_exists(id+2311))
							remove_task(id+2311);
						
						pev(id, pev_velocity, velocity);
						
						if(jump_type[id]!=Type_ladderBhop)
						{
							if(oldjump_typ1[id]==1)
							{
								jump_type[id]=Type_ladderBhop;
								oldjump_typ1[id]=0;
							}
						}
						
						
						
						jumpoff_origin[id] = origin;
						
						if(is_user_ducking(id))
						{
							jumpoff_origin[id][2] = origin[2]+18.0;
						}
						else jumpoff_origin[id][2] = origin[2];
						
						jumpoff_time[id] = get_gametime( );
						strafecounter_oldbuttons[id] = 0;
						
						pev(id, pev_origin, origin);
						if(is_user_ducking(id))
						{
							dropbjorigin[id][2]=origin[2]+18;
						}
						else dropbjorigin[id][2]=origin[2];
						dropbjorigin[id][0]=origin[0];
						dropbjorigin[id][1]=origin[1];
						pev(id, pev_velocity, velocity);
						secorig[id]=origin;
						
						nextbhop[id]=true;
						
						
						if(dropbhop[id] && jump_type[id] != Type_Drop_CountJump && jump_type[id] != Type_StandUp_CountJump)
						{
							dropbhop[id]=false;
							jump_type[id] = Type_Drop_BhopLongJump; 
						}
						else dropbhop[id]=false;
						
						if(jump_type[id]==Type_CountJump || jump_type[id]==Type_Multi_CountJump || jump_type[id]==Type_Double_CountJump)
						{
							cjjump[id]=true;
						}
						if ( (jump_type[id] == Type_CountJump || jump_type[id] == Type_Multi_CountJump || jump_type[id] == Type_Double_CountJump) && floatabs(duckstartz[id]-jumpoff_origin[id][2])>4.0)
						{
							if(speed<200.0)
							{
								jump_type[id] = Type_LongJump;
								formatex(Jtype[id],32,"LongJump");
								formatex(Jtype1[id],32,"lj");
							}
							else
							{
								jump_type[id] = Type_WeirdLongJump;	
								formatex(Jtype[id],32,"WeirdJump");
								formatex(Jtype1[id],32,"wj");
							}
						}
						if(jump_type[id] == Type_Drop_CountJump && multidropcj[id]==0 && (origin[2]-first_duck_z[id])>4)
						{
							JumpReset(id);
							return FMRES_IGNORED;
						}
						prestrafe[id]	= speed;
						maxspeed[id]	= speed;
						new Float:kkk;
							
						kkk=1.112*Pmaxspeed;
						
						if(prestrafe[id]<kkk && jump_type[id] !=Type_ladderBhop && jump_type[id] != Type_Drop_BhopLongJump && jump_type[id] != Type_WeirdLongJump && jump_type[id] != Type_CountJump && jump_type[id] != Type_Multi_CountJump && jump_type[id] != Type_Double_CountJump && jump_type[id] != Type_BhopLongJump && jump_type[id] != Type_StandupBhopLongJump && jump_type[id] != Type_Drop_CountJump)
						{
							if(jump_type[id] != Type_Drop_CountJump && jump_type[id] != Type_StandUp_CountJump && jump_type[id] !=Type_Real_ladder_Bhop)
							{
								jump_type[id] = Type_LongJump;
								formatex(Jtype[id],32,"LongJump");
								formatex(Jtype1[id],32,"lj");
								
								if((jumpoff_origin[id][2]-origin[2])==18.0 && oldbuttons & IN_DUCK && button & IN_DUCK && duckbhop[id]==false)
								{
									duckbhop[id]=true;
									//client_print(id,print_chat,"%f",jumpoff_origin[id][2]-origin[2]);
									
									find_sphere_class (id, "func_ladder",100.0, entlist1, 1);
									if(entlist1[0]!=0)
									{
										if(get_gametime()-checkladdertime[id]<0.1 || prestrafe[id]>110)
										{
											ladderbug[id]=true;
										}
										else if(entlist1[0]!=0)
										{
											ladderbug[id]=true;
										}
										find_ladder[id]=true;
									}
								}
								else duckbhop[id]=false;
							}
						}
						
						TempSpeed[id] = 0.0;
						
						static i;
						for( i = 0; i < NSTRAFES; i++ )
						{
							strafe_stat_speed[id][i][0] = 0.0;
							strafe_stat_speed[id][i][1] = 0.0;
							strafe_stat_sync[id][i][0] = 0;
							strafe_stat_sync[id][i][1] = 0;
							strafe_stat_time[id][i] = 0.0;
							strafe_lost_frame[id][i] = 0;
						}
						in_air[id]	= true;
						g_Jumped[id]	= true;
						first_frame[id] = true;
						
						prestrafe[id]	= speed;
						maxspeed[id]	= speed;
						
						turning_right[id] = false;
						turning_left[id] = false;
						
						for( i = 0; i < 2; i++ )
						{
							frame_origin[id][i][0] = 0.0;
							frame_origin[id][i][1] = 0.0;
							frame_origin[id][i][2] = 0.0;
							
							frame_velocity[id][i][0] = 0.0;
							frame_velocity[id][i][1] = 0.0;
							frame_velocity[id][i][2] = 0.0;
						}
						
						if(jump_type[id]==Type_LongJump && prestrafe[id]>kkk)
						{
							jump_type[id] = Type_WeirdLongJump;
							formatex(Jtype[id],32,"WeirdJump");
							formatex(Jtype1[id],32,"wj");
							
						}
						
						for( i = 1; i < max_players; i++ )
						{
							if( (i == id || is_spec_user[i]))
							{
								if((Pmaxspeed * 1.2)>prestrafe[id])
								{	
									if(prestrafe[id]>min_prestrafe[id])
									{
										if(jump_type[id] == Type_Double_CountJump && showpre[id]==true && uq_dcj==1)
										{
											if(CjafterJump[id]==2)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "DCJ After Jump Pre: %.03f",prestrafe[id]);	
											}
											else
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "DCJ Pre: %.03f",prestrafe[id]);
											}
										}
										else if(jump_type[id] == Type_CountJump && showpre[id]==true && uq_cj==1)
										{
											if(CjafterJump[id]==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "CJ After Jump Pre: %.03f",prestrafe[id]);	
											}
											else
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "CJ Pre: %.03f",prestrafe[id]);
											}
										}
										else if(jump_type[id] == Type_Multi_CountJump  && showpre[id]==true  && uq_mcj==1)
										{
											if(CjafterJump[id]==3)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "MCJ After Jump Pre: %.03f",prestrafe[id]);	
											}
											else
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "MCJ Pre: %.03f",prestrafe[id]);
											}
										}
										else if(jump_type[id] == Type_LongJump && showpre[id]==true && ljpre[id]==true && uq_lj==1)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "Prestrafe: %.03f",prestrafe[id]);
										}
										else if(jump_type[id] == Type_WeirdLongJump && showpre[id]==true && ddbeforwj[id]==true  && uq_wj==1)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "DD+WJ Pre: %.03f",prestrafe[id]);
										}
										else if(jump_type[id] == Type_WeirdLongJump && showpre[id]==true && ddbeforwj[id]==false && uq_wj==1)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "WJ Pre: %.03f",prestrafe[id]);
										}
										else if((jump_type[id] == Type_Drop_BhopLongJump)&& showpre[id]==true && uq_drbj==1 )
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "Drop BJ Pre: %.03f",prestrafe[id]);
										}
										else if((jump_type[id] == Type_ladderBhop)&& showpre[id]==true && uq_ldbj==1 )
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "Ladder Bhop Pre: %.03f",prestrafe[id]);
										}
										else if((jump_type[id]==Type_Drop_CountJump)&& showpre[id]==true)
										{
											if(multidropcj[id]==0 && uq_drcj==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Drop CJ Pre: %.03f",prestrafe[id]);
											}
											else if(multidropcj[id]==1 && uq_dropdcj==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Double Drop CJ Pre: %.03f",prestrafe[id]);
											}
											else if(multidropcj[id]==2 && uq_dropmcj==1)
											{
												set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
												show_hudmessage(i, "Multi Drop CJ Pre: %.03f",prestrafe[id]);
											}
										}
										else if((jump_type[id]==Type_StandUp_CountJump) && showpre[id]==true && uq_drsbj==1)
										{
											if(dropaem[id])
											{
												if(multiscj[id]==0 && uq_dropscj==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Drop SCJ Pre: %.03f",prestrafe[id]);
												}
												else if(multiscj[id]==1 && uq_dropdscj==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Drop Double SCJ Pre: %.03f",prestrafe[id]);
												}
												else if(multiscj[id]==2 && uq_dropmscj==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Drop Multi SCJ Pre: %.03f",prestrafe[id]);
												}
											}
											else if(ddafterJump[id])
											{
												if(multiscj[id]==0)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "SCJ After Jump Pre: %.03f",prestrafe[id]);
												}
												else if(multiscj[id]==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Double SCJ After Jump Pre: %.03f",prestrafe[id]);
												}
												else if(multiscj[id]==2)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Multi SCJ After Jump Pre: %.03f",prestrafe[id]);
												}
											}
											else
											{
												if(multiscj[id]==0 && uq_drsbj==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "SCJ Pre: %.03f",prestrafe[id]);
												}
												else if(multiscj[id]==1 && uq_dscj==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Double SCJ Pre: %.03f",prestrafe[id]);
												}
												else if(multiscj[id]==2 && uq_mscj==1)
												{
													set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
													show_hudmessage(i, "Multi SCJ Pre: %.03f",prestrafe[id]);
												}
											}
										}
										else if((jump_type[id]==Type_Real_ladder_Bhop) && showpre[id]==true && uq_realldbhop==1)
										{
											set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
											show_hudmessage(i, "Real ladder Bhop Pre: %.03f",prestrafe[id]);
										}
									}
								}
								else if(showpre[id]==true)
								{
									set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 1.5, 0.1, 0.1, h_prest);
									show_hudmessage(i, "Your prestrafe %.03f is too high (%.01f)",prestrafe[id],Pmaxspeed * 1.2);
								}
							}
						}
					}
				}
				else if(slide_protec[id]==false && ddafterJump[id]==false && UpcjFail[id]==false && bhopaem[id]==true && button & IN_JUMP && !( oldbuttons & IN_JUMP ) && flags & FL_ONGROUND)
				{
					if(touch_ent[id])
					{
						JumpReset(id);
					}
					ddnum[id]=0;
					if(ddforcj[id]==true)
					{
						ddforcj[id]=false;
						JumpReset(id);
						return FMRES_IGNORED;
					}
					pev(id, pev_origin, origin);
					static bool:ducking;
					ducking = is_user_ducking( id );
					strafecounter_oldbuttons[id] = 0;
				
					strafe_num[id] = 0;
					TempSpeed[id] = 0.0;
					
					pre_jumpoff_origin[id] = jumpoff_origin[id];
					jumpoff_foot_height[id] = ducking ? origin[2] - 18.0 : origin[2] - 36.0;
					
					jumpoff_time[id] = get_gametime( );
					
					jumpoff_origin[id] = origin;
					if(is_user_ducking( id )==true)
					{
						jumpoff_origin[id][2] = origin[2]+18.0;
					}
					else jumpoff_origin[id][2] = origin[2];
					pev(id, pev_velocity, velocity);
					
					first_frame[id] = true;
					
					prestrafe[id] = speed;
					maxspeed[id] = speed;
					
					static i;
					for( i = 0; i < NSTRAFES; i++ )
					{
						strafe_stat_speed[id][i][0] = 0.0;
						strafe_stat_speed[id][i][1] = 0.0;
						strafe_stat_sync[id][i][0] = 0;
						strafe_stat_sync[id][i][1] = 0;
						strafe_stat_time[id][i] = 0.0;
						strafe_lost_frame[id][i] = 0;
					}
					for( i = 0; i < 2; i++ )
					{
						frame_origin[id][i][0] = 0.0;
						frame_origin[id][i][1] = 0.0;
						frame_origin[id][i][2] = 0.0;
						
						frame_velocity[id][i][0] = 0.0;
						frame_velocity[id][i][1] = 0.0;
						frame_velocity[id][i][2] = 0.0;
					}
					in_air[id]	= true;
					g_Jumped[id]	= true;
					turning_right[id] = false;
					turning_left[id] = false;
					jump_type[id]=Type_Multi_Bhop;
					formatex(Jtype[id],32,"Multi Bhop");
					formatex(Jtype1[id],32,"mbj");
				
					bhop_num[id]++;
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{	
							if(showpre[i]==true && multibhoppre[id] && speed>50.0)
							{
								if((Pmaxspeed * 1.2)>speed && (uq_bj==1 || uq_sbj==1))
								{
									set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
									show_hudmessage(i, "Multi Bhop Pre: %.03f",speed);
								}
								else
								{	if((uq_bj==1 || uq_sbj==1))
									{
										set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 1.5, 0.1, 0.1, h_prest);
										show_hudmessage(i, "Your prestrafe %.01f is high(%.01f)",prestrafe[id],Pmaxspeed * 1.2);
									}
								}
							}
						}
					}
				}
				else if(slide_protec[id]==false && ddafterJump[id]==false && UpcjFail[id]==false && !(button&IN_JUMP) && oldbuttons&IN_JUMP && flags & FL_ONGROUND && nextbhop[id]==true && cjjump[id]==false && bhopaem[id]==false && jump_type[id]!=Type_Drop_BhopLongJump)	
				{		
					if(touch_ent[id])
					{
						JumpReset(id);
					}
					ddnum[id]=0;
					if(ddforcj[id]==true)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					bhop_num[id]=0;
			
					if(oldbuttons & IN_DUCK && button & IN_DUCK && duckbhop[id]==true && (jump_type[id]==Type_LongJump || jump_type[id]==Type_None))
					{
						jump_type[id]=Type_DuckBhop;
						formatex(Jtype[id],32,"DuckBhop");
						formatex(Jtype1[id],32,"dkbj");
						duckbhop[id]=false;
					}
					else
					{
						bhopaem[id]=true;
						
						static i;
						for( i = 1; i < max_players; i++ )
						{
							if( (i == id || is_spec_user[i]))
							{	
								if(showpre[id]==true && failearly[id]==true && (uq_bj==1 || uq_sbj==1))
								{
									set_hudmessage(255, 0, 109, -1.0, 0.70, 0, 0.0, 0.5, 0.1, 0.1, h_stats);
									show_hudmessage(id, "You pressed jump too early");
								}
							}
						}
					}
				}
				else if( ( failed_jump[id] || flags&FL_ONGROUND)&& in_air[id] )
				{	
					if(old_type_dropbj[id]!=Type_Null && jump_type[id]==Type_Drop_BhopLongJump)
					{
						jump_type[id]=old_type_dropbj[id];
						
						formatex(Jtype[id],32,Jtype_old_dropbj[id]);
						formatex(Jtype1[id],32,Jtype_old_dropbj1[id]);
					}
					if(bug_true[id])
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					if(prestrafe[id]>200 && jump_type[id]==Type_DuckBhop)
					{
						duckbhop_bug_pre[id]=true;
						set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 1.5, 0.1, 0.1, h_prest);
						show_hudmessage(id, "Your prestrafe %.01f probably bugged for DuckBhop",prestrafe[id]);
					}
					new summad,summws;
					for(new i=0;i<NSTRAFES;i++)
					{
						if(type_button_what[id][i]==1)
						summad++;
						if(type_button_what[id][i]==2)
						summws++;
					}
					if(summws>summad)
					{
						if(backwards[id])
						{
							pre_type[id] = "[Backwards-Sideways]";
						}
						else pre_type[id] = "[Sideways]";
					}
					else if(backwards[id])
					{
						pre_type[id] = "[Backwards]";
					}
					else pre_type[id] = "";
			
					static bool:ducking;
					
					static type[33];
					type[0] = '^0';
					new bool:failed;
					if (failed_jump[id] == true)
					{
						formatex( type, 32, "" );
						failed=true;
						origin=failed_origin[id];
					}
					else
					{
						pev(id, pev_origin, origin);
						ducking = is_user_ducking( id );
						failed=false;
					}
					
					if(donehook[id])
					{
						donehook[id]=false;
						failed_jump[id]=true;
						client_print(id,print_center,"Hook protection");		
					}	
					if(failed==false)
					{
						height_difference[id] =  ducking ? jumpoff_origin[id][2] - origin[2] - 18.0 : jumpoff_origin[id][2] - origin[2];
						if(jump_type[id] == Type_BhopLongJump || jump_type[id] == Type_StandupBhopLongJump || jump_type[id]==Type_Bhop_In_Duck)
						{
							if(height_difference[id] <-22.0)
							{
								JumpReset(id);
								return FMRES_IGNORED;
							}
							
							if(height_difference[id] > -18.0)
							{
								if(height_difference[id] <= -1.0)
								{
									JumpReset(id);
									return FMRES_IGNORED;
								}	
							}
						}
						else
						{
							if(height_difference[id] < -1.0)
							{
								if((jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_StandUp_CountJump) && height_difference[id]==-18.0)
								{
									//ColorChat(id, GREEN, "ne reset");
								}
								else
								{	
									JumpReset(id);
									return FMRES_IGNORED;	
								}
							}	
						}
						if(jump_type[id]==Type_StandupBhopLongJump)
						{
							if(height_difference[id] > 1.0)
							failed_jump[id]=true; 
						}
						else if(height_difference[id] > 0.0 && jump_type[id]!=Type_Drop_BhopLongJump )
						{
							JumpReset(id);
							return FMRES_IGNORED; 
						}
						else if(height_difference[id] > 0.02 && jump_type[id]==Type_Drop_BhopLongJump )
						{
							failed_jump[id]=true; 
						}
					}
					
					if( is_user_ducking(id))
					{
						origin[2]+=18.0;
					}
					
					static Float:distance1;
					if(jump_type[id] == Type_ladder)
					{
						distance1 = get_distance_f( jumpoff_origin[id], origin )+laddist[id];
					}
					else distance1 = get_distance_f( jumpoff_origin[id], origin ) + 32.0;
					
					if( is_user_ducking(id) )
					{
						origin[2]-=18.0;
					}
					
					if( frame_velocity[id][1][0] < 0.0 ) frame_velocity[id][1][0] *= -1.0;
					if( frame_velocity[id][1][1] < 0.0 ) frame_velocity[id][1][1] *= -1.0;
					
					static Float:land_origin[3];
					
					land_origin[2] = frame_velocity[id][0][2] * frame_velocity[id][0][2] + (2 * get_pcvar_float(sv_gravity) * (frame_origin[id][0][2] - origin[2]));
					
					rDistance[0] = (floatsqroot(land_origin[2]) * -1) - frame_velocity[id][1][2];
					rDistance[1] = get_pcvar_float(sv_gravity)*-1;
					
					frame2time = floatdiv(rDistance[0], rDistance[1]);
					if(frame_velocity[id][1][0] < 0 )
					frame_velocity[id][1][0] = frame_velocity[id][1][0]*-1;
					rDistance[0] = frame2time*frame_velocity[id][1][0];
						
					if( frame_velocity[id][1][1] < 0 )
					frame_velocity[id][1][1] = frame_velocity[id][1][1]*-1;
					rDistance[1] = frame2time*frame_velocity[id][1][1];
			
					if( frame_velocity[id][1][2] < 0 )
					frame_velocity[id][1][2] = frame_velocity[id][1][2]*-1;
					rDistance[2] = frame2time*frame_velocity[id][1][2];
					
					if( frame_origin[id][1][0] < origin[0] )
					land_origin[0] = frame_origin[id][1][0] + rDistance[0];
					else
					land_origin[0] = frame_origin[id][1][0] - rDistance[0];
					if( frame_origin[id][1][1] < origin[1] )
					land_origin[1] = frame_origin[id][1][1] + rDistance[1];
					else
					land_origin[1] = frame_origin[id][1][1] - rDistance[1];
					
					if( is_user_ducking(id) )
					{
						origin[2]+=18.0;
						duckstring[id]=true;
					}
			
					land_origin[2] = origin[2];
					
					frame2time += (last_land_time[id]-jumpoff_time[id]);
					
					static Float:distance2;
					if(jump_type[id] == Type_ladder)
					{
						distance2 = get_distance_f( jumpoff_origin[id], land_origin ) +laddist[id];
					}
					else distance2 = get_distance_f( jumpoff_origin[id], land_origin ) + 32.0;
					
					if(failed==true)
					{
						if(jump_type[id] == Type_ladder)
						{
							distance[id] = GetFailedDistance(laddist[id],failed_ducking[id], GRAVITY, jumpoff_origin[id], velocity, failed_origin[id], failed_velocity[id]);
						}
						else distance[id] = GetFailedDistance(32.0,failed_ducking[id], GRAVITY, jumpoff_origin[id], velocity, failed_origin[id], failed_velocity[id]);
					}
					else distance[id] = distance1 > distance2 ? distance2 : distance1; //distance
					
					
					new Float:Landing,bool:land_bug;
					
					if(jump_type[id]!=Type_ladder && distance[id]>64.0)
					{
						new Float:landing_orig[3];
						
						landing_orig=origin;
						landing_orig[2]=landing_orig[2]-36.1;
						
						Landing=LandingCalculate(id,landing_orig,jumpoff_origin[id]);
						if(distance[id]<(jumpblock[id]+edgedist[id]+Landing))
						{
							landing_orig=land_origin;
							landing_orig[2]=landing_orig[2]-36.1;
							
							Landing=LandingCalculate(id,landing_orig,jumpoff_origin[id]);
							Landing=Landing-0.06250;
							land_bug=true;
						}
						else land_bug=false;
					}
					
					if(!uq_noslow && entity_get_float(id,EV_FL_fuser2)==0.0 && jump_type[id] != Type_ladder)
					{
						failed_jump[id]=true;
					}
					if(fps_hight[id] && jump_type[id]!=Type_ladder)
					{
						failed_jump[id]=true;
					}
					if(duckbhop_bug_pre[id])
					{
						failed_jump[id]=true;
					}
					
					new tmp_dist,tmp_min_dist,tmp_maxdist,tmp_mindist_other;
					if(Pmaxspeed != 250.0 && jump_type[id]!=Type_ladder)
					{
						tmp_dist=floatround((250.0-Pmaxspeed)*0.73,floatround_floor);
						
						tmp_min_dist=min_distance-tmp_dist;
						
					}
					else tmp_min_dist=min_distance;
					
					tmp_maxdist=max_distance;
					tmp_mindist_other=min_distance_other;
					
					if(jump_type[id]!=Type_Bhop_In_Duck && jump_type[id]!=Type_Up_Bhop_In_Duck && jump_type[id]!=Type_Up_Stand_Bhop  && jump_type[id] != Type_Up_Bhop && jump_type[id] != Type_ladder && jump_type[id] != Type_Multi_Bhop && jump_type[id]!=Type_DuckBhop && jump_type[id]!=Type_Real_ladder_Bhop)
					{
						if( distance[id] < tmp_min_dist || tmp_maxdist < distance[id] )
						{
							JumpReset(id);
							return FMRES_IGNORED;
						}
					}
					else if( jump_type[id] == Type_ladder && (distance[id] > tmp_maxdist || distance[id] < tmp_mindist_other))
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if( (jump_type[id] == Type_Multi_Bhop || jump_type[id]==Type_Real_ladder_Bhop) && (distance[id] > tmp_maxdist || distance[id] < tmp_mindist_other))
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if( (jump_type[id]==Type_Bhop_In_Duck || jump_type[id]==Type_Up_Bhop_In_Duck || jump_type[id]==Type_Up_Stand_Bhop ||  jump_type[id] == Type_Up_Bhop || jump_type[id]==Type_Real_ladder_Bhop)&& (distance[id] > tmp_maxdist || distance[id] < tmp_mindist_other))
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if( jump_type[id]==Type_DuckBhop && (distance[id] > tmp_maxdist || distance[id] < tmp_min_dist-150))
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					
					
					
					if( jump_type[id] == Type_LongJump ) 
					{			
						oldjump_type[id]=1;
					}
					else oldjump_type[id]=0;
					
					if(jump_type[id] == Type_LongJump && detecthj[id]==1) 
					{
						jump_type[id] = Type_HighJump;
						formatex(Jtype[id],32,"HighJump");
						formatex(Jtype1[id],32,"hj");
					}
					if(touch_somthing[id])
					{
						failed_jump[id]=true;
					}
					
					new wpn,weapon_name[21],clip,ammo;
					
					wpn = get_user_weapon(id,clip,ammo);
					if(wpn)
					{
						get_weaponname(wpn,weapon_name,20);
						replace(weapon_name,20,"weapon_","");
					}
					else formatex(weapon_name,20,"Unknow");
	
					new t_type;
					t_type=0;
					
					switch(jump_type[id])
					{
						case 0: t_type=1;
						case 1: t_type=1;
						case 2: t_type=2;
						case 9: t_type=2;
						case 11:t_type=2;
						case 6: t_type=2;
						case 7: t_type=2;
						case 15: t_type=2;
						case 17: t_type=2;
						case 18: t_type=2;
						case 19: t_type=2;
						case 3: t_type=3;
						case 5: t_type=3;
						case 21: t_type=3;
						case 22: t_type=3;
						case 13: t_type=4;
						case 23: t_type=5;
						case 24:t_type=5;
						case 12: t_type=6;
					}
					
					if(uq_bug==1 && check_for_bug_distance(distance[id],t_type,Pmaxspeed))
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					if(uq_bug==1)
					{
						new Float:b_check=2.1;
						
						if(jump_type[id]==Type_ladder)
						{
							b_check=b_check-0.1;
						}
						
						if((maxspeed[id]+prestrafe[id])/distance[id]<b_check)
						{
							JumpReset(id);
							return FMRES_IGNORED;
						}
					}
					new dom_dist,god_dist,leet_dist,holy_dist,pro_dist,good_dist;
					new d_array[6];
					
					d_array=get_colorchat_by_distance(jump_type[id],Pmaxspeed,tmp_dist,dropaem[id],multiscj[id],aircj);
					dom_dist=d_array[5];
					god_dist=d_array[4];
					leet_dist=d_array[3];
					holy_dist=d_array[2];
					pro_dist=d_array[1];
					good_dist=d_array[0];
					
					
					//streifs stat
					sync_[id] = 0;
					strMess[0] = '^0'; //unnecessary?
					strMessBuf[0] = '^0'; //unnecessary?
					strLen = 0;
					badSyncTemp = 0;
					goodSyncTemp = 0;
					new Float:tmpstatspeed[NSTRAFES],Float:tmpstatpoteri[NSTRAFES];
								
					Fulltime = last_land_time[id]-jumpoff_time[id];
					if(strafe_num[id] < NSTRAFES)
					{
						strafe_stat_time[id][0] = jumpoff_time[id];
						strafe_stat_time[id][strafe_num[id]] =last_land_time[id];
						for(jj = 1;jj <= strafe_num[id]; jj++)
						{
							//client_print(id,print_chat,"%d=%d,%d - %d",jj,strafe_stat_sync[id][jj][0],strafe_stat_sync[id][jj][1],strafe_lost_frame[id][jj]);

							time_ = ((strafe_stat_time[id][jj] - strafe_stat_time[id][jj-1])*100) / (Fulltime);
							if ((strafe_stat_sync[id][jj][0]+strafe_stat_sync[id][jj][1]) > 0)
							{
								sync_[id] =(strafe_stat_sync[id][jj][0] * 100)/(strafe_stat_sync[id][jj][0]+strafe_stat_sync[id][jj][1]); //using like a buffer		
							}				
							else
							{
								sync_[id] = 0;
							}
							strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t%2d^t%4.3f^t%4.3f^t%3.1f%%^t%3d%%^n", jj, strafe_stat_speed[id][jj][0], strafe_stat_speed[id][jj][1], time_, sync_[id]);
							goodSyncTemp += strafe_stat_sync[id][jj][0];
							badSyncTemp += strafe_stat_sync[id][jj][1];
							tmpstatspeed[jj]=strafe_stat_speed[id][jj][0];
							tmpstatpoteri[jj]=strafe_stat_speed[id][jj][1];
							
							if(tmpstatpoteri[jj]>200)
							{
								if(duckstring[id]==false)
								duckstring[id]=true;
							}
							if(tmpstatpoteri[jj]>200 && Checkframes[id])
							{
								Checkframes[id]=false;
								failed_jump[id]=true;
							}
						}
						//client_print(id,print_chat,"full=%d - %d,%d",FullJumpFrames[id],strafe_stat_sync[id][0][0],strafe_stat_sync[id][0][1]);

						if(strafe_num[id]!=0)
						{
							if (jump_type[id]==Type_ladder && strafe_stat_speed[id][0][0]!=0)
							{	
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t^tTurn speed: %4.3f",strafe_stat_speed[id][0][0]);
							}
							if (duckstring[id]==false)
							{							
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t^tNo duck");
							}
							if (jump_type[id]==Type_StandupBhopLongJump || jump_type[id]==Type_Up_Stand_Bhop)
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^tStand-Up");
							}
							if(wpn!=29 && wpn!=17 && wpn!=16)
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tWeapon: %s",weapon_name);
							}
							
							if(Show_edge[id] && failed_jump[id]==false && jump_type[id]!=Type_ladder && jumpblock[id]<user_block[id][0] && jumpblock[id]>user_block[id][1] && edgedist[id]<100.0 && edgedist[id]!=0.0 && (jumpblock[id]+edgedist[id])<distance[id])
							{
								if((jumpblock[id]+Landing+edgedist[id])>(distance[id]+10.0) || Landing<=0.0)
								{
									strLen =strLen+format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tBlock -- %d^n^tJumpoff -- %f",jumpblock[id],edgedist[id]);
								}
								else if(land_bug)
								{
									strLen =strLen+format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tBlock -- %d^n^tJumpoff -- %f^n^tLanding -- %f(bg)",jumpblock[id],edgedist[id],Landing);
								}
								else strLen =strLen+format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tBlock -- %d^n^tJumpoff -- %f^n^tLanding -- %f",jumpblock[id],edgedist[id],Landing);
							}
							else if(Show_edge[id] && failed_jump[id] && jump_type[id]!=Type_ladder && jumpblock[id]<user_block[id][0] && jumpblock[id]>user_block[id][1] && edgedist[id]<100.0 && edgedist[id]!=0.0)
							{
								strLen =strLen+format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tBlock -- %d^n^tJumpoff -- %f",jumpblock[id],edgedist[id]);
							}
							else if(Show_edge_Fail[id] && failed_jump[id] && jump_type[id]!=Type_ladder && edgedist[id]<100.0 && edgedist[id]!=0.0)
							{
								strLen =strLen+format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tJumpoff -- %f",edgedist[id]);	
							}
							if(jump_type[id]==Type_Up_Bhop || jump_type[id]==Type_Up_Stand_Bhop || jump_type[id]==Type_Up_Bhop_In_Duck)
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tUp Height: %0.3f",upheight[id]);
							}
							if(fps_hight[id] && jump_type[id]!=Type_ladder)
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tYour Fps more 110 or Lags");
							}
							if(ladderbug[id])
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tProbably Ladder bug");
								failed_jump[id]=true;
							}
							if(find_ladder[id] && jump_type[id]==Type_DuckBhop)
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tDuckBhop doesn't work near Ladder");
								failed_jump[id]=true;
							}
							if(touch_somthing[id])
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tProbably Touched something");
							}
							if(angles_arry[id]>60 && uq_script_detection && distance[id]>holy_dist)
							{
								strLen += format(strMess[strLen],(40*NSTRAFES)-strLen-1, "^n^n^tProbably you use Script");
								failed_jump[id]=true;
								
								//if(jump_type[id]!=Type_None)
									//Log_script(id,distance[id],maxspeed[id],strafe_num[id],goodSyncTemp*100/(goodSyncTemp+badSyncTemp),Jtype[id],weapon_name);
							}
						}
					}
					//client_print(id,print_chat,"%d",angles_arry[id]);	
					
					//Sync
					if( goodSyncTemp > 0 ) sync_[id]= (goodSyncTemp*100/(goodSyncTemp+badSyncTemp));
					else sync_[id] = 0;
					
					switch( jump_type[id] )
					{
						case 0: add( type, 32, "LJ", 25 ); //Lj
						case 1: add( type, 32, "HJ", 25 ); //hj
						case 2: 
						{
							if(CjafterJump[id]==1)
							{
								add( type, 32, "CJ After Jump", 25 );
							}
							else add( type, 32, "CJ", 25 ); //cj
						}
						case 3: add( type, 32, "BJ", 25 );//bj
						case 4: add( type, 32, "Slide", 25 );//??
						case 5: add( type, 32, "SBJ", 25 );//sbj
						case 6: 
						{
							if(ddbeforwj[id]==false)
							{
								add( type, 32, "WJ", 25 ); //wj
							}
							else
							{
								add( type, 32, "DD+WJ", 25 );
							}
						}
						case 7: add( type, 32, "Drop BJ", 25 );
						case 9:
						{
							if(CjafterJump[id]==2)
							{
								add( type, 32, "DCJ After Jump", 25 );
							}
							else add( type, 32, "DCJ", 25 ); //dcj
						}
						case 11: 
						{
							if(CjafterJump[id]==3)
							{
								add( type, 32, "MCJ After Jump", 25 );
							}
							else add( type, 32, "Multi CJ", 25 );//mcj
						}
						case 12: add( type, 32, "Duck Bhop", 25 );//nothing
						case 13: add( type, 32, "Ladder", 25 );//ld
						case 15: add( type, 32, "Ladder Bhop", 25 );
						case 16: add( type, 32, "Drop SBJ", 25 );
						case 17: add( type, 32, "Real Ladder Bhop", 25 );
						case 18:
						{	
							if(multidropcj[id]==0)
							{
								add( type, 32, "Drop CJ", 25 );
							}
							else if(multidropcj[id]==1)
							{
								add( type, 32, "Double Drop CJ", 25 );
								formatex(Jtype[id],32,"Double Drop CJ");
							}
							else if(multidropcj[id]==2)
							{
								add( type, 32, "Multi Drop CJ", 25 );
								formatex(Jtype[id],32,"Multi Drop CJ");
							}
						}
						case 19:
						{	if(dropaem[id])
							{
								if(multiscj[id]==0)
								{
									add( type, 32, "Drop SCJ", 25 );
									formatex(Jtype[id],32,"Drop StandUp CountJump");
									formatex(Jtype1[id],32,"dropscj");
								}
								else if(multiscj[id]==1)
								{
									add( type, 32, "Drop Double SCJ", 25 );
									formatex(Jtype[id],32,"Drop Double StandUp CountJump");
									formatex(Jtype1[id],32,"dropdscj");
								}
								else if(multiscj[id]==2)
								{
									add( type, 32, "Drop Multi SCJ", 25 );
									formatex(Jtype[id],32,"Drop Multi StandUp CountJump");
									formatex(Jtype1[id],32,"dropmscj");
									
								}
							}
							else if(ddafterJump[id])
							{
								if(multiscj[id]==0)
								{
									add( type, 32, "SCJ After Jump", 25 );
									formatex(Jtype[id],32,"StandUp CountJump After Jump");
									formatex(Jtype1[id],32,"scjaj");
								}
								else if(multiscj[id]==1)
								{
									add( type, 32, "Double SCJ After Jump", 25 );
									formatex(Jtype[id],32,"Double StandUp CountJump After Jump");
									formatex(Jtype1[id],32,"dscjaj");
								}
								else if(multiscj[id]==2)
								{
									add( type, 32, "Multi SCJ After Jump", 25 );
									formatex(Jtype[id],32,"Multi StandUp CountJump After Jump");
									formatex(Jtype1[id],32,"mscjaj");
								}
							}
							else
							{
								if(multiscj[id]==0)
								{
									add( type, 32, "SCJ", 25 );
								}
								else if(multiscj[id]==1)
								{
									add( type, 32, "Double SCJ", 25 );
									formatex(Jtype[id],32,"Double StandUp CountJump");
									formatex(Jtype1[id],32,"dscj");
								}
								else if(multiscj[id]==2)
								{
									add( type, 32, "Multi SCJ", 25 );
									formatex(Jtype[id],32,"Multi StandUp CountJump");
									formatex(Jtype1[id],32,"mscj");
								}
							}
						}
						case 20:add( type, 32, "Multi Bhop", 25 );
						case 21:add( type, 32, "Up Bhop", 25 );
						case 22:add( type, 32, "Up StandUp Bhop", 25 );
						case 23:add( type, 32, "Up Bhop In Duck", 25);
						case 24:add( type, 32, "Bhop In Duck", 25);
					}
					//gain
					
					
					
					new Float:gain[33];
					gain[id] = floatsub( maxspeed[id], prestrafe[id] );
			
					if(jump_type[id]==Type_StandUp_CountJump && dropaem[id]==false && multiscj[id]==0 && uq_drsbj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id]==false && multiscj[id]==1 && uq_dscj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id]==false && multiscj[id]==2 && uq_mscj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id] && multiscj[id]==0 && uq_dropscj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id] && multiscj[id]==1 && uq_dropdscj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id] && multiscj[id]==2 && uq_dropmscj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Double_CountJump&& uq_dcj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Multi_CountJump && uq_mcj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_CountJump && uq_cj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if((jump_type[id]==Type_LongJump || jump_type[id]==Type_HighJump) && uq_lj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_ladder && uq_ladder==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Bhop_In_Duck && (uq_bhopinduck==0 )) 
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_DuckBhop && (uq_duckbhop==0 )) 
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Up_Bhop && (uq_upbj==0) ) 
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Up_Bhop_In_Duck && (uq_upbhopinduck==0 )) 
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_BhopLongJump && uq_bj==0) 
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_ladderBhop && uq_ldbj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Real_ladder_Bhop && uq_realldbhop==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_WeirdLongJump && uq_wj==0) 
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Drop_CountJump && multidropcj[id]==0 && uq_drcj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Drop_CountJump && multidropcj[id]==1 && uq_dropdcj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Drop_CountJump && multidropcj[id]==2 && uq_dropmcj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Drop_BhopLongJump && uq_drbj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_StandupBhopLongJump && uq_sbj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Up_Stand_Bhop && uq_upsbj==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					else if(jump_type[id]==Type_Multi_Bhop && uq_multibhop==0)
					{
						JumpReset(id);
						return FMRES_IGNORED;
					}
					
					for(new i=1;i<NSTRAFES;i++)
					{
						if(tmpstatspeed[i]>40 && jump_type[id]!=Type_ladder && jump_type[id]!=Type_Real_ladder_Bhop && jump_type[id]!=Type_Slide)
						{
							JumpReset(id);
							return FMRES_IGNORED;
						}
					}
					
					if(jump_type[id]==Type_Multi_Bhop && multibhoppre[id]==false)
					{
						g_reset[id]=true;
						return FMRES_IGNORED;
					}
					if(!failed_jump[id])
					{
						new tmp_type_num;
												
						if(jump_type[id]==Type_Double_CountJump  && uq_dcj==1) 
						{
							formatex(sql_JumpType[id],25,"doublecj_top");
							tmp_type_num=10;
						}
						else if(jump_type[id]==Type_Multi_CountJump  && uq_mcj==1) 
						{
								formatex(sql_JumpType[id],25,"multicj_top");
								tmp_type_num=21;
						}
						else if(jump_type[id]==Type_CountJump  && uq_cj==1) 
						{
								formatex(sql_JumpType[id],25,"cj_top");
								tmp_type_num=2;
						}
						else if((jump_type[id]==Type_LongJump || jump_type[id]==Type_HighJump)  && uq_lj==1) 
						{
							formatex(sql_JumpType[id],25,"lj_top");
							tmp_type_num=0;
						}
						else if(jump_type[id]==Type_ladder  && uq_ladder==1) 
						{
							formatex(sql_JumpType[id],25,"ladder_top");
							tmp_type_num=6;
						}
						else if(jump_type[id]==Type_BhopLongJump  && uq_bj==1) 
						{
							formatex(sql_JumpType[id],25,"bj_top");
							tmp_type_num=4;
						}
						else if(jump_type[id]==Type_ladderBhop  && uq_ldbj==1) 
						{
							formatex(sql_JumpType[id],25,"ladderbhop_top");
							tmp_type_num=7;
						}
						else if(jump_type[id]==Type_WeirdLongJump  && uq_wj==1) 
						{
							formatex(sql_JumpType[id],25,"wj_top");
							tmp_type_num=3;
						}
						else if(jump_type[id]==Type_Drop_BhopLongJump  && uq_drbj==1) 
						{
							formatex(sql_JumpType[id],25,"dropbj_top");
							tmp_type_num=9;
						}
						else if(jump_type[id]==Type_StandupBhopLongJump  && uq_sbj==1) 
						{
							formatex(sql_JumpType[id],25,"sbj_top");
							tmp_type_num=5;
						}
						else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id]==false && multiscj[id]==0  && uq_drsbj==1)
						{
							formatex(sql_JumpType[id],25,"scj_top");
							tmp_type_num=1;
						}
						else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id]==false && multiscj[id]==1   && uq_dscj==1) 
						{
							formatex(sql_JumpType[id],25,"doublescj_top");
							tmp_type_num=11;
						}
						else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id]==false && multiscj[id]==2   && uq_mscj==1) 
						{
							formatex(sql_JumpType[id],25,"multiscj_top");
							tmp_type_num=22;
						}
						else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id] && multiscj[id]==0   && uq_dropscj==1) 
						{
							formatex(sql_JumpType[id],25,"dropscj_top");
							tmp_type_num=12;
						}
						else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id] && multiscj[id]==1   && uq_dropdscj==1) 
						{
							formatex(sql_JumpType[id],25,"dropdoublescj_top");
							tmp_type_num=13;
						}
						else if(jump_type[id]==Type_StandUp_CountJump && dropaem[id] && multiscj[id]==2   && uq_dropmscj==1) 
						{
							formatex(sql_JumpType[id],25,"dropmultiscj_top");
							tmp_type_num=23;
						}
						else if(jump_type[id]==Type_DuckBhop   && uq_duckbhop==1) 
						{
							formatex(sql_JumpType[id],25,"duckbhop_top");
							tmp_type_num=14;
						}
						else if(jump_type[id]==Type_Bhop_In_Duck   && uq_bhopinduck==1) 
						{
							formatex(sql_JumpType[id],25,"bhopinduck_top");
							tmp_type_num=15;
						}
						else if(jump_type[id]==Type_Real_ladder_Bhop   && uq_realldbhop==1) 
						{
							formatex(sql_JumpType[id],25,"realladderbhop_top");
							tmp_type_num=16;
						}
						else if(jump_type[id]==Type_Up_Bhop   && uq_upbj==1) 
						{
							formatex(sql_JumpType[id],25,"upbj_top");
							tmp_type_num=17;
						}
						else if(jump_type[id]==Type_Up_Bhop_In_Duck   && uq_upbhopinduck==1) 
						{
							formatex(sql_JumpType[id],25,"upbhopinduck_top");
							tmp_type_num=19;
						}
						else if(jump_type[id]==Type_Up_Stand_Bhop   && uq_upsbj==1) 
						{
							formatex(sql_JumpType[id],25,"upsbj_top");
							tmp_type_num=18;
						}
						else if(jump_type[id]==Type_Multi_Bhop   && uq_multibhop==1) 
						{
							formatex(sql_JumpType[id],25,"multibhop_top");
							tmp_type_num=24;
						}
						else if(jump_type[id]==Type_Drop_CountJump && multidropcj[id]==2   && uq_dropmcj==1) 
						{
							formatex(sql_JumpType[id],25,"multidropcj_top");
							tmp_type_num=25;
						}
						else if(jump_type[id]==Type_Drop_CountJump && multidropcj[id]==1   && uq_dropdcj==1) 
						{
							formatex(sql_JumpType[id],25,"doubledropcj_top");
							tmp_type_num=20;
						}
						else if(jump_type[id]==Type_Drop_CountJump && multidropcj[id]==0  && uq_drcj==1) 
						{
							formatex(sql_JumpType[id],25,"dropcj_top");
							tmp_type_num=8;
						}
						
					
						if(jump_type[id]!=Type_None && jump_type[id]!=Type_Null && jump_type[id]!=Type_Nothing && jump_type[id]!=Type_Nothing2) 
						{
							if(jumpblock[id]>100 && edgedist[id]!=0.0 && (jumpblock[id]+edgedist[id])<distance[id])
							{
								new cData[6];
								
								cData[0] = floatround(distance[id]*1000000);
								cData[1] = floatround(edgedist[id]*1000000);
								cData[2] = jumpblock[id];
								
								if(jump_type[id]==Type_HighJump)
								{
									cData[3]=6;
								}
								else cData[3] = tmp_type_num;
								
								cData[4] = Pmaxspeed;
								cData[5] = wpn;
							// Добавляются только lj за 240
								if (distance[id] >=good_dist)
									PlayerSaveData_to_SQL_block(id, cData);
							}
							
							new cData[9];
							cData[0] = floatround(distance[id]*1000000);
							cData[1] = floatround(maxspeed[id]*1000000);
							cData[2] = floatround(prestrafe[id]*1000000);
							cData[3] = strafe_num[id];
							cData[4] = sync_[id];
							
							
							if(jump_type[id]==Type_Multi_Bhop)
							{
								cData[5]=bhop_num[id];
							}
							else cData[5] = ducks[id];
							
							cData[6] = tmp_type_num;
							cData[7] = Pmaxspeed;
							cData[8] = wpn;
							// Добавляются только lj за 240
							if (distance[id] >=good_dist)
								PlayerSaveData_to_SQL(id, cData);
						}
					}
					
			
					if(kz_stats_pre[id]==true)//ducks stat for mcj
					{
						strM[0] = '^0'; 
						strMBuf[0] = '^0'; 
						strL = 0;
						for(jj = 2;jj <= ducks[id]; jj++)
						{
							strL += format(strM[strL],(40*NSTRAFES)-strL-1, "^t%2d^tduck: (%0.3f)^n", jj-1,statsduckspeed[id][jj]);
						}
						copy(strMBuf,strL,strM);//dlya stat ducks
					}
					if(uq_istrafe)
					{
						new st1[NSTRAFES],st2[NSTRAFES];
						for(new i = 1;i <= strafe_num[id]; i++)
						{
							st1[i]=strafe_stat_sync[id][i][0];
							st2[i]=strafe_stat_sync[id][i][1];
						}
						
						for( new i = 1; i < max_players; i++ )
						{
							if( (i == id || is_spec_user[i]))
							{
								if(ingame_strafe[i])
								{
									new Float:or[3];
									pev(id,pev_origin,or);
									
									remove_beam_ent(i);
									
									epta(i,or,direct_for_strafe[id],line_lost[id],FullJumpFrames[id],is_user_ducking(id),strafe_num[id],st1,st2,strafe_lost_frame[id]);
								}
							}
						}
					}
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]) && g_lj_stats[i]==true)
						{	
							copy(strMessBuf,strLen,strMess);
							//stats
							if(jump_type[id]==Type_Multi_Bhop &&!failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats  );	
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: %f^nStrafes: %d^nSync: %d%%^nBhop Jump's: %d", type, distance[id], maxspeed[id], gain[id], prestrafe[id],strafe_num[id], sync_[id],bhop_num[id]);
							}
							else if((jump_type[id]==Type_Double_CountJump || (multiscj[id]==1 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==1 && jump_type[id] == Type_Drop_CountJump)) &&!failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );	
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: (%.01f) (%.01f) %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prest1[id],prest[id], prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_ladderBhop || jump_type[id]==Type_ladder || jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_WeirdLongJump || jump_type[id]==Type_LongJump || jump_type[id]==Type_HighJump) &&!failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats  );	
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_CountJump || (multiscj[id]==0 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==0 && jump_type[id] == Type_Drop_CountJump)) && !failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats);
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: (%.03f) %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prest1[id],prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_Bhop_In_Duck || jump_type[id]==Type_Up_Bhop_In_Duck || jump_type[id]==Type_Up_Stand_Bhop || jump_type[id]==Type_Up_Bhop || jump_type[id]==Type_Real_ladder_Bhop || jump_type[id]==Type_DuckBhop || jump_type[id] == Type_BhopLongJump || jump_type[id] == Type_StandupBhopLongJump ) && !failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats);
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id],prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id] == Type_Drop_CountJump)) && !failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: (%.03f) %f^nDucks: %d%^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prest1[id],prestrafe[id],ducks[id], strafe_num[id], sync_[id]);
							}
							
							if(jump_type[id] != Type_Slide && streifstat[id]==true && jump_type[id]!=Type_None && !failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, strafe_x, strafe_y, 0, 6.0, 2.5, 0.1, 0.3, h_streif);
								show_hudmessage(i,"%s",strMessBuf); //stata streifof
							}
							
							if(kz_stats_pre[id]==true && (jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id] == Type_Drop_CountJump)) && !failed_jump[id])
							{
								set_hudmessage(stats_r, stats_g, stats_b, duck_x,duck_y, 0, 6.0, 2.5, 0.1, 0.3, h_duck);	
								show_hudmessage(i, "%s",strMBuf);//stata duckov
							}
							
							//failstats
							if(jump_type[id]==Type_Multi_Bhop  && (failed_jump[id]))
							{
								set_hudmessage( f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: %f^nStrafes: %d^nSync: %d%%^nBhop Jump's: %d", type, distance[id], maxspeed[id], gain[id], prestrafe[id],strafe_num[id], sync_[id],bhop_num[id]);
							}
							else if((jump_type[id]==Type_ladderBhop || jump_type[id]==Type_ladder || jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_WeirdLongJump || jump_type[id]==Type_LongJump || jump_type[id]==Type_HighJump)  && (failed_jump[id]))
							{
								set_hudmessage( f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_CountJump || (multiscj[id]==0 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==0 && jump_type[id] == Type_Drop_CountJump)) && (failed_jump[id]))
							{
								set_hudmessage(f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: (%.03f) %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prest1[id],prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_Bhop_In_Duck || jump_type[id]==Type_Up_Bhop_In_Duck || jump_type[id]==Type_Up_Stand_Bhop || jump_type[id]==Type_Up_Bhop || jump_type[id]==Type_Real_ladder_Bhop || jump_type[id]==Type_DuckBhop || jump_type[id] == Type_BhopLongJump || jump_type[id] == Type_StandupBhopLongJump ) && (failed_jump[id]))
							{
								set_hudmessage(f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: %f^nStrafes: %d^nSynca: %d%%^n", type, distance[id], maxspeed[id], gain[id], prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_Double_CountJump || (multiscj[id]==1 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==1 && jump_type[id] == Type_Drop_CountJump)) && (failed_jump[id]))
							{
								set_hudmessage( f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: (%.01f) (%.01f) %f^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prest1[id],prest[id], prestrafe[id],strafe_num[id], sync_[id]);
							}
							else if((jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id] == Type_Drop_CountJump)) && (failed_jump[id]))
							{
								set_hudmessage(f_stats_r, f_stats_g, f_stats_b, stats_x, stats_y, 0, 6.0, 2.5, 0.1, 0.3, h_stats );
								show_hudmessage( i, "%s Distance: %f^nMaxspeed: %f (%.03f)^nPrestrafe: (%.03f) %f^nDucks: %d%^nStrafes: %d^nSync: %d%%^n", type, distance[id], maxspeed[id], gain[id], prest1[id],prestrafe[id],ducks[id],strafe_num[id], sync_[id]);
							}
													
							if(jump_type[id] != Type_Slide && streifstat[id]==true && jump_type[id]!=Type_None && (failed_jump[id]))
							{
								set_hudmessage(f_stats_r, f_stats_g, f_stats_b, strafe_x, strafe_y, 0, 6.0, 2.5, 0.1, 0.3, h_streif );
								show_hudmessage(i,"%s",strMessBuf);  //stata streifof fail
							}
							
							if(kz_stats_pre[id]==true && (jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id] == Type_Drop_CountJump)) && (failed_jump[id]))
							{
								set_hudmessage(f_stats_r, f_stats_g, f_stats_b, duck_x,duck_y, 0, 6.0, 2.5, 0.1, 0.3, h_duck);	
								show_hudmessage(i, "%s",strMBuf); //stata duckov fail
							}					
						}
					}
					
					//console prints
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]) && g_lj_stats[i]==true)
						{
							copy(strMessBuf,strLen,strMess);
							if((jump_type[id]==Type_ladderBhop || jump_type[id]==Type_ladder || jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_WeirdLongJump || jump_type[id]==Type_LongJump || jump_type[id]==Type_HighJump) )
							{
								client_print( i, print_console, " ");
								client_print( i, print_console, "%s Distance: %f Maxspeed: %f (%.03f) Prestrafe: %f Strafes: %d Sync: %d%%", type, distance[id], maxspeed[id], gain[id], prestrafe[id], strafe_num[id],sync_[id] );
							}
							else if(jump_type[id]==Type_Multi_Bhop )
							{
								client_print( i, print_console, " ");
								client_print( i, print_console, "%s Distance: %f Maxspeed: %f (%.03f) Prestrafe: %f Strafes: %d Sync: %d Bhop Jump's: %d", type, distance[id], maxspeed[id], gain[id], prestrafe[id], strafe_num[id],sync_[id] ,bhop_num[id]);
							
							}
							else if(jump_type[id]==Type_CountJump || (multiscj[id]==0 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==0 && jump_type[id] == Type_Drop_CountJump))
							{
								client_print( i, print_console, " ");
								client_print( i, print_console, "%s Distance: %f Maxspeed: %f (%.03f) Prestrafe: (%.03f) %f Strafes: %d Sync: %d%%", type, distance[id], maxspeed[id], gain[id], prest1[id], prestrafe[id], strafe_num[id],sync_[id] );
							}
							else if(jump_type[id]==Type_Bhop_In_Duck || jump_type[id]==Type_Up_Bhop_In_Duck || jump_type[id]==Type_Up_Stand_Bhop || jump_type[id]==Type_Up_Bhop || jump_type[id]==Type_Real_ladder_Bhop || jump_type[id]==Type_DuckBhop || jump_type[id] == Type_BhopLongJump || jump_type[id] == Type_StandupBhopLongJump)
							{
								client_print( i, print_console, " ");
								client_print( i, print_console, "%s Distance: %f Maxspeed: %f (%.03f) Prestrafe: %f Strafes: %d Sync: %d%%", type, distance[id], maxspeed[id], gain[id], prestrafe[id], strafe_num[id],sync_[id] );
							}
							else if(jump_type[id]==Type_Double_CountJump || (multiscj[id]==1 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==1 && jump_type[id] == Type_Drop_CountJump))
							{
								client_print( i, print_console, " ");
								client_print( i, print_console, "%s Distance: %f Maxspeed: %f (%.03f) Prestrafe: (%.01f) (%.01f) %f Strafes: %d Sync: %d%%", type, distance[id], maxspeed[id], gain[id], prest1[id],prest[id], prestrafe[id], strafe_num[id],sync_[id] );
							}
							else if(jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id] == Type_Drop_CountJump))
							{
								client_print( i, print_console, " ");
								client_print( i, print_console, "%s Distance: %f Maxspeed: %f (%.03f) Prestrafe: (%.03f) %f Ducks: %d% Strafes: %d Sync: %d%%", type, distance[id], maxspeed[id], gain[id], prest1[id],prestrafe[id],ducks[id],strafe_num[id], sync_[id]);
							}
							
							if(jump_type[id]!=Type_None)
							{
								static strMessHalf[40];
								for(jj=1; (jj <= strafe_num[id]) && (jj < NSTRAFES);jj++)
								{
										strtok(strMessBuf,strMessHalf,40,strMessBuf,40*NSTRAFES,'^n');
										replace(strMessHalf,40,"^n","");
										client_print(i, print_console, "%s", strMessHalf);
								}
							}
							
							if(jump_type[id]==Type_ladder && strafe_stat_speed[id][0][0]!=0)
							{
								client_print(i, print_console, "Turn speed: %.03f", strafe_stat_speed[id][0][0]);
							}
							else if(jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id] == Type_Drop_CountJump))
							{
								client_print( i, print_console, "..................................................");
								client_print( i, print_console, "Prestrafe before ducking: %.03f",prest1[id]);
								for(new ss=2;ss<=ducks[id];ss++)
								client_print( i, print_console, "Prestrafe after #%d duck: %.03f",ss-1,statsduckspeed[id][ss]);
								client_print( i, print_console, "Prestrafe before jumping: %.03f",prestrafe[id]);
								client_print( i, print_console, "..................................................");
							}
							else if(jump_type[id]==Type_Double_CountJump || (multiscj[id]==1 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==1 && jump_type[id] == Type_Drop_CountJump))
							{
								client_print( i, print_console, "..................................................");
								client_print( i, print_console, "Prestrafe before ducking: %.03f",prest1[id]);
								client_print( i, print_console, "Prestrafe after 1st duck: %.03f",prest[id]);
								client_print( i, print_console, "Prestrafe before jumping: %.03f",prestrafe[id]);
								client_print( i, print_console, "..................................................");
							}
							else if(jump_type[id]==Type_Up_Bhop || jump_type[id]==Type_Up_Stand_Bhop || jump_type[id]==Type_Up_Bhop_In_Duck)
							{
								client_print( i, print_console,"Up Height: %0.3f",upheight[id]);
							}
							if(wpn!=29 && wpn!=17 && wpn!=16)
							{
								client_print( i, print_console,"Weapon: %s",weapon_name);
							}
							if(fps_hight[id] && jump_type[id]!=Type_ladder)
							{
								client_print( i, print_console,"Your Fps more 110 or Lags");
								fps_hight[id]=false;
							}
							if(ladderbug[id])
							{
								client_print( i, print_console,"Probably Ladder bug");
								ladderbug[id]=false;
							}
							if(find_ladder[id] && jump_type[id]==Type_DuckBhop)
							{
								client_print( i, print_console,"DuckBhop doesn't work near Ladder");
								find_ladder[id]=false;
							}
							if(touch_somthing[id])
							{
								client_print( i, print_console,"Probably Touched something");
							}
							if(Show_edge[id] && failed_jump[id]==false && jump_type[id]!=Type_ladder && jumpblock[id]<user_block[id][0] && jumpblock[id]>user_block[id][1] && edgedist[id]<100.0 && edgedist[id]!=0.0 && (jumpblock[id]+edgedist[id])<distance[id])
							{
								if((jumpblock[id]+Landing+edgedist[id])>(distance[id]+10.0) || Landing<=0.0)
								{
									client_print( i, print_console,"Block -- %d! Jumpoff -- %f!",jumpblock[id],edgedist[id]);
								}
								else if(land_bug )
								{
									client_print( i, print_console,"Block -- %d! Jumpoff -- %f! Landing -- %f(bg)!",jumpblock[id],edgedist[id],Landing);
								}
								else client_print( i, print_console,"Block -- %d! Jumpoff -- %f! Landing -- %f!",jumpblock[id],edgedist[id],Landing);
							}
							else if(Show_edge[id] && failed_jump[id] && jump_type[id]!=Type_ladder && jumpblock[id]<user_block[id][0] && jumpblock[id]>user_block[id][1] && edgedist[id]<100.0 && edgedist[id]!=0.0 && (jumpblock[id]+edgedist[id])<distance[id])
							{
								client_print( i, print_console,"Block -- %d! Jumpoff -- %f!",jumpblock[id],edgedist[id]);
							}
							else if(Show_edge_Fail[id] && failed_jump[id] && jump_type[id]!=Type_ladder && edgedist[id]<100.0 && edgedist[id]!=0.0)
							{
								client_print( i, print_console,"Jumpoff -- %f!",edgedist[id]);	
							}
							if(angles_arry[id]>60 && uq_script_detection && distance[id]>holy_dist)
							{
								client_print( i, print_console,"Probably you use Script");
								
							}
						}
					}
					
					if(wpn==29 || wpn==17 || wpn==16 || wpn==4 || wpn==9 || wpn==25)
					{
						formatex(weapon_name,20,"");
					}
					else
					{
						new tmp_str[21];
						
						formatex(tmp_str,20,"[");
						add(weapon_name, 20, "]");
						add(tmp_str, 20, weapon_name);
						formatex(weapon_name,20,tmp_str);
					}
					
					new block_colorchat_dist=god_dist;
						new uq_block_chat_min = 1;
						switch(uq_block_chat_min)
						{
							case 0:
								block_colorchat_dist=good_dist;
							case 1:
								block_colorchat_dist=pro_dist;
							case 2:
								block_colorchat_dist=holy_dist;
							case 3:
								block_colorchat_dist=leet_dist;
							case 4:
								block_colorchat_dist=god_dist;
							case 5:
								block_colorchat_dist=dom_dist;
						}
					
					
					new block_str[20];
					
					if(jumpblock[id]>=block_colorchat_dist && jumpblock[id]<user_block[id][0] && jumpblock[id]>user_block[id][1] && edgedist[id]<100.0 && edgedist[id]!=0.0 && (jumpblock[id]+edgedist[id])<distance[id])
					{
						formatex(block_str,19,"[%d block]",jumpblock[id]);
					}
					else
					{
						formatex(block_str,19,"");
					}

					new iPlayers[32],iNum; 
					get_players( iPlayers, iNum,"ch") ;
					
					
					for(new i=0;i<iNum;i++) 
					{ 
						new ids=iPlayers[i]; 
						if(gHasColorChat[ids] ==true || ids==id)
						{	
							if( !failed_jump[id] )
							{
								if((jump_type[id]==Type_Bhop_In_Duck || jump_type[id]==Type_Up_Bhop_In_Duck || jump_type[id]==Type_Up_Stand_Bhop || jump_type[id]==Type_Up_Bhop || jump_type[id]==Type_DuckBhop || jump_type[id]==Type_Real_ladder_Bhop || jump_type[id]==Type_Double_CountJump
										     || (multiscj[id]!=2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]!=2 && jump_type[id]==Type_Drop_CountJump) || jump_type[id]==Type_CountJump
										     || jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_BhopLongJump || jump_type[id]==Type_StandupBhopLongJump || jump_type[id]==Type_WeirdLongJump
										     || jump_type[id]==Type_ladderBhop || jump_type[id]==Type_ladder || jump_type[id]==Type_LongJump || jump_type[id]==Type_HighJump))
								{
									if ( distance[id] >= dom_dist ) {
										if( uq_sounds && enable_sound[ids]==true )
										{
											client_cmd(ids, "speak misc/dominatingkz");
										}
										ColorChat(ids, RED, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%% ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],weapon_name, block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= god_dist ) {
										if( uq_sounds && enable_sound[ids]==true )
										{
											client_cmd(ids, "speak misc/mod_godlike");
										}
										ColorChat(ids, RED, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%% ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],weapon_name, block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= leet_dist  ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/mod_wickedsick");
									
										ColorChat(ids, RED, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%% ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],weapon_name, block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= holy_dist ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/holyshit");
									
										ColorChat(ids, BLUE, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%% ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],weapon_name, block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= pro_dist ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/perfect");
									
										ColorChat(ids, GREEN, "%s ^x01%s  ^x04%s ^x01= ^x01 Distance: ^x04%.3f ^x01Prestrafe: ^x04%.01f ^x01Strafes: ^x04%d ^x01Sync: ^x04%d%% ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],weapon_name, block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >=good_dist ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/impressive");
									
										ColorChat(ids, GREY, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%% ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],weapon_name, block_str,pre_type[id],airacel[id]);
									}
								}
								else if(jump_type[id]==Type_Multi_CountJump || (multiscj[id]==2 && jump_type[id]==Type_StandUp_CountJump) || (multidropcj[id]==2 && jump_type[id]==Type_Drop_CountJump))
								{
									if ( distance[id] >= dom_dist ) {
										if( uq_sounds && enable_sound[ids]==true )
										{
											client_cmd(ids, "speak misc/dominatingkz");
										}
										ColorChat(ids, RED, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%%^x01 Ducks: ^x03%d ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],ducks[id],weapon_name,block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= god_dist ) {
										if( uq_sounds && enable_sound[ids]==true )
										{
											client_cmd(ids, "speak misc/mod_godlike");
										}
										ColorChat(ids, RED, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%%^x01 Ducks: ^x03%d ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],ducks[id],weapon_name,block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= leet_dist  ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/mod_wickedsick");
									
										ColorChat(ids, RED, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%%^x01 Ducks: ^x03%d ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],ducks[id],weapon_name,block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= holy_dist ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/holyshit");
									
										ColorChat(ids, BLUE, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%%^x01 Ducks: ^x03%d ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],ducks[id],weapon_name,block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >= pro_dist ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/perfect");
									
										ColorChat(ids, GREEN, "%s ^x01%s  ^x04%s ^x01= ^x01 Distance: ^x04%.3f ^x01Prestrafe: ^x04%.01f ^x01Strafes: ^x04%d ^x01Sync: ^x04%d%%^x01 Ducks: ^x04%d ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],ducks[id],weapon_name,block_str,pre_type[id],airacel[id]);
									}
									else if ( distance[id] >=good_dist ) {
										if( uq_sounds && enable_sound[id]==true ) client_cmd(id, "speak misc/impressive");
									
										ColorChat(ids, GREY, "%s ^x01%s  ^x03%s ^x01= ^x01 Distance: ^x03%.3f ^x01Prestrafe: ^x03%.01f ^x01Strafes: ^x03%d ^x01Sync: ^x03%d%%^x01 Ducks: ^x03%d ^x01%s ^x01%s ^x03%s",prefix, g_playername[id],Jtype[id],distance[id],prestrafe[id],strafe_num[id],sync_[id],ducks[id],weapon_name,block_str,pre_type[id],airacel[id]);
									}
								}
							}	
						}
					}
					
					// UberBeam start
					if( kz_beam[id]==true)
						{
						for( new i = 0; i < 100; i++ ) {
							if( gBeam_points[id][i][0] == 0.0
							&& gBeam_points[id][i][1] == 0.0
							&& gBeam_points[id][i][2] == 0.0 ) {
								continue;
							}
						
							message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0, 0, 0}, id);
							write_byte ( TE_BEAMPOINTS );
							if( i == 100 ) {
								write_coord(floatround(gBeam_points[id][i][0]));
								write_coord(floatround(gBeam_points[id][i][1]));
								write_coord(floatround(jumpoff_origin[id][2]-34.0));
								write_coord(floatround(land_origin[0]));
								write_coord(floatround(land_origin[1]));
								write_coord(floatround(jumpoff_origin[id][2]-34.0));
							} else {
								if ( i > 2 ) {
									write_coord(floatround(gBeam_points[id][i-1][0]));
									write_coord(floatround(gBeam_points[id][i-1][1]));
									write_coord(floatround(jumpoff_origin[id][2]-34.0));
								} else {
									write_coord(floatround(jumpoff_origin[id][0]));
									write_coord(floatround(jumpoff_origin[id][1]));
									write_coord(floatround(jumpoff_origin[id][2]-34.0));
								}
								write_coord(floatround(gBeam_points[id][i][0]));
								write_coord(floatround(gBeam_points[id][i][1]));
								write_coord(floatround(jumpoff_origin[id][2]-34.0));
							}
							write_short(gBeam);
							write_byte(1);
							write_byte(5);
							write_byte(30);
							write_byte(20);
							write_byte(0);
							if(gBeam_duck[id][i])
							{
								
								write_byte(255);
								write_byte(0);
								write_byte(0);
							}
							else if(beam_type[id]==2 && gBeam_button[id][i])
							{
								if(gBeam_button_what[id][i]==1)
								{
									write_byte(0);
									write_byte(255);
									write_byte(0);
								}
								else if(gBeam_button_what[id][i]==2)
								{
									write_byte(0);
									write_byte(0);
									write_byte(255);
								}
							}
							else 
							{
								write_byte(255);
								write_byte(255);
								write_byte(0);
							}
							write_byte(200);
							write_byte(200);
							message_end();
							
						}
					}
					
					JumpReset(id);
			
				}
				new bool:posible_dropcj;
				if(button & IN_DUCK && !(oldbuttons &IN_DUCK) && (jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_WeirdLongJump))
				{
					new Float:tmpdropcj_start[3],Float:tmpdropcj_end[3],Float:tmpdropcj_frame[3];
					pev(id, pev_origin, origin);
					
					tmpdropcj_start=origin;
					tmpdropcj_start[2]=tmpdropcj_start[2]-36.0;
					
					tmpdropcj_end=tmpdropcj_start;
					tmpdropcj_end[2]=tmpdropcj_end[2]-20;
					
					engfunc(EngFunc_TraceLine,origin,tmpdropcj_end, IGNORE_GLASS, id, 0); 
					get_tr2( 0, TR_vecEndPos, tmpdropcj_frame);
					
					if(tmpdropcj_start[2]-tmpdropcj_frame[2]<=18.0)
					{
						posible_dropcj=true;
						in_duck[id]=false;
					}
					else posible_dropcj=false;
					
				}
				
				if(!in_air[id] && button & IN_DUCK && !(oldbuttons &IN_DUCK) && (flags & FL_ONGROUND || posible_dropcj) && !in_duck[id] && UpcjFail[id]==false)
				{	
					if( get_gametime( ) - duckoff_time[id] < 0.3 )
					{
						started_multicj_pre[id] = true;
						prest[id]= speed; 
						ducks[id]++;
						statsduckspeed[id][ducks[id]]=speed;
						new Float:tmporg_z;
						if(is_user_ducking(id))
						{
							tmporg_z=origin[2]+18.0;
						}
						else tmporg_z=origin[2];
						
						if(tmporg_z-first_duck_z[id]>4.0)
						{
							JumpReset(id);
							if(dropbhop[id])
								dropbhop[id]=false;
							if(in_ladder[id])
								in_ladder[id]=false;
								
							dropupcj[id]=true;
							
							return FMRES_IGNORED;
						}
						
						for( new i = 1; i < max_players; i++ )
						{
							if( (i == id || is_spec_user[i]))
							{
								if(showpre[id]==true && showduck[id]==true)
								{
									set_hudmessage(prest_r,prest_g, prest_b, prest_x, prest_y, 0, 0.0, 0.7, 0.1, 0.1, h_prest);
									show_hudmessage(i, "Duck Pre: %.03f",speed);
								}
							}
						}
					}
					else
					{
						pev(id, pev_origin, origin);
						
						ducks[id]=0;
						prest1[id]= speed; //ground pre
						ducks[id]++;//schetchik duckov
						duckstartz[id]=origin[2];
						statsduckspeed[id][ducks[id]]=speed;//dlya vivoda stati po ducka
						
						started_cj_pre[id] = true;
						nextbhop[id]=false;
						bhopaem[id]=false;
						
						if(first_duck_z[id] && (origin[2]-first_duck_z[id])>4)
						{
							dropupcj[id]=true;
							
							JumpReset(id);
							if(dropbhop[id])
								dropbhop[id]=false;
							if(in_ladder[id])
								in_ladder[id]=false;
								
							return FMRES_IGNORED;
						}
						if(ducks[id]==1) 
						{
							if(is_user_ducking(id))
							{
								first_duck_z[id]=origin[2]+18.0;
							}
							else first_duck_z[id]=origin[2];
						}
						if(dropupcj[id]==false && get_gametime()-FallTime[id]<0.3 && (in_ladder[id] || jump_type[id]==Type_ladderBhop || jump_type[id]==Type_Drop_BhopLongJump || jump_type[id]==Type_WeirdLongJump || dropbhop[id]))
						{
							in_ladder[id]=false;
							jump_type[id] = Type_Drop_CountJump;
							formatex(Jtype[id],32,"Drop CJ");
							formatex(Jtype1[id],32,"drcj");
							multidropcj[id]=0;
							dropaem[id]=true;
							
							if(dropbhop[id])
								dropbhop[id]=false;
							if(in_ladder[id])
								in_ladder[id]=false;
						}
					}
					
					in_duck[id] = true;
				}
				else if( !in_air[id] && oldbuttons & IN_DUCK && (flags & FL_ONGROUND || posible_dropcj) && UpcjFail[id]==false)
				{
					if( !is_user_ducking( id ) )
					{	
						in_duck[id] = false;
						if( started_cj_pre[id] )
						{
							started_cj_pre[id] = false;
							
							duckoff_time[id] = get_gametime( );
							duckoff_origin[id] = origin;
							FallTime1[id]=get_gametime();
						
							strafe_num[id] = 0;
							TempSpeed[id] = 0.0;
							
							if(jump_type[id] != Type_Drop_CountJump)
							{
								jump_type[id] = Type_CountJump;
								jump_typeOld[id]=1;			
								if(nextbhop[id] || bhopaem[id])
								{
									formatex(Jtype[id],32,"CountJump After Jump");
									formatex(Jtype1[id],32,"cjaj");
									
									CjafterJump[id]=1;
			
									ddafterJump[id]=true;
								}
								else
								{
									formatex(Jtype[id],32,"CountJump");
									formatex(Jtype1[id],32,"cj");
									
									CjafterJump[id]=0;
									ddafterJump[id]=false;
								}
								
							}
							else 
							{
								FallTime[id]=get_gametime();
								multidropcj[id]=0;
								jump_typeOld[id]=1;
							}
						}
						else if( started_multicj_pre[id] )
						{
							started_multicj_pre[id] = false;
							
							duckoff_time[id] = get_gametime( );
							duckoff_origin[id] = origin;
							FallTime1[id]=get_gametime();
							
							strafe_num[id] = 0;
							TempSpeed[id] = 0.0;
							
							if(jump_type[id] != Type_Drop_CountJump)
							{
								jump_type[id] = Type_Double_CountJump;
								jump_typeOld[id]=2;
								if(nextbhop[id] || bhopaem[id])
								{
									formatex(Jtype[id],32,"Double CountJump After Jump");
									formatex(Jtype1[id],32,"dcjaj");
									
									CjafterJump[id]=2;
									ddafterJump[id]=true;
								}
								else
								{
									formatex(Jtype[id],32,"Double CountJump");
									formatex(Jtype1[id],32,"dcj");
									
									CjafterJump[id]=0;
									ddafterJump[id]=false;
								}
							}
							else 
							{	
								multidropcj[id]=1;
								FallTime[id]=get_gametime();
								jump_typeOld[id]=2;
							}
						}
						if(ducks[id]>2)
						{	
							if(jump_type[id] != Type_Drop_CountJump)
							{
								jump_type[id] = Type_Multi_CountJump; //detect mcj
								jump_typeOld[id]=3;
								if(nextbhop[id] || bhopaem[id])
								{
									formatex(Jtype[id],32,"Multi CountJump After Jump");
									formatex(Jtype1[id],32,"mcjaj");
									
									CjafterJump[id]=3;
									ddafterJump[id]=true;
								}
								else
								{
									formatex(Jtype[id],32,"Multi CountJump");
									formatex(Jtype1[id],32,"mcj");
									
									CjafterJump[id]=0;
									ddafterJump[id]=false;
								}
							}
							else 
							{	
								multidropcj[id]=2;
								FallTime[id]=get_gametime();
								jump_typeOld[id]=3;
							}	
						}
					}
				}
				
				
				if(flags&FL_ONGROUND && g_Jumped[id]==false && jofon[id] && movetype[id] != MOVETYPE_FLY)
				{
					new Float:new_origin[3],Float:tmpOrigin[3], Float:tmpOrigin2[3];
						
					pev(id,pev_origin,new_origin);
					new_origin[2]=new_origin[2]-36.1;
					
					pev(id, pev_velocity, velocity);
					
					for(new i=0,j=-18;i<3;i++,j=j+18)
					{
						tmpOrigin=new_origin;
						tmpOrigin2=new_origin;
						
						if(velocity[1]>0 && floatabs(velocity[1])>floatabs(velocity[0]))
						{
							tmpOrigin[1]=new_origin[1]+200;
							tmpOrigin2[1]=new_origin[1]-16;
							
							tmpOrigin[0]=tmpOrigin[0]+j;
							tmpOrigin2[0]=tmpOrigin2[0]+j;
							
						}
						else if(velocity[1]<0 && floatabs(velocity[1])>floatabs(velocity[0]))
						{
							tmpOrigin[1]=new_origin[1]-200;
							tmpOrigin2[1]=new_origin[1]+16;
							
							tmpOrigin[0]=tmpOrigin[0]+j;
							tmpOrigin2[0]=tmpOrigin2[0]+j;
						}
						else if(velocity[0]>0 && floatabs(velocity[0])>floatabs(velocity[1]))
						{
							tmpOrigin[0]=new_origin[0]+200;
							tmpOrigin2[0]=new_origin[0]-16;
							
							tmpOrigin[1]=tmpOrigin[1]+j;
							tmpOrigin2[1]=tmpOrigin2[1]+j;
						}
						else if(velocity[0]<0 && floatabs(velocity[0])>floatabs(velocity[1]))
						{
							tmpOrigin[0]=new_origin[0]-200;
							tmpOrigin2[0]=new_origin[0]+16;
							
							tmpOrigin[1]=tmpOrigin[1]+j;
							tmpOrigin2[1]=tmpOrigin2[1]+j;
						}
						
						new Float:tmpEdgeOrigin[3];
						
						engfunc(EngFunc_TraceLine,tmpOrigin,tmpOrigin2, IGNORE_GLASS, id, 0); 
						get_tr2( 0, TR_vecEndPos, tmpEdgeOrigin);
					
						if(get_distance_f(tmpEdgeOrigin,tmpOrigin2)!=0.0)
						{
							jof[id]=get_distance_f(tmpEdgeOrigin,tmpOrigin2)-0.031250;
						}
					}
				}
				else if(!(flags&FL_ONGROUND) && g_Jumped[id] && edgedone[id]==false && movetype[id] != MOVETYPE_FLY)
				{
					new onbhopblock,bhop_block[1];
					
					find_sphere_class(id,"func_door", 48.0, bhop_block, 1, Float:{0.0, 0.0, 0.0} );
					
					if(bhop_block[0])
					{
						onbhopblock=true;
					}
					else
					{
						onbhopblock=false;
					}
					
					
					new Float:tmpblock[3],tmpjblock[3],Float:new_origin[3],Float:tmpOrigin[3], Float:tmpOrigin2[3];
						
					new_origin=jumpoff_origin[id];
					if(onbhopblock)
					{
						new_origin[2]=new_origin[2]-40.0;
					}
					else new_origin[2]=new_origin[2]-36.1;
					
					pev(id, pev_velocity, velocity);
					
					for(new i=0,j=-18;i<3;i++,j=j+18)
					{
						tmpOrigin=new_origin;
						tmpOrigin2=new_origin;
						tmpblock=new_origin;
						if(velocity[1]>0 && floatabs(velocity[1])>floatabs(velocity[0]))
						{
							tmpOrigin[1]=new_origin[1]+100;
							tmpOrigin2[1]=new_origin[1]-16;
							
							tmpOrigin[0]=tmpOrigin[0]+j;
							tmpOrigin2[0]=tmpOrigin2[0]+j;
							
							tmpblock[1]=new_origin[1]+uq_maxedge+1;
							tmpblock[0]=tmpblock[0]+j;
						}
						else if(velocity[1]<0 && floatabs(velocity[1])>floatabs(velocity[0]))
						{
							tmpOrigin[1]=new_origin[1]-100;
							tmpOrigin2[1]=new_origin[1]+16;
							
							tmpOrigin[0]=tmpOrigin[0]+j;
							tmpOrigin2[0]=tmpOrigin2[0]+j;
							
							tmpblock[1]=new_origin[1]-uq_maxedge+1;
							tmpblock[0]=tmpblock[0]+j;
						}
						else if(velocity[0]>0 && floatabs(velocity[0])>floatabs(velocity[1]))
						{
							tmpOrigin[0]=new_origin[0]+100;
							tmpOrigin2[0]=new_origin[0]-16;
							
							tmpOrigin[1]=tmpOrigin[1]+j;
							tmpOrigin2[1]=tmpOrigin2[1]+j;
							
							tmpblock[0]=new_origin[0]+uq_maxedge+1;
							tmpblock[1]=tmpblock[1]+j;
						}
						else if(velocity[0]<0 && floatabs(velocity[0])>floatabs(velocity[1]))
						{
							tmpOrigin[0]=new_origin[0]-100;
							tmpOrigin2[0]=new_origin[0]+16;
							
							tmpOrigin[1]=tmpOrigin[1]+j;
							tmpOrigin2[1]=tmpOrigin2[1]+j;
							
							tmpblock[0]=new_origin[0]-uq_maxedge+1;
							tmpblock[1]=tmpblock[1]+j;
						}
						
						new Float:tmpEdgeOrigin[3];
						
						engfunc(EngFunc_TraceLine,tmpOrigin,tmpOrigin2, IGNORE_GLASS, id, 0); 
						get_tr2( 0, TR_vecEndPos, tmpEdgeOrigin);
								
						if(get_distance_f(tmpEdgeOrigin,tmpOrigin2)!=0.0)
						{
							edgedist[id]=get_distance_f(tmpEdgeOrigin,tmpOrigin2)-0.031250;
						}
						
						new Float:tmpblockOrigin[3];
						
						engfunc(EngFunc_TraceLine,tmpEdgeOrigin,tmpblock, IGNORE_GLASS, id, 0); 
						get_tr2( 0, TR_vecEndPos, tmpblockOrigin);
						
						if(get_distance_f(tmpblockOrigin,tmpEdgeOrigin)!=0.0)
						{
							tmpjblock[i]=floatround(get_distance_f(tmpblockOrigin,tmpEdgeOrigin),floatround_floor)+1;
						}
						
						/*new Float:checkblock1[3],Float:checkblock2[3];
						tmpblockOrigin[2]=tmpblockOrigin[2]-1.0;
												
						if(velocity[1]>0 && floatabs(velocity[1])>floatabs(velocity[0]))
						{
							checkblock1[1]=checkblock1[1]+2.0;
						}
						else if(velocity[1]<0 && floatabs(velocity[1])>floatabs(velocity[0]))
						{
							checkblock1[1]=checkblock1[1]-2.0;
						}
						else if(velocity[0]>0 && floatabs(velocity[0])>floatabs(velocity[1]))
						{
							checkblock1[0]=checkblock1[0]+2.0;
						}
						else if(velocity[0]<0 && floatabs(velocity[0])>floatabs(velocity[1]))
						{
							checkblock1[0]=checkblock1[0]-2.0;
						}
						
						checkblock2=checkblock1;
						checkblock2[2]=checkblock2[2]+18.0;
						
						new Float:tmpcheckblock[3];
						engfunc(EngFunc_TraceLine,checkblock2,checkblock1, IGNORE_GLASS, id, 0); 
						get_tr2( 0, TR_vecEndPos, tmpcheckblock);
						
						if(floatabs(tmpblockOrigin[2]-tmpcheckblock[2])==0.0)
						{
							tmpjblock[i]=0;
						}*/
						
						edgedone[id]=true;
					}
					
					if(tmpjblock[0]!=0 && tmpjblock[0]<=tmpjblock[1] && tmpjblock[0]<=tmpjblock[2])
					{
						jumpblock[id]=tmpjblock[0];
					}
					else if(tmpjblock[1]!=0 && tmpjblock[1]<=tmpjblock[2] && tmpjblock[0]<=tmpjblock[0])
					{
						jumpblock[id]=tmpjblock[1];
					}
					else if(tmpjblock[2]!=0 && tmpjblock[2]<=tmpjblock[1] && tmpjblock[0]<=tmpjblock[0])
					{
						jumpblock[id]=tmpjblock[2];
					}
					else jumpblock[id]=0;
					
					if(equali(mapname,"prochallenge_longjump"))
					{
						jumpblock[id]=jumpblock[id]-1;
					}
					
					new h_jof;
					
					if(jofon[id])
					{
						h_jof=h_speed;
					}
					else h_jof=4;
					
					for( new i = 1; i < max_players; i++ )
					{
						if( (i == id || is_spec_user[i]))
						{	
							if(edgedist[i]!=0.0 && (showjofon[i] || jofon[id])) 
							{
								if(edgedist[i]>5.0)
								{
									set_hudmessage(255, 255, 255, -1.0, 0.6, 0, 0.0, 0.7, 0.0, 0.0, h_jof);
								}
								else
								{
									set_hudmessage(255, 0, 0, -1.0, 0.6, 0, 0.0, 0.7, 0.0, 0.0, h_jof);
								}
								show_hudmessage(i, "JumpOff: %f", edgedist[id]);
							}
						}
					}
				}
				
				new Float:checkfall;
				if(jump_type[id]==Type_Drop_CountJump)
				{
					checkfall=0.5;
				}
				else checkfall=0.4;
				
				if(flags&FL_ONGROUND && firstfall_ground[id]==true && get_gametime()-FallTime1[id]>checkfall)
				{
					touch_ent[id]=false;		
					JumpReset(id);
					dropbhop[id]=false;
					ddnum[id]=0;
					x_jump[id]=false;
					firstfall_ground[id]=false;
					in_ladder[id]=false;
					nextbhop[id]=false;
					bhopaem[id]=false;
					UpcjFail[id]=false;
					slide_protec[id]=false;
					backwards[id]=false;
					ladderbug[id]=false;
					find_ladder[id]=false;
					touch_somthing[id]=false;
					duckbhop[id]=false;
					dropupcj[id]=false;
					//if(donehook[id]) ColorChat(id, RED, "reset ground %d %f",jump_type[id],get_gametime()-FallTime1[id]);
					return FMRES_IGNORED;
				}
				
				if(flags&FL_ONGROUND && firstfall_ground[id]==false)
				{
					FallTime1[id]=get_gametime();
					firstfall_ground[id]=true;
				}
				else if(!(flags&FL_ONGROUND) && firstfall_ground[id]==true)
				{
					firstfall_ground[id]=false;
				}
				
				if(flags&FL_ONGROUND && donehook[id] && hookcheck[id]==false)
				{
					timeonground[id]=get_gametime();
					hookcheck[id]=true;
				}
				else if(!(flags&FL_ONGROUND) && donehook[id] && hookcheck[id])
				{
					timeonground[id]=get_gametime()-timeonground[id];
					hookcheck[id]=false;
					
					if(timeonground[id]>0.4)
					donehook[id]=false;
				}
			}
		}
	}
	return FMRES_IGNORED;
}

public HamTouch( id, entity )
{
	if ( g_alive[id] )
	{
		static Float:Vvelocity[3];
		pev(id, pev_velocity, Vvelocity);
		if(!equali(mapname,"slide_gs_longjumps") && !equali(mapname,"b2j_slide_longjumps"))
		{
			if(g_Jumped[id] && !(pev(id, pev_flags)&FL_ONGROUND) && floatround(Vvelocity[2], floatround_floor) < 0)
			{
				touch_somthing[id]=true;
			}
		}
	}
}
public fwdTouch(ent, id)
{
	static ClassName[32];
	if( pev_valid(ent) )
	{
		pev(ent, pev_classname, ClassName, 31);
	}
	
	static ClassName2[32];
	if( valid_id(id) )
	{
		pev(id, pev_classname, ClassName2, 31);
	}
	if( equali(ClassName2, "player") )
	{
		if( equali(ClassName, "func_train")
			|| equali(ClassName, "func_conveyor") 
			|| equali(ClassName, "trigger_push") || equali(ClassName, "trigger_gravity"))
		{
			if(valid_id(id))
			{
				touch_ent[id]=true;
				JumpReset(id);
				set_task(0.4,"JumpReset", id);
			}
		}
	}
}

public fwdPostThink( id ) 
{
	if( g_alive[id] && g_userConnected[id])
	{
		if( g_Jumped[id] ) 
		{
			
			FullJumpFrames[id]++;
			
			static buttonsNew;
			
			static buttons;
			static Float:angle[3];
	
			buttonsNew = pev(id, pev_button);
			buttons = pev(id, pev_button);
			pev(id, pev_angles, angle);
			pev(id, pev_velocity, velocity);
			velocity[2] = 0.0;
			
			fSpeed = vector_length(velocity);
			
			
			if( old_angle1[id] > angle[1] ) {
				turning_left[id] = false;
				turning_right[id] = true;
			}
			else if( old_angle1[id] < angle[1] ) {
				turning_left[id] = true;
				turning_right[id] = false;
			} else {
				turning_left[id] = false;
				turning_right[id] = false;
			}
			//schetchik streifof
			if( !(strafecounter_oldbuttons[id]&IN_MOVELEFT) && buttonsNew&IN_MOVELEFT
			&& !(buttonsNew&IN_MOVERIGHT) && !(buttonsNew&IN_BACK) && !(buttonsNew&IN_FORWARD)
			&& (turning_left[id] || turning_right[id]) )
			{
				preessbutton[id]=true;
				button_what[id]=1;
				
				if(strafe_num[id] < NSTRAFES)
					strafe_stat_time[id][strafe_num[id]] = get_gametime();
				strafe_num[id] += 1;
				
				if(strafe_num[id]>0 && strafe_num[id]<100) type_button_what[id][strafe_num[id]]=1;
			}
			else if( !(strafecounter_oldbuttons[id]&IN_MOVERIGHT) && buttonsNew&IN_MOVERIGHT
			&& !(buttonsNew&IN_MOVELEFT) && !(buttonsNew&IN_BACK) && !(buttonsNew&IN_FORWARD)
			&& (turning_left[id] || turning_right[id]) )
			{
				preessbutton[id]=true;
				button_what[id]=2;
				
				if(strafe_num[id] < NSTRAFES)
					strafe_stat_time[id][strafe_num[id]] = get_gametime();
				strafe_num[id] += 1;
				
				if(strafe_num[id]>0 && strafe_num[id]<100) type_button_what[id][strafe_num[id]]=1;
			}
			else if( !(strafecounter_oldbuttons[id]&IN_BACK) && buttonsNew&IN_BACK
			&& !(buttonsNew&IN_MOVELEFT) && !(buttonsNew&IN_MOVERIGHT) && !(buttonsNew&IN_FORWARD)
			&& (turning_left[id] || turning_right[id]) )
			{
				preessbutton[id]=true;
				button_what[id]=1;
				
				if(strafe_num[id] < NSTRAFES)
					strafe_stat_time[id][strafe_num[id]] = get_gametime();
				strafe_num[id] += 1;
				
				if(strafe_num[id]>0 && strafe_num[id]<100) type_button_what[id][strafe_num[id]]=2;
			}
			else if( !(strafecounter_oldbuttons[id]&IN_FORWARD) && buttonsNew&IN_FORWARD
			&& !(buttonsNew&IN_MOVELEFT) && !(buttonsNew&IN_MOVERIGHT) && !(buttonsNew&IN_BACK)
			&& (turning_left[id] || turning_right[id]) )
			{
				preessbutton[id]=true;
				button_what[id]=2;
		
				if(strafe_num[id] < NSTRAFES)
					strafe_stat_time[id][strafe_num[id]] = get_gametime();
				strafe_num[id] += 1;
				
				if(strafe_num[id]>0 && strafe_num[id]<100) type_button_what[id][strafe_num[id]]=2;
			}
			
			if( buttonsNew&IN_MOVERIGHT
			|| buttonsNew&IN_MOVELEFT
			|| buttonsNew&IN_FORWARD
			|| buttonsNew&IN_BACK )
			{	
				//tskFps(id);
				if(strafe_num[id] < NSTRAFES)
				{
					if( fSpeed > speed)
					{
						strafe_stat_sync[id][strafe_num[id]][0] += 1; 
					}
					else
					{
						strafe_stat_sync[id][strafe_num[id]][1] += 1;
						if(uq_istrafe)
							line_lost[id][strafe_num[id]][lost_frame_count[id][strafe_num[id]]]=1;
					}
					
					if(uq_istrafe)
					{
						line_erase[id][strafe_num[id]]=lost_frame_count[id][strafe_num[id]];
						line_erase_strnum[id]=strafe_num[id];
					
						lost_frame_count[id][strafe_num[id]]++;
					}
				}
				
			}
			else if(uq_istrafe)
				strafe_lost_frame[id][strafe_num[id]] += 1;
			
			if( buttons&IN_MOVERIGHT && (buttons&IN_MOVELEFT || buttons&IN_FORWARD || buttons&IN_BACK) )
				strafecounter_oldbuttons[id] = 0;
			else if( buttons&IN_MOVELEFT && (buttons&IN_FORWARD || buttons&IN_BACK || buttons&IN_MOVERIGHT) )
				strafecounter_oldbuttons[id] = 0;
			else if( buttons&IN_FORWARD && (buttons&IN_BACK || buttons&IN_MOVERIGHT || buttons&IN_MOVELEFT) )
				strafecounter_oldbuttons[id] = 0;
			else if( buttons&IN_BACK && (buttons&IN_MOVERIGHT || buttons&IN_MOVELEFT || buttons&IN_FORWARD) )
				strafecounter_oldbuttons[id] = 0;
			else if( turning_left[id] || turning_right[id] )
				strafecounter_oldbuttons[id] = buttons;
		}
	}
}
public get_colorchat_by_distance(JumpType:type_jump,mSpeed,t_dist,bool:drop_a,multiscj_a,aircj)
{
	new dist_array[6];
	
	dist_array[2]=280;
		
	if(type_jump==Type_Double_CountJump || type_jump==Type_Multi_CountJump )
	{
		dist_array[5]=270;
		dist_array[4]=268;
		dist_array[3]=265;
		dist_array[2]=260;
		dist_array[1]=255;
		dist_array[0]=250;
	}
	else if(type_jump==Type_LongJump || type_jump==Type_HighJump)
	{	
		dist_array[5]=255;
		dist_array[4]=254;
		dist_array[3]=252;
		dist_array[2]=250;
		dist_array[1]=245;
		dist_array[0]=240;
	}
	else if(type_jump==Type_ladder)
	{	
		dist_array[5]=190;
		dist_array[4]=185;
		dist_array[3]=180;
		dist_array[2]=170;
		dist_array[1]=160;
		dist_array[0]=150;
	}
	else if(type_jump==Type_WeirdLongJump || type_jump==Type_Drop_CountJump || type_jump==Type_ladderBhop)
	{	
		dist_array[5]=270;
		dist_array[4]=268;
		dist_array[3]=265;
		dist_array[2]=260;
		dist_array[1]=255;
		dist_array[0]=250;
	}
	else if(type_jump==Type_BhopLongJump || type_jump==Type_StandupBhopLongJump)
	{	
		dist_array[5]=247;
		dist_array[4]=245;
		dist_array[3]=243;
		dist_array[2]=240;
		dist_array[1]=235;
		dist_array[0]=230;
	}
	else if(type_jump==Type_CountJump)
	{	
		dist_array[5]=267;
		dist_array[4]=265;
		dist_array[3]=263;
		dist_array[2]=260;
		dist_array[1]=255;
		dist_array[0]=250;
	}
	else if(type_jump==Type_Drop_BhopLongJump)
	{	
		dist_array[5]=267;
		dist_array[4]=265;
		dist_array[3]=263;
		dist_array[2]=260;
		dist_array[1]=250;
		dist_array[0]=240;
	}
	else if(type_jump==Type_StandUp_CountJump && drop_a==false)
	{	
		if(multiscj_a==0)
		{
			dist_array[5]=262+aircj;
			dist_array[4]=260+aircj;
			dist_array[3]=257+aircj;
			dist_array[2]=255+aircj;
			dist_array[1]=250+aircj;
			dist_array[0]=245+aircj;
		}
		else if(multiscj_a==1 || multiscj_a==2)
		{
			dist_array[5]=262+aircj+10;
			dist_array[4]=260+aircj+10;
			dist_array[3]=257+aircj+10;
			dist_array[2]=255+aircj+10;
			dist_array[1]=250+aircj+10;
			dist_array[0]=245+aircj+10;
		}
	}
	else if(type_jump==Type_StandUp_CountJump && drop_a)
	{	
		dist_array[5]=267;
		dist_array[4]=265;
		dist_array[3]=263;
		dist_array[2]=260;
		dist_array[1]=255;
		dist_array[0]=250;
	}
	else if(type_jump==Type_Bhop_In_Duck || type_jump==Type_Up_Bhop_In_Duck)
	{	
		dist_array[5]=220;
		dist_array[4]=217;
		dist_array[3]=215;
		dist_array[2]=212;
		dist_array[1]=210;
		dist_array[0]=205;
	}
	else if(type_jump==Type_Up_Bhop)
	{	
		dist_array[5]=245;
		dist_array[4]=242;
		dist_array[3]=240;
		dist_array[2]=235;
		dist_array[1]=230;
		dist_array[0]=225;
	}
	else if(type_jump==Type_Up_Stand_Bhop)
	{	
		dist_array[5]=245;
		dist_array[4]=242;
		dist_array[3]=240;
		dist_array[2]=235;
		dist_array[1]=230;
		dist_array[0]=225;
	}
	else if(type_jump==Type_Real_ladder_Bhop)
	{	
		dist_array[5]=267;
		dist_array[4]=265;
		dist_array[3]=260;
		dist_array[2]=255;
		dist_array[1]=250;
		dist_array[0]=240;
	}
	else if(type_jump==Type_DuckBhop)
	{	
		dist_array[5]=162;
		dist_array[4]=160;
		dist_array[3]=150;
		dist_array[2]=140;
		dist_array[1]=130;
		dist_array[0]=120;
	}
	
	if(mSpeed != 250.0 && type_jump!=Type_ladder)
	{
		dist_array[5]=dist_array[5]-t_dist;
		dist_array[4]=dist_array[4]-t_dist;
		dist_array[3]=dist_array[3]-t_dist;
		dist_array[2]=dist_array[2]-t_dist;
		dist_array[1]=dist_array[1]-t_dist;
		dist_array[0]=dist_array[0]-t_dist;
	}
	return dist_array;
}
public fnSaveBeamPos( client ) {
	if( g_Jumped[client] ) {
		new Float:vOrigin[3];
		pev(client, pev_origin, vOrigin);
		
		if( gBeam_count[client] < 100 ) {
			gBeam_points[client][gBeam_count[client]][0] = vOrigin[0];
			gBeam_points[client][gBeam_count[client]][1] = vOrigin[1];
			gBeam_points[client][gBeam_count[client]][2] = vOrigin[2];
			
			if(preessbutton[client])
			{
				gBeam_button[client][gBeam_count[client]]=true;
				
				if(button_what[client]==1)
				{
					gBeam_button_what[client][gBeam_count[client]]=1;
				}
				else if(button_what[client]==2)
				{
					gBeam_button_what[client][gBeam_count[client]]=2;
				}
			}
			
			if(is_user_ducking( client ))
				gBeam_duck[client][gBeam_count[client]] = true;
			
			gBeam_count[client]++;
		}
	}
}
public JumpReset(id)
{
	g_reset[id] = true;
}

public ddReset(id)
{
	id=id-2311;
	JumpReset(id);
	//ColorChat(id, GREEN, "reset dd");
}

public cmdColorChat(id)
{	
	if( !gHasColorChat[id] )
	{
		gHasColorChat[id] = true;
		ColorChat(id, GREEN, "^x04%s^x01 ColorChat enabled. To disable, type /colorchat.", prefix);
	}
	else 
	{
		gHasColorChat[id] = false;
		ColorChat(id, GREEN, "^x04%s^x01 ColorChat disabled. To enable, type /colorchat.", prefix);
	}
	
	return PLUGIN_CONTINUE;
}
public cmdljStats( id ) {
	
	if(g_lj_stats[id]==true) 
	{
		ColorChat(id, RED, "^x04%s^x01 Stats:^x03 disabled",prefix);
		g_lj_stats[id]=false;
		
		if(showpre[id]==true)
		{
			showpre[id]=false;
			oldpre[id]=1;
		}
		if(failearly[id]==true)
		{
			failearly[id]=false;
			oldfail[id]=1;
		}
		if(ljpre[id]==true)
		{
			ljpre[id]=false;
			oldljpre[id]=1;
		}
	}
	else 
	{
		if(oldpre[id]==1)
		{
			showpre[id]=true;
			oldpre[id]=0;
		}
		if(oldfail[id]==1)
		{
			failearly[id]=true;
			oldfail[id]=0;
		}
		if(oldljpre[id]==1)
		{
			ljpre[id]=true;
			oldljpre[id]=0;
		}
		g_lj_stats[id]=true;
		ColorChat(id, BLUE, "^x04%s^x01 Stats:^x03 enabled",prefix);
	}
	
}

public pre_stats(id)
{	
	if(kz_stats_pre[id]==true) 
	{
		ColorChat(id, RED, "^x04%s^x01 Prestrafe stats:^x03 disabled",prefix);
		kz_stats_pre[id]=false;
	}
	else 
	{
		kz_stats_pre[id]=true;
		ColorChat(id, BLUE, "^x04%s^x01 Prestrafe stats:^x03 enabled",prefix);
	}
}
public streif_stats(id)
{	
	if(streifstat[id]==true) 
	{
		ColorChat(id, RED, "^x04%s^x01 Strafe's stats:^x03 disabled",prefix);
		streifstat[id]=false;
	}
	else 
	{
		streifstat[id]=true;
		ColorChat(id, BLUE, "^x04%s^x01 Strafe's stats:^x03 enabled",prefix);
	}
}
public cmdljbeam(id)
{
	if(kz_beam[id]==true) 
	{
		ColorChat(id, RED, "^x04%s^x01 Beam:^x03 disabled",prefix);
		kz_beam[id]=false;
	}
	else 
	{
		kz_beam[id]=true;
		ColorChat(id, BLUE, "^x04%s^x01 Beam:^x03 enabled",prefix);
	}
}
public show_pre(id)
{
	if(showpre[id]==true) 
	{
		ColorChat(id, RED, "^x04%s^x01 ShowPre:^x03 disabled",prefix);
		showpre[id]=false;
	}
	else 
	{
		showpre[id]=true;
		ColorChat(id, BLUE, "^x04%s^x01 ShowPre:^x03 enabled",prefix);
	}
}
public show_speed(id)
{
	if(jofon[id])
	{
		ColorChat(id,RED,"^x04%s^x03 You need Turn off /joftr",prefix);
	}
		else
		{
			if(speedon[id]==false) 
			{
				ColorChat(id, BLUE, "^x04%s^x01 Speed:^x03 enabled",prefix);
				speedon[id]=true;
				
				set_task(0.1, "DoSpeed", id+212299, "", 0, "b", 0);
			}
			else 
			{
				speedon[id]=false;
				
				if( task_exists(id+212299, 0) )
					remove_task(id+212299, 0);
					
				ColorChat(id, RED, "^x04%s^x01 Speed:^x03 disabled",prefix);
			}
		}
}
public trainer_jof(id)
{
		if(speedon[id])
		{
			ColorChat(id,RED,"^x04%s^x03 You need Turn off /speed",prefix);
		}
		else
		{
			if(jofon[id]==false) 
			{
				ColorChat(id, BLUE, "^x04%s^x01 JumpOff Trainer:^x03 enabled",prefix);
				jofon[id]=true;
				jof[id]=0.0;
				set_task(0.1, "Dojof", id+212398, "", 0, "b", 0);
			}
			else 
			{
				jofon[id]=false;
				
				if( task_exists(id+212398, 0) )
					remove_task(id+212398, 0);
					
				ColorChat(id, RED, "^x04%s^x01 JumpOff Trainer:^x03 disabled",prefix);
			}
		}
}

public show_jheight(id)
{
	if(jheight_show[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Show Jump Height:^x03 enabled",prefix);
		jheight_show[id]=true;
	}
	else 
	{
		jheight_show[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Show Jump Height:^x03 disabled",prefix);
	}
}
public show_jof(id)
{
	if(showjofon[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Show JumpOff:^x03 enabled",prefix);
		showjofon[id]=true;
	}
	else 
	{
		showjofon[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Show JumpOff:^x03 disabled",prefix);
	}
}
public show_early(id)
{
	if(failearly[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Bhop fail warn:^x03 enabled",prefix);
		failearly[id]=true;
	}
	else 
	{
		failearly[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Bhop fail warn:^x03 disabled",prefix);
	}
}
public multi_bhop(id)
{
	if(multibhoppre[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Multi Bhop Prestrafe:^x03 enabled",prefix);
		multibhoppre[id]=true;
	}
	else 
	{
		multibhoppre[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Multi Bhop Prestrafe:^x03 disabled",prefix);
	}
}
public duck_show(id)
{
	if(showduck[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Ducks Prestrafe:^x03 enabled",prefix);
		showduck[id]=true;
	}
	else 
	{
		showduck[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Ducks Prestrafe:^x03 disabled",prefix);
	}
}
public lj_show(id)
{
	if(ljpre[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 LJ Prestrafe:^x03 enabled",prefix);
		ljpre[id]=true;
	}
	else 
	{
		ljpre[id]=false;
		ColorChat(id, RED, "^x04%s^x01 LJ Prestrafe:^x03 disabled",prefix);
	}
}
public enable_sounds(id)
{
	if(uq_sounds)
	{
		if(enable_sound[id]==false) 
		{
			ColorChat(id, BLUE, "^x04%s^x01 Sound's:^x03 enabled",prefix);
			enable_sound[id]=true;
		}
		else 
		{
			enable_sound[id]=false;
			ColorChat(id, RED, "^x04%s^x01 Sound's:^x03 disabled",prefix);
		}
	}
	else ColorChat(id, RED, "^x04%s^x01 Sounds^x03 disabled^x01 by Server",prefix);
}
public ShowedgeFail(id)
{
	if(Show_edge_Fail[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Show edge when failed:^x03 enabled",prefix);
		Show_edge_Fail[id]=true;
	}
	else 
	{
		Show_edge_Fail[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Show edge when failed:^x03 disabled",prefix);
	}
}
public Showedge(id)
{
	if(Show_edge[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Show edge:^x03 enabled",prefix);
		Show_edge[id]=true;
	}
	else 
	{
		Show_edge[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Show edge:^x03 disabled",prefix);
	}
}
public heightshow(id)
{
	if(height_show[id]==false) 
	{
		ColorChat(id, BLUE, "^x04%s^x01 Show Fall/Height distance:^x03 enabled",prefix);
		height_show[id]=true;
	}
	else 
	{
		height_show[id]=false;
		ColorChat(id, RED, "^x04%s^x01 Show Fall/Height distance:^x03 disabled",prefix);
	}
}
public ingame_st_stats(id)
{
	if(uq_istrafe)
	{
		if(ingame_strafe[id]==false) 
		{
			ColorChat(id, BLUE, "^x04%s^x01 Show InGame Strafe Stats:^x03 enabled",prefix);
			ingame_strafe[id]=true;
		}
		else 
		{
			ingame_strafe[id]=false;
			ColorChat(id, RED, "^x04%s^x01 Show InGame Strafe Stats:^x03 disabled",prefix);
		}
	}
	else ColorChat(id, RED, "^x04%s^x03 Show InGame Strafe Stats disabled by Server",prefix);
	
}

public client_connect( id )
{
	oldljpre[id]=0;
	oldpre[id]=0;
	oldfail[id]=0;
	g_userConnected[id]=true;
	
	static connectt[30];
	get_pcvar_string(kz_uq_connect, connectt, 30);
	
	format(connectt, 30, "_%s", connectt);

	if( contain(connectt, "a") > 0 )
		gHasColorChat[id] =true;
	else
		gHasColorChat[id] = false;
	if( contain(connectt, "b") > 0 )
		g_lj_stats[id] = true;
	else
		g_lj_stats[id] = false;
	if( contain(connectt, "c") > 0 )
		speedon[id]=true;
	else 
		speedon[id]=false;
	if( contain(connectt, "d") > 0 )
		showpre[id]=true;
	else
		showpre[id]=false;
	if( contain(connectt, "e") > 0 )
		streifstat[id]=true;
	else
		streifstat[id]=false;
	if( contain(connectt, "f") > 0 )
		kz_beam[id]=true;
	else
		kz_beam[id]=false;
	if( contain(connectt, "g") > 0 )
		kz_stats_pre[id]=true;
	else
		kz_stats_pre[id]=false;
	if( contain(connectt, "h") > 0 )
		failearly[id]=true;
	else
		failearly[id]=false;
	if( contain(connectt, "i") > 0 )
		multibhoppre[id]=true;
	else
		multibhoppre[id]=false;
	if( contain(connectt, "j") > 0 )
		showduck[id]=true;
	else
		showduck[id]=false;
	if( contain(connectt, "k") > 0 )
		ljpre[id]=true;
	else
		ljpre[id]=false;
	if( contain(connectt, "l") > 0 )
		Show_edge[id]=true;
	else
		Show_edge[id]=false;
	if( contain(connectt, "m") > 0 )
		Show_edge_Fail[id]=true;
	else
		Show_edge_Fail[id]=false;
	if( contain(connectt, "n") > 0 )
		enable_sound[id]=true;
	else
		enable_sound[id]=false;
	if( contain(connectt, "o") > 0 )
		ingame_strafe[id]=true;
	else
		ingame_strafe[id]=false;
	
	//for beta
	//ingame_strafe[id]=true;
	
	user_block[id][0]=uq_maxedge;
	user_block[id][1]=uq_minedge;
	min_prestrafe[id]=uq_min_pre;
	beam_type[id]=1;
	edgeshow[id]=true;	
	first_ground_bhopaem[id]=false;
	donehook[id]=false;
	OnGround[id]=false;
	serf_reset[id]=false;
	first_onground[id]=false;
	duckstring[id]=false;
	firstshow[id]=false;
	height_show[id]=false;
	Checkframes[id]=false;
	firstfall_ground[id]=false;
	h_jumped[id]=false;
	touch_ent[id]=false;
	ddafterJump[id]=false;
	UpcjFail[id]=false;
	slide_protec[id]=false;
	posibleScj[id]=false;
	x_jump[id]=false;
	ddforcj[id]=false;
	dropbhop[id]=false;
	ddnum[id]=0;
	hookcheck[id]=false;
	backwards[id]=false;
	ladderbug[id]=false;
	touch_somthing[id]=false;
	record_start[id]=0;
	duckbhop_bug_pre[id]=false;
	showtime_st_stats[id]=40;

}


public client_infochanged(id) {
	new name[65];
	
	get_user_info(id, "name", name,64); 
	
	if(!equali(name, g_playername[id]))
		copy(g_playername[id], 64, name);
}

public ResetHUD(id)
{
	if(is_user_alive(id) && !is_user_hltv(id) )
	{
		if(firstshow[id]==false)
		{
			firstshow[id]=true;
			
			if(equali(mapname,"slide_gs_longjumps") || equali(mapname,"b2j_slide_longjumps"))
			{
				ColorChat(id, RED, "^x01%s^x03 Slide stats:^x04 Enable",prefix);
			}
		}
		
		firstfall_ground[id]=false;
		h_jumped[id]=false;
		
		ddafterJump[id]=false;
		UpcjFail[id]=false;
		slide_protec[id]=false;
		posibleScj[id]=false;
		x_jump[id]=false;
		ddforcj[id]=false;
		dropbhop[id]=false;
		ddnum[id]=0;
		donehook[id]=false;
		hookcheck[id]=false;
		backwards[id]=false;
		Checkframes[id]=false;
		first_ground_bhopaem[id]=false;
		touch_ent[id]=false;
		ladderbug[id]=false;
		touch_somthing[id]=false;
	}
	
}
public FwdPlayerSpawn(id)
{
	if( is_user_alive(id) && !is_user_bot(id) && !is_user_hltv(id))
	{
		if( !task_exists(id+434490, 0) )
			set_task(1.0, "tskFps", id+434490, "", 0, "b", 0);
			
		g_alive[id] = true;
		strafe_num[id]=0;
	}
}

public FwdPlayerDeath(id)
{
	if( task_exists(id, 0) )
		remove_task(id, 0);
		
	if( task_exists(id+434490, 0) )
		remove_task(id+434490, 0);
		
	if( task_exists(id, 0) )
		remove_task(id, 0);
	
	if( task_exists(id+89012, 0) )
		remove_task(id+89012, 0);
	
	if( task_exists(id+3313, 0) )
		remove_task(id+3313, 0);
	
	if( task_exists(id+3214, 0) )
		remove_task(id+3214, 0);
		
	if( task_exists(id+15237, 0) )
		remove_task(id+15237, 0);
	
	if( task_exists(id+212398, 0) )
		remove_task(id+212398, 0);
		
	g_alive[id] = false;
}

public client_disconnect(id)
{
	new tmp_str[3];
	num_to_str(g_sql_pid[id], tmp_str, 2);

	if(TrieKeyExists(JumpPlayers, tmp_str))
		TrieDeleteKey(JumpPlayers, tmp_str);
	
	remove_beam_ent(id);
	
	login[id]=false;
	g_userConnected[id]=false;
	OnGround[id]=false;
	g_alive[id]=false;
	
	
	if( task_exists(id, 0) )
		remove_task(id);
	
	firstshow[id]=false;
	if( task_exists(id+434490, 0) )
		remove_task(id+434490, 0);
		
	if( task_exists(id, 0) )
		remove_task(id, 0);
	
	if( task_exists(id+89012, 0) )
		remove_task(id+89012, 0);

	if( task_exists(id+3313, 0) )
		remove_task(id+3313, 0);
	
	if( task_exists(id+3214, 0) )
		remove_task(id+3214, 0);
		
	if( task_exists(id+15237, 0) )
		remove_task(id+15237, 0);
		
	if( task_exists(id+212299, 0) )
		remove_task(id+212299, 0);
		
	if( task_exists(id+212398, 0) )
		remove_task(id+212398, 0);
		
	if( task_exists(id, 0) )
		remove_task(id, 0);
}

public Option(id)
{	
	new MenuBody[512], len, keys;
	len = format(MenuBody, 511, "\yOptions Menu 1/3 ^n");
	
	if(g_lj_stats[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r1. \yShowStats: \wEnable");
		keys |= (1<<0);
	}
	else
	{
		keys |= (1<<0);
		len += format(MenuBody[len], 511-len, "^n\r1. \yShowStats: \dDisable");
	}
	
	if(gHasColorChat[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r2. \yColorchat: \wEnable");
		keys |= (1<<1);
	}
	else
	{
		keys |= (1<<1);
		len += format(MenuBody[len], 511-len, "^n\r2. \yColorchat: \dDisable");
	}
	
	if(speedon[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r3. \yShow speed: \wEnable");
		keys |= (1<<2);
	}
	else
	{
		keys |= (1<<2);
		len += format(MenuBody[len], 511-len, "^n\r3. \yShow speed: \dDisable");
	}
	
	if(showpre[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r4. \yShow prestrafe: \wEnable");
		keys |= (1<<3);
	}
	else
	{
		keys |= (1<<3);
		len += format(MenuBody[len], 511-len, "^n\r4. \yShow prestrafe: \dDisable");
	}
	
	if(streifstat[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r5. \yShow strafes stats: \wEnable");
		keys |= (1<<4);
	}
	else
	{
		keys |= (1<<4);
		len += format(MenuBody[len], 511-len, "^n\r5. \yShow strafes stats: \dDisable");
	}
	
	if(kz_beam[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r6. \yShow beam after jump: \wEnable");
		keys |= (1<<5);
	}
	else
	{
		keys |= (1<<5);
		len += format(MenuBody[len], 511-len, "^n\r6. \yShow beam after jump: \dDisable");
	}
	
	if(showduck[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r7. \yShow ducks Prestrafe: \wEnable");
		keys |= (1<<6);
	}
	else
	{
		keys |= (1<<6);
		len += format(MenuBody[len], 511-len, "^n\r7. \yShow ducks Prestrafe: \dDisable");
	}
	if(failearly[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r8. \yBhop fail warn: \wEnable");
		keys |= (1<<7);
	}
	else
	{
		keys |= (1<<7);
		len += format(MenuBody[len], 511-len, "^n\r8. \yBhop fail warn: \dDisable");
	}

	len += format(MenuBody[len], 511-len, "^n^n\r9. \wGo to the Next page");
	keys |= (1<<8);
		
	len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
	keys |= (1<<9);
	
	show_menu(id, keys, MenuBody, -1, "StatsOptionMenu1");	
}

public OptionMenu1(id, key)
{
	switch((key+1))
	{
		case 1:
		{
			cmdljStats(id);
			Option(id);
			
		}
		case 2:
		{
			cmdColorChat(id);
			Option(id);
		}
		case 3:
		{
			show_speed(id);
			Option(id);
		}
		case 4:
		{
			show_pre(id);
			Option(id);
		}
		case 5:
		{
			streif_stats(id);
			Option(id);
		}
		case 6:
		{
			cmdljbeam(id);
			Option(id);
		}
		case 7:
		{
			duck_show(id);
			Option(id);
		}
		case 8:
		{
			show_early(id);
			Option(id);
		}
		case 9:
		{
			Option2(id);
		}

	}
	return PLUGIN_HANDLED;
}
public Option2(id)
{	
	new MenuBody[512], len, keys;
	len = format(MenuBody, 511, "\yOptions Menu 2/3 ^n");
	
	if(multibhoppre[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r1. \yMulti Bhop Prestrafe: \wEnable");
		keys |= (1<<0);
	}
	else
	{
		keys |= (1<<0);
		len += format(MenuBody[len], 511-len, "^n\r1. \yMulti Bhop Prestrafe: \dDisable");
	}
	if(Show_edge[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r2. \yShow Edge: \wEnable");
		keys |= (1<<1);
	}
	else
	{
		keys |= (1<<1);
		len += format(MenuBody[len], 511-len, "^n\r2. \yShow Edge: \dDisable");
	}
	if(Show_edge_Fail[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r3. \yShow Edge when Failed \d(without block)\y: \wEnable");
		keys |= (1<<2);
	}
	else
	{
		keys |= (1<<2);
		len += format(MenuBody[len], 511-len, "^n\r3. \yShow Edge when Failed \d(without block)\y: \dDisable");
	}
	
	len += format(MenuBody[len], 511-len, "^n\r4. \yMin Block for Edge: \w%d",user_block[id][1]);
	keys |= (1<<3);
	len += format(MenuBody[len], 511-len, "^n\r5. \yMax Block for Edge: \w%d",user_block[id][0]);
	keys |= (1<<4);
	len += format(MenuBody[len], 511-len, "^n\r6. \yMinimum Prestrafe to Show: \w%d",min_prestrafe[id]);
	keys |= (1<<5);
	
	if(beam_type[id]==1)
	{
		len += format(MenuBody[len], 511-len, "^n\r7. \yBeam Type: \w1");
		keys |= (1<<6);
	}
	else if(beam_type[id]==2)
	{
		len += format(MenuBody[len], 511-len, "^n\r7. \yBeam Type: \w2");
		keys |= (1<<6);
	}
	
	
	len += format(MenuBody[len], 511-len, "^n^n\r8. \wBack to the First Page");
	keys |= (1<<7);
	len += format(MenuBody[len], 511-len, "^n\r9. \wGo to the Next Page");
	keys |= (1<<8);	
	len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
	keys |= (1<<9);
	
	show_menu(id, keys, MenuBody, -1, "StatsOptionMenu2");
		
}

public OptionMenu2(id, key)
{
	switch((key+1))
	{
		case 1:
		{
			multi_bhop(id);
			Option2(id);	
		}
		case 2:
		{
			Showedge(id);
			Option2(id);	
		}
		case 3:
		{
			ShowedgeFail(id);
			Option2(id);	
		}
		case 4:
		{
			user_block[id][1]=user_block[id][1]+10;
			if(user_block[id][1]>=user_block[id][0])
			{
				user_block[id][1]=uq_minedge;
			}
			Option2(id);	
		}
		case 5:
		{
			if(user_block[id][0]==uq_maxedge)
			{
				user_block[id][0]=user_block[id][1];
				client_print(id,print_center,"Reached a maximum value (%d)",uq_maxedge);
			}
			user_block[id][0]=user_block[id][0]+10;
			Option2(id);	
		}
		case 6:
		{
			if(min_prestrafe[id]>=320)
			{
				min_prestrafe[id]=0;
				client_print(id,print_center,"Reached a maximum value (320)");
			}
			min_prestrafe[id]=min_prestrafe[id]+20;
			Option2(id);	
		}
		case 7:
		{
			if(beam_type[id]==1)
			{
				beam_type[id]=2;
				client_print(id,print_center,"Beam With Showing Strafes");
			}
			else
			{
				beam_type[id]=1;
				client_print(id,print_center,"Standart Beam");
			}
			Option2(id);	
		}
		case 8:
		{
			Option(id);	
		}
		case 9:
		{
			Option3(id);	
		}
	}
	return PLUGIN_HANDLED;
}
public Option3(id)
{	
	new MenuBody[512], len, keys;
	len = format(MenuBody, 511, "\yOptions Menu 3/3 ^n");
	
	if(enable_sound[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r1. \ySounds: \wEnable");
		keys |= (1<<0);
	}
	else
	{
		keys |= (1<<0);
		len += format(MenuBody[len], 511-len, "^n\r1. \ySounds: \dDisable");
	}
	if(showjofon[id]==true)
	{
		len += format(MenuBody[len], 511-len, "^n\r2. \yShow JumpOff: \wEnable");
		keys |= (1<<1);
	}
	else
	{
		keys |= (1<<1);
		len += format(MenuBody[len], 511-len, "^n\r2. \yShow JumpOff: \dDisable");
	}
	if(height_show[id])
	{
		len += format(MenuBody[len], 511-len, "^n\r3. \yShow Jump Height: \wEnable");
		keys |= (1<<2);
	}
	else
	{
		len += format(MenuBody[len], 511-len, "^n\r3. \yShow Jump Height: \dDisable");
		keys |= (1<<2);
	}
	if(jofon[id])
	{
		len += format(MenuBody[len], 511-len, "^n\r4. \yJumpOff Trainer: \wEnable");
		keys |= (1<<3);
	}
	else
	{
		len += format(MenuBody[len], 511-len, "^n\r4. \yJumpOff Trainer: \dDisable");
		keys |= (1<<3);
	}
	if(jheight_show[id])
	{
		len += format(MenuBody[len], 511-len, "^n\r5. \yJump Height: \wEnable");
		keys |= (1<<4);
	}
	else
	{
		len += format(MenuBody[len], 511-len, "^n\r5. \yJump Height: \dDisable");
		keys |= (1<<4);
	}
	if(uq_istrafe)
	{
		if(ingame_strafe[id])
		{
			len += format(MenuBody[len], 511-len, "^n\r6. \yInGame Strafe Stats: \wEnable");
			keys |= (1<<5);
		}
		else
		{
			len += format(MenuBody[len], 511-len, "^n\r6. \yInGame Strafe Stats: \dDisable");
			keys |= (1<<5);
		}
	}
	else len += format(MenuBody[len], 511-len, "^n\r6. \dInGame Strafe Stats disabled by Server");
	
	len += format(MenuBody[len], 511-len, "^n\r7. \yInGame Strafe Stats Showing Time: \w%ds",showtime_st_stats[id]/10);
	keys |= (1<<6);
		
	len += format(MenuBody[len], 511-len, "^n^n\r9. \wBack to the Previous Page");
	keys |= (1<<8);
		
	len += format(MenuBody[len], 511-len, "^n^n\r0. \wExit");
	keys |= (1<<9);
	
	show_menu(id, keys, MenuBody, -1, "StatsOptionMenu3");
		
}
public OptionMenu3(id, key)
{
	switch((key+1))
	{
		case 1:
		{
			enable_sounds(id);
			Option3(id);	
		}
		case 2:
		{
			show_jof(id);
			Option3(id);	
		}
		case 3:
		{
			heightshow(id);
			Option3(id);	
		}
		case 4:
		{
			trainer_jof(id);
			Option3(id);
		}
		case 5:
		{
			show_jheight(id);
			Option3(id);
		}
		case 6:
		{
			ingame_st_stats(id);
			Option3(id);
		}
		case 7:
		{
			if(showtime_st_stats[id]==200)
			{
				client_print(id,print_center,"Maximum 20 seconds");
				showtime_st_stats[id]=0;
			}
			showtime_st_stats[id]=showtime_st_stats[id]+10;

			Option3(id);
		}
	
		case 9:
		{
			Option2(id);	
		}
	}
	return PLUGIN_HANDLED;
}

public plugin_end() 
{ 
	if(DB_TUPLE)
		SQL_FreeHandle(DB_TUPLE);
	if(SqlConnection)
		SQL_FreeHandle(SqlConnection);
		
	TrieDestroy(JumpPlayers);
}