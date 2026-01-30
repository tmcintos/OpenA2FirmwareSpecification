## <a id="summary-of-firmware-entry-points"></a>Summary of Firmware Entry Points

| Routine Name | Address | Function Summary |
|---|---|---|
| [A1PC](#a1pc-fe75) | $FE75 | Conditionally copy A1L/A1H to PCL/PCH (Internal helper). |
| [Advance](#advance-fbf4) | $FBF4 | Advances the text cursor's horizontal position. |
| [AppleII](#appleii-fb60) | $FB60 | Clears screen and displays machine ID. |
| [BasCalc](#bascalc-fbc1) | $FBC1 | Calculates 16-bit base address for text display line. |
| [Bell](#bell-ff3a) | $FF3A | Sends a bell character to standard output. |
| [Bell1](#bell1-fbdd) | $FBDD | Produces a brief 1 kHz tone through the system speaker with delay. |
| [Bell1_2](#bell1_2-fbe2) | $FBE2 | Produces a brief 1 kHz tone through the system speaker without delay. |
| [Bell2](#bell2-fbe4) | $FBE4 | Generates a square-wave tone by toggling the system speaker for a duration. |
| [Break](#break-fa4c) | $FA4C | Handles processor hardware break event, saves registers, and transfers control to user hook. |
| [BS](#bs-fc10) | $FC10 | Performs a backspace operation, decrements CH, and moves cursor up if at left edge. |
| [ClrCH](#clrch-fee9) | $FEE9 | Clear horizontal cursor positions (Internal helper). |
| [ClrEOL](#clreol-fc9c) | $FC9C | Clears a line of text from the cursor's current position to the right edge of the window. |
| [ClrEOLZ](#clreolz-fc9e) | $FC9E | Clears a line of text from a specified column to the right edge of the window. |
| [ClrEOP](#clreop-fc42) | $FC42 | Clears the text window from the current cursor position to the end of the window. |
| [ClrScr](#clrscr-f832) | $F832 | Clears the Lo-Res graphics display or fills the text screen with inverse '@'. |
| [ClrTop](#clrtop-f836) | $F836 | Clears the upper 40 lines of the Lo-Res graphics display to black. |
| [COut](#cout-fded) | $FDED | Primary entry point for standard character output, indirect calls to active output routine. |
| [COut1](#cout1-fdf0) | $FDF0 | Displays ASCII character at current cursor, advances cursor, handles control characters, applies inverse flag. |
| [COutZ](#coutz-fdf6) | $FDF6 | Alternative entry point to COut1; identical except it does not apply inverse mode at entry. |
| [CR](#cr-fc62) | $FC62 | Executes a carriage return, moving cursor to left edge and then calling LF. |
| [CROut](#crout-fd8e) | $FD8E | Initiates a carriage return by sending a CR character to standard output. |
| [CROut1](#crout1-fd8b) | $FD8B | Clears to end of line, then outputs a carriage return via the current standard output. |
| [Dig](#dig-ff8a) | $FF8A | Converts ASCII hexadecimal digit to 4-bit numerical value. |
| [FD10](#fd10-fd10) | $FD10 | Indirect jump for standard input, transfers control to routine in KSWL/KSWH. |
| [GBasCalc](#gbascalc-f847) | $F847 | Calculates 16-bit base address for a specified Lo-Res graphics display row. |
| [GetCur2](#getcur2-ccad) | $CCAD | Update zero-page horizontal cursor positions (Internal helper). |
| [GetLn](#getln-fd6a) | $FD6A | Reads a complete line of input from standard input, with editing features. |
| [GetLn0](#getln0-fd6c) | $FD6C | Outputs the prompt character in A, then reads a line of input (via GetLn1). |
| [GetLn1](#getln1-fd6f) | $FD6F | Alternate entry point to GetLn, reads line without displaying a prompt. |
| [GetLnZ](#getlnz-fd67) | $FD67 | Sends a carriage return, then transfers control to GetLn. |
| [GetNum](#getnum-ffa7) | $FFA7 | Scans Monitor's input buffer for hex digits, converts to numerical values. |
| [Go](#go-feb6) | $FEB6 | Restores A, X, Y, P registers from saved values and jumps to address in A1L/A1H. |
| [HeadR](#headr-fcc9) | $FCC9 | Obsolete entry point, simply returns. |
| [HLine](#hline-f819) | $F819 | Draws a horizontal line of blocks on the Lo-Res graphics display. |
| [Home](#home-fc58) | $FC58 | Clears the active text window and positions cursor at upper-left corner. |
| [HomeCur](#homecur-cda5) | $CDA5 | Move cursor to upper left corner of text window (Internal helper). |
| [IDRoutine](#idroutine-fe1f) | $FE1F | Immediate return from subroutine (Internal helper). |
| [Init](#init-fb2f) | $FB2F | Initializes text display to show text Page 1 and full-screen text window. |
| [InPort](#inport-fe8b) | $FE8B | Configures system's input links to a designated input port. |
| [InsDs1_2](#insds1_2-f88c) | $F88C | Loads A with an opcode then calls InsDs2 to calculate its length. |
| [InsDs2](#insds2-f88e) | $F88E | Determines length (minus 1) of 6502 instruction from opcode in A. |
| [InstDsp](#instdsp-f8d0) | $F8D0 | Disassembles and prints instruction pointed to by PCL/PCH to standard output. |
| [IORTS](#iorts-ff58) | $FF58 | Contains an RTS instruction, used by peripheral cards for slot identification. |
| [IRQ](#irq-fa40) | $FA40 | Jumps to interrupt-handling routine in ROM, saves state, checks interrupts, calls user hook. |
| [KbdWait](#kbdwait-fb88) | $FB88 | Pauses execution until a key is pressed; handles Control-C. |
| [KeyIn](#keyin-fd1b) | $FD1B | Manages standard keyboard input, displays cursor, waits for keypress, updates RNDL/RNDH. |
| [KeyIn0](#keyin0-fd18) | $FD18 | Alternate entry point for standard keyboard input, jumps to routine in KSWL/KSWH. |
| [LF](#lf-fc66) | $FC66 | Executes a line feed, increments CV, and scrolls window up if needed. |
| [List](#list-fe5e) | $FE5E | Disassembles and displays 20 6502 instructions to standard output. |
| [Mon](#mon-ff65) | $FF65 | Prepares processor to enter System Monitor, clears decimal flag, activates speaker. |
| [MonZ](#monz-ff69) | $FF69 | Primary entry point for System Monitor, displays prompt, reads input, clears mode flag. |
| [MonZ4](#monz4-ff70) | $FF70 | Alternative entry point to System Monitor, bypasses initial prompt and mode clearing. |
| [Move](#move-fe2c) | $FE2C | Copies a block of memory from source to destination. |
| [NewBrk](#newbrk-fa47) | $FA47 | Stores A in MACSTAT, pulls Y, X, A from stack, then transfers to Break. |
| [NewVTabZ](#newvtabz-fc88) | $FC88 | Update OURCV and transfer to VTABZ (Internal helper). |
| [NxtA1](#nxtal-fcba) | $FCBA | Performs a 16-bit comparison of A1L/A1H with A2L/A2H, then increments A1L/A1H. |
| [NxtA4](#nxta4-fcb4) | $FCB4 | Increments A4L/A4H, then calls NxtAl for comparison and A1L/A1H increment. |
| [NxtChr](#nxtchr-ffad) | $FFAD | Inspects input buffer for hex numbers, converts them, handles case. |
| [NxtCol](#nxtcol-f85f) | $F85F | Modifies current color for Lo-Res graphics plotting by adding 3. |
| [OldBrk](#oldbrk-fa59) | $FA59 | Prints saved PC and register values, then transfers control to the Monitor. |
| [OldRst](#oldrst-ff59) | $FF59 | Performs warm restart, initializes text screen, sets I/O hooks, enters Monitor. |
| [OutPort](#outport-fe95) | $FE95 | Sets output hooks to ROM code for specified port. |
| [PCAdj](#pcadj-f953) | $F953 | Reads Monitor's program counter, loads into A/Y, increments based on LENGTH. |
| [Plot](#plot-f800) | $F800 | Plots a single block of specified color on Lo-Res graphics display. |
| [Plot1](#plot1-f80e) | $F80E | Plots a single block of specified color on Lo-Res graphics display at current row. |
| [PrA1](#pra1-fd92) | $FD92 | Sends carriage return, prints A1L/A1H in hex, followed by a hyphen. |
| [PrBl2](#prbl2-f94a) | $F94A | Prints a number of blank spaces to standard output. |
| [PrBlnk](#prblnk-f948) | $F948 | Prints three blank spaces to standard output. |
| [PrByte](#prbyte-fdda) | $FDDA | Prints contents of A register in hexadecimal format. |
| [PRead](#pread-fb1e) | $FB1E | Returns dial position of hand control or mouse position. |
| [PRead4](#pread4-fb21) | $FB21 | Alternate entry point of PRead. |
| [PrErr](#prerr-ff2d) | $FF2D | Prints "ERR" and sends a bell character. |
| [PrHex](#prhex-fde3) | $FDE3 | Prints lower nibble of A register in hexadecimal format. |
| [PrntAX](#prntax-f941) | $F941 | Prints contents of A and X registers as a four-digit hex value. |
| [PrntX](#prntx-f944) | $F944 | Prints contents of X register as a two-digit hex value. |
| [PrntYX](#prntyx-f940) | $F940 | Prints contents of Y and X registers as a four-digit hex value. |
| [PwrUp](#pwrup-faa6) | $FAA6 | Completes cold start initialization, sets soft switches, initializes RAM, transfers control. |
| [RdChar](#rdchar-fd35) | $FD35 | Activates escape mode, then jumps to RdKey. |
| [RdKey](#rdkey-fd0c) | $FD0C | Loads A with character at current cursor, passes control to FD10. |
| [Read](#read-fefd) | $FEFD | Obsolete entry point, simply returns. |
| [RegDsp](#regdsp-fad7) | $FAD7 | Displays memory state and saved A, X, Y, P, S register contents. |
| [Reset](#reset-fa62) | $FA62 | Performs warm start initialization, checks for cold start, transfers control. |
| [Restore](#restore-ff3f) | $FF3F | Sets A, X, Y, P registers to stored values. |
| [Save](#save-ff4a) | $FF4A | Stores current A, X, Y, P, S registers, clears decimal mode flag. |
| [Scrn](#scrn-f871) | $F871 | Returns color value of a single block on Lo-Res graphics display. |
| [Scroll](#scroll-fc70) | $FC70 | Scrolls text window up by one line, updates BASL/BASH. |
| [SetCol](#setcol-f864) | $F864 | Set the color used for plotting in the Lo-Res graphics mode. |
| [SetGr](#setgr-fb40) | $FB40 | Sets display to mixed graphics, clears graphics screen, sets text window top. |
| [SetInv](#setinv-fe80) | $FE80 | Sets INVFLG to $3F for inverse text output. |
| [SetKbd](#setkbd-fe89) | $FE89 | Sets input links to point to keyboard input routine KeyIn. |
| [SetNorm](#setnorm-fe84) | $FE84 | Sets normal text output mode (clears inverse mode). |
| [SetPwrC](#setpwrc-fb6f) | $FB6F | Calculates Validity-Check byte for reset vector and stores it. |
| [SetTxt](#settxt-fb39) | $FB39 | Sets display to full-screen text window, updates BASL/BASH. |
| [SetVid](#setvid-fe93) | $FE93 | Sets output links to point to screen display routine COut1. |
| [SetWnd](#setwnd-fb4b) | $FB4B | Sets text window to full screen width, with top at specified line. |
| [StorAdv](#storadv-fbf0) | $FBF0 | Places printable character on text screen, advances cursor, handles carriage return. |
| [TabV](#tabv-fb5b) | $FB5B | Performs a vertical tab to the line specified in A, updates CV and BASL/BASH. |
| [Up](#up-fc1a) | $FC1A | Decrements CV value, moving cursor up one line, unless at top of window. |
| [Verify](#verify-fe36) | $FE36 | Compares contents of two memory ranges, reports mismatches. |
| [Version](#version-fbb3) | $FBB3 | ROM identification byte, not a callable routine (value is $06). |
| [VidOut](#vidout-fbfd) | $FBFD | Sends printable characters to StorAdv, handles control characters. |
| [VidWait](#vidwait-fb78) | $FB78 | Checks for carriage return, Control-S, handles output pausing and enhanced video. |
| [VLine](#vline-f828) | $F828 | Draws a vertical line of blocks on the Lo-Res graphics display. |
| [VTab](#vtab-fc22) | $FC22 | Performs vertical tab to line specified by CV, updates BASL/BASH. |
| [VTabZ](#vtabz-fc24) | $FC24 | Vertical tab to line specified in A register (Internal helper). |
| [Wait](#wait-fca8) | $FCA8 | Introduces a time delay determined by the value in A register. |
| [Write](#write-fecd) | $FECD | Obsolete entry point, simply returns. |
| [ZIDByte](#zidbyte-fbc0) | $FBC0 | ROM identification byte, not a callable routine ($00 for Apple IIc). |
| [ZIDByte2](#zidbyte2-fbbf) | $FBBF | ROM identification byte, not a callable routine (depends on Apple IIc version). |
| [ZMode](#zmode-ffc7) | $FFC7 | Stores $00 in Monitor’s Monitor Mode Byte to clear Monitor mode. |
