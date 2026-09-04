/* See LICENSE file for copyright and license details. */

static int fuzzy = 1; /* -F  option; if 0, dmenu doesn't use fuzzy matching */
static int topbar = 1;
#define OPAQUE 0xffU
static const unsigned int alpha = 0xee; /* Amount of opacity. 0xff is opaque */
static const unsigned int alphas[SchemeLast][2] = {
    [SchemeNorm] = {OPAQUE, alpha}, [SchemeSel] = {OPAQUE, alpha}};
static int centered = 1;    /* -c option; centers dmenu on screen */
static int min_width = 640; /* minimum width when centered */
static int max_width = 960; /* maximum width when centered */
static const float menu_height_ratio =
    4.0f; /* This is the ratio used in the original calculation */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {"Iosevka Custom:size=16",
                              "Symbols Nerd Font:size=14"};
static const char *prompt = "run";
static const char *colors[SchemeLast][2] = {
    /*     fg         bg       */
    [SchemeNorm] = {"#BBB3A9", "#131210"},
    [SchemeSel] = {"#131210", "#D9A441"},
    [SchemeNormHighlight] = {"#D9A441", "#131210"},
    [SchemeSelHighlight] = {"#131210", "#E17A3F"},
    [SchemeOut] = {"#131210", "#879B5C"},
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines = 8;
static unsigned int maxhist = 64;
static int histnodup = 1; /* if 0, record repeated histories */
/* -h option; minimum height of a menu line */
static unsigned int lineheight = 26;
static unsigned int min_lineheight = 8;

/* Size of the window border */
static unsigned int border_width = 2;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
