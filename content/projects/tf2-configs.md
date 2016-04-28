+++
date = "2013-01-01T00:00:00-00:00"
draft = false
title = "TF2 Configs"
+++

_(Note: these are old and crufty and probably don't fully reflect the state of the game at this
point. Your mileage may vary.)_

I (used to) maintain a fairly comprehensive set of config files for Team Fortress 2 for my personal use.
On occasion, I need to share a particular part of them with someone. To make this easier,
I've decided to keep my latest (or as long as I remember to update them) copy of the configs
available here for public use.

## [autoexec.cfg](/files/tf2configs/autoexec.cfg)

    // autoexec.cfg gets executed once, so game-wide settings go here: graphics, networking, etc

    // Graphics settings

    fov_desired                        90
    mat_viewportscale                  1
    cl_hud_playerclass_use_playermodel 1
    cl_showbackpackrarities            1
    cl_show_market_data_on_items       1
    cl_logofile                        "materials/vgui/logos/hFbKTHX.vtf"

    // Network settings
    // http://www.reddit.com/r/truetf2/comments/stutd/tf2_and_interpolation/

    cl_interp       0
    cl_updaterate   67
    cl_cmdrate      67
    cl_interp_ratio 1

    // Sound settings

    dsp_water 0

    // PREC settings

    prec_dir    prec
    prec_notify 1
    prec_mode   2

    // Misc settings

    cl_software_cursor    1
    hud_fastswitch        1
    con_enable            1
    cl_disablehtmlmotd    0
    alias closed_htmlpage "echo Blocked pinion!"
    con_logfile           console.log

    // Disable tutorials

    tf_training_has_prompted_for_training                1
    tf_training_has_prompted_for_offline_practice        1
    tf_training_has_prompted_for_forums                  1
    tf_training_has_prompted_for_options                 1
    tf_training_has_prompted_for_loadout                 1
    tf_explanations_backpackpanel                        1
    tf_explanations_charinfo_armory_panel                1
    tf_explanations_charinfopanel                        1
    tf_explanations_craftingpanel                        1
    tf_explanations_discardpanel                         1
    tf_explanations_store                                1
    tf_explanations_tradingpanel                         1
    tf_show_preset_explanation_in_class_loadout          0
    tf_highfive_hintcount                                99
    sv_unlockedchapters                                  99
    cl_training_completed_with_classes                   255
    cl_hud_playerclass_playermodel_showed_confirm_dialog 1

## [default.cfg](/files/tf2configs/default.cfg)

    // default.cfg is called at the top of every class specific config
    // binds and such go here so they can be reset on class change

    // Mouse options

    sensitivity   1
    m_rawinput    1
    m_filter      0
    m_customaccel 0

    // Default viewmodel state is off

    r_drawviewmodel 0
    alias "cjs_toggleviewmodels"           "cjs__toggleviewmodels_enabled"
    alias "cjs__viewmodels"                "r_drawviewmodel 0"
    alias "cjs__toggleviewmodels_enabled"  "r_drawviewmodel 1; alias cjs__viewmodels ""r_drawviewmodel 1""; alias cjs_toggleviewmodels ""cjs__toggleviewmodels_disabled"""
    alias "cjs__toggleviewmodels_disabled" "r_drawviewmodel 0; alias cjs__viewmodels ""r_drawviewmodel 0""; alias cjs_toggleviewmodels ""cjs__toggleviewmodels_enabled"""

    // Convenience aliases for switching weapons
    // Melee always has viewmodels on

    alias "cjs_slot1"  "cjs__viewmodels;   slot1"
    alias "cjs_slot2"  "cjs__viewmodels;   slot2"
    alias "cjs_slot3"  "r_drawviewmodel 1; slot3"
    alias "cjs_slot4"  "cjs__viewmodels;   slot4"
    alias "cjs_slot5"  "cjs__viewmodels;   slot5"
    alias "cjs_slot6"  "cjs__viewmodels;   slot6"
    alias "cjs_slot7"  "cjs__viewmodels;   slot7"
    alias "cjs_slot8"  "cjs__viewmodels;   slot8"
    alias "cjs_slot9"  "cjs__viewmodels;   slot9"
    alias "cjs_slot10" "cjs__viewmodels;   slot10"

    // Anti-locking movement aliases

    alias "+cjs_forward"   "-back;      +forward;          alias ""cjs__checkforward"" ""+forward"""
    alias "+cjs_back"      "-forward;   +back;             alias ""cjs__checkback""    ""+back"""
    alias "+cjs_moveleft"  "-moveright; +moveleft;         alias ""cjs__checkleft      ""+moveleft"""
    alias "+cjs_moveright" "-moveleft;  +moveright;        alias ""cjs__checkright     ""+moveright"""
    alias "-cjs_forward"   "-forward;   cjs__checkback;    alias ""cjs__checkforward"" ""cjs__none"""
    alias "-cjs_back"      "-back;      cjs__checkforward; alias ""cjs__checkback""    ""cjs__none"""
    alias "-cjs_moveleft"  "-moveleft;  cjs__checkright;   alias ""cjs__checkleft""    ""cjs__none"""
    alias "-cjs_moveright" "-moveright; cjs__checkleft;    alias ""cjs__checkright""   ""cjs__none"""

    alias "cjs__checkforward" "cjs__none"
    alias "cjs__checkback"    "cjs__none"
    alias "cjs__checkleft"    "cjs__none"
    alias "cjs__checkright"   "cjs__none"
    alias "cjs__none"         ""

    // Jumpduck? Duckjump? Divekick?

    alias "+cjs_crouchjump" "+jump; +duck"
    alias "-cjs_crouchjump" "-jump; -duck"

    // Scoreboard with MORE INFO

    alias "+cjs_scores" "+showscores; net_graph 4"
    alias "-cjs_scores" "-showscores; net_graph 0"

    // This fixes HUD, sound, and render issues
    // Don't use while recording a demo

    alias "cjs_fix" "snd_restart; hud_reloadscheme; record fix; stop"

    // Autoreload is almost always a good thing

    cl_autoreload 1

    // Enable damage dings, and modify pitch based on damage done

    tf_dingalingaling        1
    tf_dingaling_pitchmaxdmg 30
    tf_dingaling_pitchmindmg 150

    // Display damage done, health healed, and batch damage together

    hud_combattext                            1
    hud_combattext_batching                   1
    hud_combattext_healing                    1
    hud_combattext_doesnt_block_overhead_text 1

    // Crosshair - small green circle

    cl_crosshair_file  crosshair3
    cl_crosshair_scale 32
    cl_crosshair_red   0
    cl_crosshair_green 255
    cl_crosshair_blue  0

    // Viewmodel FOV.. real FOV is set in autoexec

    viewmodel_fov 70

    // Keybinds
    // These are sort of grouped together by region on the keyboard (US English)

    unbindall

    bind "f1"  "jointeam red"
    bind "f2"  "jointeam blue"
    bind "f3"  "spectate"
    bind "f4"  ""
    bind "f5"  ""
    bind "f6"  ""
    bind "f7"  ""
    bind "f8"  ""
    bind "f9"  ""
    bind "f10" ""
    bind "f11" ""
    bind "f12" ""

    bind "1" "cjs_slot1"
    bind "2" "cjs_slot2"
    bind "3" "cjs_slot3"
    bind "4" "cjs_slot4"
    bind "5" "cjs_slot5"
    bind "6" "cjs_slot6"
    bind "7" "cjs_slot7"
    bind "8" "cjs_slot8"
    bind "9" "cjs_slot9"
    bind "0" "cjs_slot10"

    bind "q" "cjs_slot2"
    bind "w" "+cjs_forward"
    bind "e" "voicemenu 0 0" // Medic
    bind "r" "+reload"
    bind "t" "impulse 201"   // Spray
    bind "y" "lastdisguise"
    bind "u" "say_team Enemy is in European position"
    bind "i" "voice_menu_1"
    bind "o" "voice_menu_2"
    bind "p" "voice_menu_3"

    bind "a" "+cjs_moveleft"
    bind "s" "+cjs_back"
    bind "d" "+cjs_moveright"
    bind "f" "voicemenu 0 6" // Yes
    bind "g" "voicemenu 0 7" // No
    bind "h" "+taunt"
    bind "j" "+use_action_slot_item"
    bind "k" "cl_trigger_first_notification"
    bind "l" "cl_decline_first_notification"

    bind "z" "voicemenu 0 1" // Thanks
    bind "x" "voicemenu 1 1" // Spy
    //bind "c" "voicemenu 1 4" // Dispenser Here
    bind "c" "+use_action_slot_item"
    bind "v" "inspect"
    bind "b" "dropitem"
    bind "n" "cjs_toggleviewmodels"
    bind "m" "explode"

    bind "escape"    "escape"
    bind "`"         "toggleconsole"
    bind "tab"       "+cjs_scores"
    bind "shift"     "+duck"
    bind "ctrl"      "+duck"
    bind "alt"       ""
    bind "space"     "+jump"

    bind "-"         "disguiseteam"
    bind "="         ""
    bind "backspace" ""
    bind "["         "buddha"
    bind "]"         "noclip"
    bind "\"         "say_team"
    bind "semicolon" ""
    bind "'"         ""
    bind "enter"     "say"
    bind ","         "open_charinfo_direct"
    bind "."         "changeclass"
    bind "/"         "changeteam"
    bind "rshift"    ""
    bind "rctrl"     ""
    bind "ralt"      ""

    bind "scrolllock" ""
    bind "ins"        ""
    bind "home"       ""
    bind "pgup"       ""
    bind "del"        ""
    bind "end"        "cjs_fix"
    bind "pgdn"       ""

    bind "uparrow"    ""
    bind "leftarrow"  ""
    bind "downarrow"  ""
    bind "rightarrow" ""

    bind "numlock"       ""
    bind "kp_slash"      ""
    bind "kp_multiply"   ""
    bind "kp_minus"      ""
    bind "kp_plus"       ""
    bind "kp_enter"      ""
    bind "kp_del"        "" // .
    bind "kp_ins"        "" // 0
    bind "kp_end"        "" // 1
    bind "kp_downarrow"  "" // 2
    bind "kp_pgdn"       "" // 3
    bind "kp_leftarrow"  "" // 4
    bind "kp_5"          "" // 5
    bind "kp_rightarrow" "" // 6
    bind "kp_home"       "" // 7
    bind "kp_uparrow"    "" // 8
    bind "kp_pgup"       "" // 9

    bind "mouse1"     "+attack"
    bind "mouse2"     "+attack2"
    bind "mouse3"     ""
    bind "mouse4"     "+voicerecord"
    bind "mouse5"     "cjs_slot2"
    bind "mwheeldown" "cjs_slot1"
    bind "mwheelup"   "cjs_slot3"

## [soldier.cfg](/files/tf2configs/soldier.cfg)
    exec default
    // I don't use this anymore, but leaving it here
    alias "+cjs_rocketjump" "+duck; +jump; +attack"
    alias "-cjs_rocketjump" "-attack; -jump; -duck"
    // bind "mouse3" "+cjs_rocketjump"

## [pyro.cfg](/files/tf2configs/pyro.cfg)
    exec default
    // Viewmodel FOV of 80 gives most accurate flame representation
    viewmodel_fov 80

## [engineer.cfg](/files/tf2configs/engineer.cfg)
    exec default
    // Middle click for quickly building sentries
    alias "cjs_quickbuild" "destroy 2; build 2"
    bind "mouse3" "cjs_quickbuild"


## [spy.cfg](/files/tf2configs/spy.cfg)
    // Autoreloading is annoying with Spy revolver

    cl_autoreload 0

    // Enable viewmodels for spy - can't see if cloaked / DR without it easily

    r_drawviewmodel 1
    alias "cjs__viewmodels" "r_drawviewmodel 1"

    // "Random" disguise bind

    alias "disguise_random"   "disguise_random_1"
    alias "disguise_random_1" "disguise 1 -1; alias disguise_random disguise_random_2" // Scout
    alias "disguise_random_2" "disguise 4 -1; alias disguise_random disguise_random_3" // Demoman
    alias "disguise_random_3" "disguise 2 -1; alias disguise_random disguise_random_4" // Sniper
    alias "disguise_random_4" "disguise 7 -1; alias disguise_random disguise_random_5" // Pyro
    alias "disguise_random_5" "disguise 8 -1; alias disguise_random disguise_random_6" // Spy
    alias "disguise_random_6" "disguise 5 -1; alias disguise_random disguise_random_7" // Medic
    alias "disguise_random_7" "disguise 9 -1; alias disguise_random disguise_random_1" // Engineer

    bind "mouse3" "disguise_random"

    // Numpad disguises

    alias "disguise_scout_friendly"    "disguise 1 -2"
    alias "disguise_soldier_friendly"  "disguise 3 -2"
    alias "disguise_pyro_friendly"     "disguise 7 -2"
    alias "disguise_demoman_friendly"  "disguise 4 -2"
    alias "disguise_heavy_friendly"    "disguise 6 -2"
    alias "disguise_engineer_friendly" "disguise 9 -2"
    alias "disguise_medic_friendly"    "disguise 5 -2"
    alias "disguise_sniper_friendly"   "disguise 2 -2"
    alias "disguise_spy_friendly"      "disguise 8 -2"

    alias "disguise_scout_enemy"    "disguise 1 -1"
    alias "disguise_soldier_enemy"  "disguise 3 -1"
    alias "disguise_pyro_enemy"     "disguise 7 -1"
    alias "disguise_demoman_enemy"  "disguise 4 -1"
    alias "disguise_heavy_enemy"    "disguise 6 -1"
    alias "disguise_engineer_enemy" "disguise 9 -1"
    alias "disguise_medic_enemy"    "disguise 5 -1"
    alias "disguise_sniper_enemy"   "disguise 2 -1"
    alias "disguise_spy_enemy"      "disguise 8 -1"

    alias "disguise_friendly" "bind KP_END disguise_scout_friendly; bind KP_DOWNARROW disguise_soldier_friendly; bind KP_PGDN disguise_pyro_friendly; bind KP_LEFTARROW disguise_demoman_friendly; bind KP_5 disguise_heavy_friendly; bind KP_RIGHTARROW disguise_engineer_friendly; bind KP_HOME disguise_medic_friendly; bind KP_UPARROW disguise_sniper_friendly; bind KP_PGUP disguise_spy_friendly"
    alias "disguise_enemy"    "bind KP_END disguise_scout_enemy;    bind KP_DOWNARROW disguise_soldier_enemy;    bind KP_PGDN disguise_pyro_enemy;    bind KP_LEFTARROW disguise_demoman_enemy;    bind KP_5 disguise_heavy_enemy;    bind KP_RIGHTARROW disguise_engineer_enemy;    bind KP_HOME disguise_medic_enemy;    bind KP_UPARROW disguise_sniper_enemy;    bind KP_PGUP disguise_spy_enemy"

    alias "disguise_toggle_enemy"    "bind KP_INS disguise_toggle_friendly; disguise_enemy"
    alias "disguise_toggle_friendly" "bind KP_INS disguise_toggle_enemy;    disguise_friendly"

    bind "KP_DEL" "disguise_spy_friendly"

    disguise_toggle_enemy

## [spectator.cfg](/files/tf2configs/spectator.cfg)
    exec default
    // Crouch-jump alias screws with changing spec modes, so bind it directly in spec
    bind "space" "spec_mode"
    bind "tab"   "+showscores"

## [listenserver.cfg](/files/tf2configs/listenserver.cfg)
    // Reset all cvars when a listen server is started
    // Otherwise replication could screw us

    tv_enable 0
    tf_tournament_classlimit_soldier -1
    tf_tournament_classlimit_medic -1
    tf_tournament_classlimit_scout -1
    tf_tournament_classlimit_demoman -1
    tf_tournament_classlimit_pyro -1
    tf_tournament_classlimit_sniper -1
    tf_tournament_classlimit_heavy -1
    tf_tournament_classlimit_engineer -1
    tf_tournament_classlimit_spy -1
    decalfrequency 30
    host_framerate 0
    mp_allowspectators 1
    mp_autocrosshair 0
    mp_autoteambalance 0
    mp_bonusroundtime 0
    mp_chattime 10
    mp_disable_respawn_times 0
    mp_enableroundwaittime 1
    mp_fadetoblack 0
    mp_falldamage 1
    mp_footsteps 1
    mp_forcecamera 1
    mp_fraglimit 0
    mp_highlander 0
    mp_idledealmethod 0
    mp_idlemaxtime 0
    mp_respawnwavetime 10.0
    mp_match_end_at_timelimit 1
    mp_stalemate_enable 0
    mp_stalemate_timelimit 0
    mp_teams_unbalance_limit 0
    mp_teamplay 0
    mp_time_between_capscoring 30
    mp_tournament_allow_non_admin_restart 0
    mp_weaponstay 0
    sv_allow_color_correction 0
    sv_allow_voice_from_file 0
    sv_allow_wait_command 0
    sv_allowdownload 1
    sv_allowupload 0
    sv_alltalk 0
    sv_cheats 0
    sv_client_cmdrate_difference 30
    sv_client_max_interp_ratio 1
    sv_client_min_interp_ratio 1
    sv_client_predict 1
    sv_consistency 1
    sv_gravity 800
    sv_minrate 20000
    sv_maxrate 60000
    sv_maxupdaterate 66
    sv_minupdaterate 40
    sv_maxcmdrate 66
    sv_mincmdrate 40
    sv_pausable 1
    sv_pure 2
    sv_pure_kick_clients 1
    sv_rcon_log 1
    sv_showladders 0
    sv_specaccelerate 5
    sv_specnoclip 1
    sv_specspeed 3
    sv_turbophysics 1
    tf_allow_player_use 0
    tf_arena_first_blood 0
    tf_clamp_airducks 1
    tf_tournament_hide_domination_icons 1
    tf_use_fixed_weaponspreads 1
    tf_teamtalk 1
    tf_damage_disablespread 1
    tf_weapon_criticals 0

## [itemtest.cfg](/files/tf2configs/itemtest.cfg)
    // Disable respawn times completely
    sv_cheats 1
    mp_respawnwavetime 0
    mp_disable_respawn_times 1
    spec_freeze_time 0

## [mtp.cfg](/files/tf2configs/mtp.cfg)
    "VisionFilterShadersMapWhitelist"
    {
    }

## [scout.cfg](/files/tf2configs/scout.cfg)
    exec default

## [demoman.cfg](/files/tf2configs/demoman.cfg)
    exec default

## [medic.cfg](/files/tf2configs/medic.cfg)
    exec default

## [heavyweapons.cfg](/files/tf2configs/heavyweapons.cfg)
    exec default

## [sniper.cfg](/files/tf2configs/sniper.cfg)
    exec default
    cl_autorezoom 0

