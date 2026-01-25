## <a id="zero-page-definitions"></a>Zero-Page Definitions

| Address | Label(s) | Description | Usage |
|---|---|---|---|
| $00 | LOC0 | I/O Vector Low Byte. | Used by PR#n routines for I/O port selection; part of autostart vector from disk. |
| $01 | LOC1 | I/O Vector High Byte. | Pair with LOC0 to form 16-bit I/O routing vector. |
| $20 | WNDLFT | Left edge of the text window. | Horizontal start of the active text display area. |
| $21 | WNDWDTH | Width of the text window. | Number of character columns in the active text display area. |
| $22 | WNDTOP | Top line of the text window. | Vertical start of the active text display area. |
| $23 | WNDBTM | Bottom line of the text window. | Vertical end of the active text display area. |
| $24 | CH | Current Horizontal Cursor Position. | Current column number of the text cursor within the window. |
| $25 | CV | Current Vertical Cursor Position. | Current row number of the text cursor within the window. |
| $26-$27 | GBASL/GBASH | Lo-Res Graphics Base Address. | 16-bit pointer to the start of a Lo-Res graphics display row. |
| $28-$29 | BASL/BASH | Text Screen Base Address. | 16-bit pointer to the start of a text display line. |
| $2A-$2B | A2L/A2H | General-purpose 16-bit Address/Value 2. | General-purpose 16-bit register for temporary storage, comparisons, or loop bounds. |
| $2C | H2 | HLine Rightmost Horizontal Position. | Used by the HLine routine to determine the rightmost horizontal position to plot. |
| $2E | V2 | VLine Bottommost Vertical Position. | Used by the VLine routine to determine the bottommost vertical position to plot. |
| $2F | LENGTH | Length/Amount for Operations. | Defines an increment amount (e.g., for PCAdj, it is 1 less than the actual increment). |
| $30 | COLOR | Current Lo-Res Graphics Color. | Stores the 4-bit color value ($00-$0F) for Lo-Res graphics plotting. |
| $31 | INVFLG | Inverse Text Flag. | Controls whether subsequent text output is displayed in normal or inverse video. |
| $32 | Monitor Mode Byte | Monitor's Internal Mode Flag. | Determines how the Monitor handles hexadecimal number input and other modes. |
| $33 | PROMPT | Prompt Character ASCII Code. | Stores the ASCII code (high bit set) for the command prompt character. |
| $36-$37 | CSWL/CSWH | Current Standard Output Hook. | Low ($36) and high ($37) bytes of a 16-bit pointer to the currently active standard output routine. |
| $38-$39 | KSWL/KSWH | Current Standard Input Hook. | Low ($38) and high ($39) bytes of a 16-bit pointer to the currently active standard input routine. |
| $3A-$3B | PCL/PCH | Program Counter Low/High. | Low ($3A) and high ($3B) bytes of the 6502 Program Counter; used by Monitor routines. |
| $3C-$3D | A1L/A1H | 16-bit Address/Value 1. | General-purpose 16-bit register, often used as a source address pointer. |
| $3E-$3F | A4L/A4H | 16-bit Address/Value 4. | General-purpose 16-bit register, often used as a destination address pointer. |
| $44 | MACSTAT | Machine Status/Temporary Storage. | Used for storing machine state information or temporary values (e.g., A register value before a BREAK). |
| $45 | A5H | Accumulator (A) Register copy. | Stores a copy of the 6502 Accumulator (A) register for preservation or restoration. |
| $46 | XREG | X Register copy. | Stores a copy of the 6502 X-index register for preservation or restoration. |
| $47 | YREG | Y Register copy. | Stores a copy of the 6502 Y-index register for preservation or restoration. |
| $48 | STATUS | Processor Status (P) Register copy. | Stores a copy of the 6502 Processor Status (P) register for preservation or restoration. |
| $49 | SPNT | Stack Pointer (S) Register copy. | Stores a copy of the 6502 Stack Pointer (S) register for preservation or restoration. |
| $4E-$4F | RNDL/RNDH | Random Number Low/High. | Low ($4E) and high ($4F) bytes of a 16-bit seed used for random number generation. |
