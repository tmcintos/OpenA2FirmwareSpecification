### <a id="zero-page-definitions"></a>Zero-Page Definitions

| Address | Label(s) | Description | Usage |
|---|---|---|---|
| $00 | <a id="loc0"></a>LOC0 | I/O Vector Low Byte. | Used by PR#n routines for I/O port selection; part of autostart vector from disk. |
| $01 | <a id="loc1"></a>LOC1 | I/O Vector High Byte. | Pair with LOC0 to form 16-bit I/O routing vector. |
| $20 | <a id="wndlft"></a>WNDLFT | Left edge of the text window. | Horizontal start of the active text display area. |
| $21 | <a id="wndwdth"></a>WNDWDTH | Width of the text window. | Number of character columns in the active text display area. |
| $22 | <a id="wndtop"></a>WNDTOP | Top line of the text window. | Vertical start of the active text display area. |
| $23 | <a id="wndbtm"></a>WNDBTM | Bottom line of the text window. | Vertical end of the active text display area. |
| $24 | <a id="ch"></a>CH | Current Horizontal Cursor Position. | Current column number of the text cursor within the window. |
| $25 | <a id="cv"></a>CV | Current Vertical Cursor Position. | Current row number of the text cursor within the window. |
| $26-$27 | <a id="gbasl-gbash"></a>GBASL/GBASH | Lo-Res Graphics Base Address. | 16-bit pointer to the start of a Lo-Res graphics display row. |
| $28-$29 | <a id="basl-bash"></a>BASL/BASH | Text Screen Base Address. | 16-bit pointer to the start of a text display line. |
| $2A-$2B | <a id="bas2l-bas2h"></a>BAS2L/BAS2H | Scroll destination base address (temporary). | Temporary 16-bit pointer used by text scrolling routines as the destination line address while copying screen rows upward; not a stable API and should not be assumed preserved across firmware routine calls. |
| $2C | <a id="h2"></a>H2 | HLine Rightmost Horizontal Position. | Used by the HLine routine to determine the rightmost horizontal position to plot. |
| $2D | <a id="v2"></a>V2 | VLine Bottommost Vertical Position. | Used by the VLine routine to determine the bottommost vertical position to plot. |
| $2F | <a id="length"></a>LENGTH | Length/Amount for Operations. | Defines an increment amount (e.g., for PCAdj, it is 1 less than the actual increment). |
| $30 | <a id="color"></a>COLOR | Current Lo-Res Graphics Color. | Stores the 4-bit color value ($00-$0F) for Lo-Res graphics plotting. |
| $31 | <a id="mode"></a>MODE | Monitor Mode Byte. | Tracks the current Monitor mode; used internally to control how command syntax and parsed hexadecimal values are interpreted. Implementations typically store the current mode token (often the parsed command delimiter/operator) rather than a separate numeric enumeration. |
| $32 | <a id="invflg"></a>INVFLG | Inverse Text Flag. | Controls whether subsequent text output is displayed in normal or inverse video. $3F = inverse, $FF = normal. |
| $33 | <a id="prompt"></a>PROMPT | Prompt Character ASCII Code. | Stores the ASCII code (high bit set) for the command prompt character. |
| $34 | <a id="ysav"></a>YSAV | Monitor Parser Index Save. | Saves the Monitor’s current input-buffer scan index (Y) so parsing can resume after dispatching a command handler. |
| $35 | <a id="ysav1"></a>YSAV1 | Temporary Y Register Save. | Temporary storage used by routines that need to preserve the 6502 Y register across internal calls. |
| $36-$37 | <a id="cswl-cswh"></a>CSWL/CSWH | Current Standard Output Hook. | Low ($36) and high ($37) bytes of a 16-bit pointer to the currently active standard output routine. |
| $38-$39 | <a id="kswl-kswh"></a>KSWL/KSWH | Current Standard Input Hook. | Low ($38) and high ($39) bytes of a 16-bit pointer to the currently active standard input routine. |
| $3A-$3B | <a id="pcl-pch"></a>PCL/PCH | Program Counter Low/High. | Low ($3A) and high ($3B) bytes of the 6502 Program Counter; used by Monitor routines. |
| $3C-$3D | <a id="a1l-a1h"></a>A1L/A1H | Monitor address pointer (A1). | 16-bit pointer used by Monitor commands as the current/"last opened" address (varies by command). |
| $3E-$3F | <a id="a2l-a2h"></a>A2L/A2H | Monitor address pointer (A2). | 16-bit pointer used by Monitor commands as an end address / limit address (varies by command). |
| $40-$41 | <a id="a3l-a3h"></a>A3L/A3H | Monitor address pointer (A3). | 16-bit pointer used internally by some Monitor routines (for example, as a destination pointer for multi-byte stores). |
| $42-$43 | <a id="a4l-a4h"></a>A4L/A4H | Monitor address pointer (A4). | 16-bit pointer used by Monitor commands as a destination address (for example, MOVE/VERIFY). |
| $44 | <a id="a5l"></a>A5L | Monitor temp / scratch (A5 low). | Low byte of a 16-bit Monitor temporary used by some Monitor routines. Also reused by some routines for other internal state. |
| $45 | <a id="a5h"></a>A5H | Accumulator (A) Register copy. | Stores a copy of the 6502 Accumulator (A) register for preservation or restoration; also serves as the high byte of the Monitor temporary `A5L/A5H`. |
| $46 | <a id="xreg"></a>XREG | X Register copy. | Stores a copy of the 6502 X-index register for preservation or restoration. |
| $47 | <a id="yreg"></a>YREG | Y Register copy. | Stores a copy of the 6502 Y-index register for preservation or restoration. |
| $48 | <a id="status"></a>STATUS | Processor Status (P) Register copy. | Stores a copy of the 6502 Processor Status (P) register for preservation or restoration. |
| $49 | <a id="spnt"></a>SPNT | Stack Pointer (S) Register copy. | Stores a copy of the 6502 Stack Pointer (S) register for preservation or restoration. |
| $4E-$4F | <a id="rndl-rndh"></a>RNDL/RNDH | Random Number Low/High. | Low ($4E) and high ($4F) bytes of a 16-bit seed used for random number generation. Updated by keyboard input routines to provide a changing seed value. |

#### <a id="random-seed-maintenance"></a>Maintaining the random seed (`RNDL/RNDH`)

The standard keyboard input routine [KeyIn](#keyin-fd1b) (and compatible input handlers) should update `RNDL/RNDH` as part of normal key-wait/key-read operation (for example, by repeatedly incrementing the 16-bit value while waiting for a keypress). Software (including BASIC) relies on this location changing over time to obtain a non-constant pseudo-random seed.

No specific update algorithm or reset-time initialization value is required by the contract; the requirement is simply that keyboard input causes `RNDL/RNDH` to change in a way that provides usable variability.

#### <a id="monitor-mode-values"></a>Monitor mode (`MODE`) values

`MODE` is a Monitor-internal state byte. Implementations commonly set it to `$00` for the default “normal/examine” state (see [ZMode](#zmode-ffc7)). When command syntax introduces an operator or delimiter that changes how subsequent input is interpreted (for example store mode or expression add/subtract), implementations commonly store a code corresponding to that parsed token.

**Implementation note:** In common Monitor implementations, [SetMode](#setmode-fe18) stores the parsed command character itself into `MODE` (rather than mapping it to a separate set of small integers). This makes the set of nonzero `MODE` values effectively tied to the command language.

