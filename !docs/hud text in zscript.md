## Classes:HUDFont
Jump to navigation
Jump to search
	Note: This feature is for ZScript only.


HUDFont is an internal class in ZScript, for use in ZScript status bars.

This class is used in text-drawing functions (such as DrawString) as the font to use when drawing text. It also controls how the text is displayed, such as spacing and shadows.
Contents

    1 Members
    2 Methods
        2.1 Static
    3 Example
    4 See also

Members

    Font mFont

    The Font struct object that the HUDFont is using for drawing text.

Methods
Static

    static HUDFont Create(Font fnt, int spacing = 0, EMonospacing monospacing = Mono_Off, int shadowx = 0, int shadowy = 0)

        Font fnt

        The font to use. This is a Font object that can be found with Font.FindFont("<your font name>").

        int spacing

        The amount of spacing between letters that will be displayed. A spacing of 0 would draw all the characters on top of each other, otherwise this controls the spacing added on to the width of the character.
        If the monospaced arguement is not Mono_Off, this argument must be specified. This can be done by calling myfont.GetCharWidth("0") ("0" is used here as it's usually the widest, but other characters can be used too), where myfont is the same Font object that is passed to the fnt argument.

        EMonospacing monospaced

        Controls whether the font is monospaced, or uses the width of each character as spacing. Possible values:

            Mono_Off — not monospaced (default)
            Mono_CellLeft — monospaced, characters placed at the left side of the cell
            Mono_CellCenter — monospaced, characters placed at the center of the cell
            Mono_CellRight — monospaced, characters placed at the right side of the cell

        int shadowx

        Controls how far to the right drawn texts' shadows are drawn, in pixels. Negative values will position the shadow to the left.

        int shadowy

        Controls how far down the drawn texts' shadows are drawn, in pixels. Negative values will position the shadow upwards.

Example

In this example, 3 strings will be drawn to the screen, each in a different fashion.

class MyStatusBar : BaseStatusBar 
{
	HUDFont noMonospaceSmallfont;
	HUDFont monospaceSmallfont;
	HUDFont shadowSmallfont;
	
	override void Init() 
	{
		Super.Init();
		SetSize(32, 320, 200);
		
		// smallfont is a built in Font object in ZScript - if you have your own font
		// and want to use that instead, you should initialize it like this:
		// Font myFont = "<FONT NAME>";
		
		// this font will not be monospaced when drawn
		noMonospaceSmallfont = HUDFont.Create(smallfont);
		// this font will be monospaced when drawn,
		// and each character will be spaced based on the width of the "0" character
		monospaceSmallfont = HUDFont.Create(smallfont, smallfont.GetCharWidth("0"), Mono_CellLeft);
		// this font will not be monospaced, but will cast a shadow 8 pixels to the right and 8 pixels to the left
		shadowSmallfont = HUDFont.Create(smallfont, 0, Mono_Off, 8, 8);
	}
	
	override void Draw (int state, double TicFrac)
	{
		Super.Draw (state, TicFrac);
		
		if (state == HUD_StatusBar)
		{
			BeginStatusBar();
			DrawMainBar();
		}
		else if (state == HUD_Fullscreen)
		{
			BeginHUD();
			DrawFullScreenStuff();
		}
	}
	
	void DrawMainBar()
	{
		DrawSomeText();
	}
	
	void DrawFullScreenStuff()
	{
		DrawSomeText();
	}
	
	void DrawSomeText()
	{
		// get the height of the font (we could get the height of any of the 3 HUDFonts we defined,
		// but they all use the same font internally so it shouldn't matter)
		// this is used to position each string below the last one
		int fontHeight = noMonospaceSmallfont.mFont.GetHeight();
		
		// this string will have no monospacing - the "I" will be far skinnier than other characters.
		DrawString(noMonospaceSmallfont, "TEXT DISPLAY", (0, 0 * fontHeight));
		// this string will be monospaced - the "I" will be displayed very awkwardly
		DrawString(monospaceSmallfont, "TEXT DISPLAY", (0, 1 * fontHeight));
		// this string will have a shadow 8 pixels to the right and 8 pixels to the bottom
		DrawString(shadowSmallfont, "TEXT DISPLAY", (0, 2 * fontHeight));
	}
}



## DrawString (BaseStatusBar)
Jump to navigation
Jump to search

BaseStatusBar

void DrawString(HUDFont font, String string, Vector2 pos, int flags = 0, int translation = Font.CR_UNTRANSLATED, double Alpha = 1., int wrapwidth = -1, int linespacing = 4, Vector2 scale = (1, 1))
Usage

Can be used in a ZScript HUD to draw a text string on the screen.
Parameters

    HUDFont font

    A pointer to a previously created HUDFont.

    String string

    The text string to print. If you want to pass a reference from the LANGUAGE lump, pass StringTable.Localize("$LANGUAGECODE").

    Vector2 pos

    The position of the string on the screen. Note that the vertical alignment can't be modified in the function, and the text is always drawn downward from the specified pos.y.

    int flags

    Flags can be used to alter the starting position and the aligment of the string. Use | to combine multiple flags.
    The DI_SCREEN* flags will change the origin point of the coordinates where the element is drawn (essentially, moving where the (0, 0) point is located.

        DI_SCREEN_LEFT_TOP - The coordinates begin at the top left corner of the screen
        DI_SCREEN_CENTER_TOP - The coordinates begin at the top center of the screen
        DI_SCREEN_RIGHT_TOP - The coordinates begin at the top right corner of the screen
        DI_SCREEN_LEFT_CENTER - The coordinates begin at the center left side of the screen
        DI_SCREEN_CENTER - The coordinates begin at the center of the screen
        DI_SCREEN_RIGHT_CENTER - The coordinates begin at the center right side of the screen
        DI_SCREEN_LEFT_BOTTOM - The coordinates begin at the bottom left corner of the screen
        DI_SCREEN_CENTER_BOTTOM - The coordinates begin at the bottom center of the screen
        DI_SCREEN_RIGHT_BOTTOM - The coordinates begin at the bottom right corner of the screen

    Note, these flags do not change the orientation of coordinates. Regardless of where the element is drawn, positive X moves it to the right, positive Y moves it down.
    More flags are defined in the StatusBarCore class, but they're mostly aliases of the above ones.
    The DI_TEXT* flags change the alignment of the string relative to the starting position:

        DI_TEXT_ALIGN_LEFT - Left alignment (default)
        DI_TEXT_ALIGN_CENTER - Center aligment
        DI_TEXT_ALIGN_RIGHT - Right alignment

    int translation

    Allows applying a color translation to the whole string. Colors are defined in the Font struct.
    If translation is specified but the string also uses color escape codes (like \cW), the codes will take priority. However, the specified translation will still apply to the parts of the string that are not colorized with the code (note, the \c- instruction can be used to remove previously set color; the text following this instruction will use the translation as specified by this argument).

    double Alpha

    Opacity of the string.

    int wrapwidth

    The width in pixels at which the string should wrap to the next line.

    int linespacing

    Spacing between the lines of a multi-line text.

    Vector2 scale

    Scale of the text.

Examples

Prints the text "A quick brown fox" using SMALLFONT in gold at the center of the screen:

HUDFont hfnt = HUDFont.Create(smallfont); //smallfont is a constant which can be used directly
DrawString(hfnt, "A quick brown fox", (0, 0), DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER, Font.CR_Gold);


Prints "A quick brown fox jumps over the lazy dog" using BigUpper font in green at the top left corner of the screen, with the maximum line width of 200 (which splits it into 3 lines using the standard 320x200 HUD resolution):

Font fnt = "BigUpper";
HUDFont hfnt = HUDFont.Create(fnt);
DrawString(hfnt, "A quick brown fox jumps over the lazy dog", (0, 0), DI_SCREEN_LEFT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_Green, wrapwidth: 200);


Prints the text "Health: AAA/BBB" in CONFONT centered exactly around the point 32 units below the center of the screen, where AAA is the current health value, and BBB is the maximum health value. The AAA part will be colorized in either green, yellow, orange or red depending on how much health the player has compared to their max health, while the rest of the string will be colored in green (thanks to the use of the \cC code):

Font fnt = "Confont";
HUDFont hfnt = HUDFont.Create(fnt);
int health = CPlayer.health;
int maxHealth = CPlayer.mo.GetMaxHealth(true);
// Modify color based on the ratio of health to maxhealth:
int col;
if (health >= maxhealth * 0.8)
	col = Font.CR_Green;
else if (health >= maxhealth * 0.5)
	col = Font.CR_Yellow;
else if (health >= maxhealth * 0.25)
	col = Font.CR_Orange;
else
	col = Font.CR_Red;
// Note that the first %d is escaled with \c- which allows the translation col to be applied to it,
// while the rest of the string is explicitly colorized with \cC:
DrawString(hfnt, String.Format("\cCHealth: \c-%d\cC/%d", health, maxhealth), (0, 32 - fnt.GetHeight() * 0.5), DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER, col);

See also

    Classes:BaseStatusBar
    Classes:HUDFont
    Structs:Font
	
	
===

# An idea how to actually implement it as an additive element instead of replacing the hud by accident: (PREFER THIS)

  override
  void renderOverlay(RenderEvent event)
  {
    if (!mIsInitialized || players[consolePlayer].mo == NULL) return;

    uint queueSize = mQueue.size();
    if (queueSize == 0) return;

    Array<string> lines;
    double scale = mOptions.getScale();
    int longestRemainingLife = 0;

    int maxLife = 35 * mOptions.getLifetime();

    for (uint i = 0; i < queueSize; ++i)
    {
      let item = mQueue[i];

      int change = item.newValue - item.oldValue;
      string maybePlus = change > 0 ? "\cd+" : "\cg";
      lines.push(string.format("\cj%s %s%d\cj → \c-%d", item.name, maybePlus, change, item.newValue));

      longestRemainingLife = max(longestRemainingLife, maxLife - (level.time - mQueue[i].startTime));
    }

    int textWidth = 0;
    for (uint i = 0; i < queueSize; ++i)
    {
      textWidth = max(textWidth, NewSmallFont.stringWidth(lines[i]));
    }
    textWidth = int((textWidth + 1) * scale);

    int lineHeight = int(NewSmallFont.getHeight() * scale);
    int textHeight = lineHeight * queueSize;

    int screenWidth = Screen.getWidth();
    int screenHeight = Screen.getHeight();
    int alignment = mOptions.getAlignment();
    int baseX = makeBaseX(int(mOptions.getX() * screenWidth), textWidth, alignment);
    baseX = clamp(baseX, 0, screenWidth - textWidth - BORDER * 2);
    double y = min(mOptions.getY() * screenHeight, screenHeight - textHeight);

    int fadeTime = maxLife / 3;
    double dimAlpha = longestRemainingLife > fadeTime ? 1.0 : double(longestRemainingLife) / fadeTime;
    Screen.Dim( mOptions.getBackgroundColor()
              , 0.5 * dimAlpha * mOptions.getOpacity()
              , baseX
              , int(y)
              , textWidth + BORDER * 2
              , textHeight
              );

    for (uint i = 0; i < queueSize; ++i)
    {
      int remainingLife = maxLife - (level.time - mQueue[i].startTime);
      double alpha = remainingLife > fadeTime ? 1.0 : double(remainingLife) / fadeTime;
      int textX = makeTextX(baseX, lines[i], textWidth, alignment, scale);
      int max = mQueue[i].maxValue;
      int fontColor = (max > 0 && mQueue[i].newValue >= max) ? Font.CR_Cyan : Font.CR_White;
      Screen.drawText( NewSmallFont
                     , fontColor
                     , textX
                     , y
                     , lines[i]
                     , DTA_ScaleX , scale
                     , DTA_ScaleY , scale
                     , DTA_Alpha  , alpha * mOptions.getOpacity()
                     );
      y += lineHeight;
    }
  }

NOTE: This method would also need a mod options CVAR thing to let user scale the size of the text between 0.0 to 10.0.