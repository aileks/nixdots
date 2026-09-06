/* Exercise the parser from the fully patched terminal, without an X server. */
#include <assert.h>
#include "st.c"

unsigned int defaultfg = 7;
unsigned int defaultbg = 0;

static int failures;

static void
sgr(const char *sequence)
{
	csireset();
	csiescseq.len = strlen(sequence);
	assert(csiescseq.len < sizeof(csiescseq.buf));
	memcpy(csiescseq.buf, sequence, csiescseq.len);
	csiparse();
	assert(csiescseq.mode[0] == 'm');
	tsetattr(csiescseq.arg, csiescseq.narg);
}

static void
check(int condition, const char *sequence, const char *message)
{
	if (!condition) {
		fprintf(stderr, "FAIL %s: %s\n", sequence, message);
		failures++;
	}
}

int
main(void)
{
	const char *rgb[] = {
		"4;58:2:225:122:63m",
		"4;58:2::225:122:63m",
		"4;58:2:0:225:122:63m",
		"4;58;2;225;122;63m",
	};
	const char *indexed[] = { "4;58:5:123m", "4;58;5;123m" };
	const char *invalid[] = {
		"58:2:256:2:3m", "58;2;256;2;3m",
		"58:2:1:2m", "58;2;1;2m", "58m", "58;2m",
		"58:5:256m", "58;5;256m", "58:5:-1m",
		"58:2::1::3m", "58:2:1:2:3:4:5:6m",
		"58:2:999999999999999999999:2:3m",
		"58:2:999999999999999999999:1:2:3m",
		"58:2:-1:1:2:3m", "58;99;2;1;3m",
	};
	const char *foreground[] = {
		"38;2;225;122;63m", "38:2:225:122:63m",
		"38:2::225:122:63m",
	};
	const char *background[] = {
		"48;2;225;122;63m", "48:2:225:122:63m",
		"48:2::225:122:63m",
	};
	size_t i;

	for (i = 0; i < LEN(rgb); i++) {
		sgr("0;38;2;10;20;30m");
		sgr(rgb[i]);
		check((term.c.attr.mode & ~ATTR_DIRTYUNDERLINE) == ATTR_UNDERLINE,
		      rgb[i], "underline color changed text attributes");
		check(term.c.attr.ucolor[0] == 225 && term.c.attr.ucolor[1] == 122 &&
		      term.c.attr.ucolor[2] == 63, rgb[i], "wrong underline RGB");
		check(term.c.attr.fg == TRUECOLOR(10, 20, 30), rgb[i], "changed foreground");
	}
	for (i = 0; i < LEN(indexed); i++) {
		sgr("0m");
		sgr(indexed[i]);
		check((term.c.attr.mode & ~ATTR_DIRTYUNDERLINE) == ATTR_UNDERLINE,
		      indexed[i], "indexed color changed text attributes");
		check(term.c.attr.ucolor[0] == 123 && term.c.attr.ucolor[1] == -1 &&
		      term.c.attr.ucolor[2] == -1, indexed[i], "wrong underline index");
	}
	for (i = 0; i < LEN(invalid); i++) {
		sgr("0m");
		sgr(invalid[i]);
		check((term.c.attr.mode & ~ATTR_DIRTYUNDERLINE) == 0,
		      invalid[i], "malformed color became a text attribute");
		check(term.c.attr.ucolor[0] == -1, invalid[i], "accepted invalid color");
	}
	for (i = 0; i < LEN(foreground); i++) {
		sgr("0m");
		sgr(foreground[i]);
		check(term.c.attr.fg == TRUECOLOR(225, 122, 63), foreground[i], "wrong foreground");
	}
	for (i = 0; i < LEN(background); i++) {
		sgr("0m");
		sgr(background[i]);
		check(term.c.attr.bg == TRUECOLOR(225, 122, 63), background[i], "wrong background");
	}
	sgr("0;38:5:123;48:5:234;4:3;58:2::225:122:63;1m");
	check(term.c.attr.fg == 123 && term.c.attr.bg == 234, "mixed SGR", "wrong indexed colors");
	check(term.c.attr.ustyle == 3 &&
	      (term.c.attr.mode & ~ATTR_DIRTYUNDERLINE) == (ATTR_UNDERLINE | ATTR_BOLD),
	      "mixed SGR", "lost style or trailing bold");
	sgr("4:0;59m");
	check(!(term.c.attr.mode & ATTR_UNDERLINE) && term.c.attr.ucolor[0] == -1,
	      "4:0;59m", "underline reset failed");
	sgr("0;2;4;58;2;225;122;63m");
	check(term.c.attr.mode & ATTR_FAINT, "intentional dim", "cleared intentional dim");
	sgr("22;24m");
	check(!(term.c.attr.mode & (ATTR_FAINT | ATTR_UNDERLINE)), "22;24m", "attribute reset failed");
	sgr("0;58;5;123;1m");
	check(term.c.attr.mode & ATTR_BOLD, "58;5;123;1m", "consumed trailing attribute");
	sgr("0m");
	check(term.c.attr.ucolor[0] == -1 && term.c.attr.ustyle == -1,
	      "0m", "full reset failed");
	if (failures)
		return 1;
	puts("st SGR parser checks passed");
	return 0;
}
