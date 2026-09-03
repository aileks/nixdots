/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 3;        /* horiz inner gap between windows */
static const unsigned int gappiv    = 3;        /* vert inner gap between windows */
static const unsigned int gappoh    = 6;        /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 6;        /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 3;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int vertpad            = 0;        /* vertical padding of bar */
static const int sidepad            = 4;        /* horizontal padding of bar */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const char *fonts[]          = { "Iosevka Nerd Font:size=10" };

/* cinder grove palette */
static const char col_fg[]      = "#BBB3A9";
static const char col_bg[]      = "#131210";
static const char col_bright[]  = "#DDD5CA";
static const char col_gray[]    = "#58534C";
static const char col_accent[]  = "#D9A441";
static const char col_border[]  = "#E17A3F";
static const char col_red[]     = "#B34A45";
static const char col_green[]   = "#879B5C";

static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_fg,    col_bg,    col_border },
	[SchemeSel]  = { col_bg,    col_accent, col_border },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class                   instance  title  tags mask  isfloating  isfullscreen  isterminal  noswallow  monitor */
	{ "kitty",                NULL,     NULL,  0,         0,          0,             1,          0,         -1 },
	{ "xdg-desktop-portal-gtk", NULL,   NULL,  0,         1,          0,             0,          0,         -1 },
	{ "org.gnome.DiskUtility", NULL,    NULL,  0,         1,          0,             0,          0,         -1 },
	{ "qalculate-gtk",        NULL,     NULL,  0,         1,          0,             0,          0,         -1 },
};

/* layout(s) */
static const float mfact     = 0.5;  /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int attachbelow  = 1;   /* 1 means attach after the currently active window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"
#include "movestack.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define STATUSBAR "dwmblocks"

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *termcmd[]  = { "kitty", NULL };
static const char *browsercmd[] = { "zen-browser-twilight", NULL };
static const char *filescmd[]   = { "nautilus", "--new-window", NULL };
static const char *signalcmd[]  = { "signal-desktop", NULL };
static const char *mailcmd[]    = { "fastmail", NULL };
static const char *lockcmd[]    = { "loginctl", "lock-session", NULL };
static const char *shotcmd[]    = { "flameshot", "gui", NULL };

static const char *volupcmd[]   = { "sh", "-c", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+; pkill -RTMIN+10 dwmblocks", NULL };
static const char *voldowncmd[] = { "sh", "-c", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-; pkill -RTMIN+10 dwmblocks", NULL };
static const char *volmutecmd[] = { "sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; pkill -RTMIN+10 dwmblocks", NULL };
static const char *micmutecmd[] = { "sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; pkill -RTMIN+10 dwmblocks", NULL };
static const char *brightupcmd[]   = { "sh", "-c", "ddcutil setvcp 10 + 10", NULL };
static const char *brightdowncmd[] = { "sh", "-c", "ddcutil setvcp 10 - 10", NULL };

#include <X11/XF86keysym.h>
static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_space,  spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_w,      spawn,          {.v = browsercmd } },
	{ MODKEY,                       XK_e,      spawn,          {.v = filescmd } },
	{ MODKEY,                       XK_s,      spawn,          {.v = signalcmd } },
	{ MODKEY,                       XK_m,      spawn,          {.v = mailcmd } },
	{ MODKEY,                       XK_Escape, spawn,          {.v = lockcmd } },
	{ 0,                            XK_Print,  spawn,          {.v = shotcmd } },
	{ MODKEY,                       XK_Print,  spawn,          SHCMD("gpu-screen-recorder -w screen -f 60 -a default_output -o \"$HOME/Videos/rec-$(date +%Y%m%d-%H%M%S).mkv\"") },
	{ MODKEY|ShiftMask,             XK_Print,  spawn,          SHCMD("pkill --signal SIGINT gpu-screen-recorder") },
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_f,      togglefullscr,  {0} },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_j,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,      movestack,      {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05 } },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_i,      incnmaster,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY|ShiftMask,             XK_f,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY|ControlMask,           XK_g,      togglegaps,     {0} },
	{ MODKEY|ControlMask|ShiftMask, XK_g,      defaultgaps,    {0} },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	{ 0,                            XF86XK_AudioRaiseVolume, spawn, {.v = volupcmd } },
	{ 0,                            XF86XK_AudioLowerVolume, spawn, {.v = voldowncmd } },
	{ 0,                            XF86XK_AudioMute,        spawn, {.v = volmutecmd } },
	{ 0,                            XF86XK_AudioMicMute,     spawn, {.v = micmutecmd } },
	{ 0,                            XF86XK_AudioPlay,        spawn,          SHCMD("playerctl play-pause") },
	{ 0,                            XF86XK_AudioPause,       spawn,          SHCMD("playerctl play-pause") },
	{ 0,                            XF86XK_AudioNext,        spawn,          SHCMD("playerctl next") },
	{ 0,                            XF86XK_AudioPrev,        spawn,          SHCMD("playerctl previous") },
	{ 0,                            XF86XK_MonBrightnessUp,   spawn, {.v = brightupcmd } },
	{ 0,                            XF86XK_MonBrightnessDown, spawn, {.v = brightdowncmd } },
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	{ MODKEY|ControlMask|ShiftMask, XK_q,      quit,           {1} },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
};

/* button definitions */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
	{ ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
	{ ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button4,        focusstack,     {.i = +1 } },
	{ ClkTagBar,            0,              Button5,        focusstack,     {.i = -1 } },
};
