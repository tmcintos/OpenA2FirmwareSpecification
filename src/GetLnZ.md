### <a id="getlnz-fd67"></a>GetLnZ ($FD67)

**Description:**

This is the primary routine for reading a complete line of keyboard input. It begins by calling [CROut](#crout-fd8e) to output a carriage return. Subsequently, it displays a prompt character (if A is not N/A), and then repeatedly calls [RdKey](#rdkey-fd0c) (with escape mode) to get characters, storing them in [INBUF](#inbuf). It supports editing features such as:

*   Left Arrow (Control-H): Moves cursor left, places backspace (`$88`) in [INBUF](#inbuf).
*   Control-X or backspace to column 1: Calls [GetLnZ](#getlnz-fd67) for carriage return and restarts `GetLnZ`, discarding current input. Prints backslash if Control-X pressed.
*   Right Arrow (Control-U): Stores character at cursor position in [INBUF](#inbuf) instead of `$95`.

**Input:**

*   **Registers:**
    *   A: The ASCII code of the prompt character to be displayed. (If no prompt is desired, A should be N/A or a value that indicates no display).
    *   X: N/A (initialized internally, or by calling routines like [GetLn](#getln1-fd6f) or [GetLn1](#getln1-fd6f)).
    *   Y: N/A
*   **Memory:**
    *   [PROMPT](#prompt) (address $33): The ASCII character to use as a prompt.
    *   [INBUF](#inbuf) (address $0200-$02FF): The buffer where the input line is stored. Accessed for reading and writing during editing.
    *   [KSWL/KSWH](#kswl-kswh) (address $38-$39): Address of the current key-in routine, used by [RdKey](#rdkey-fd0c).
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): Address of the current character output routine, used by internal display functions.
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [CV](#cv) (address $25): Current vertical cursor position.
    *   [WNDLFT](#wndlft) (address $20): Left edge of the text window.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the text window.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current text page, used for screen memory access.
    *   [INVFLG](#invflg) (address $32): Inverse flag, checked for character display.
    *   [VFACTV](#vfactv) (address $067B): Video active flag, checked for video mode.
    *   Keyboard soft switches ($C000-$C0FF, specifically $C000 for KBST and $C010 for KBD).

**Output:**

*   **Registers:**
    *   A: Undefined (contains last character read or internal value).
    *   X: Contains the length of the input line read (number of characters in [INBUF](#inbuf)).
    *   Y: Undefined.
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [INBUF](#inbuf): Contains the complete line of user input.
    *   [CH](#ch): Updated to the final horizontal cursor position.
    *   [CV](#cv): Updated to the final vertical cursor position.
    *   Screen memory: Modified by displaying prompt, characters, and cursor movement.

**Side Effects:**

*   Calls [CROut](#crout-fd8e) to output a carriage return.
*   Displays a prompt character (if A is provided).
*   Reads keyboard input from soft switches.
*   Modifies [INBUF](#inbuf) with user input.
*   Updates cursor position ([CH](#ch), [CV](#cv)).
*   Performs screen memory writes for displaying characters.

**See also:**

*   [CROut](#crout-fd8e)
*   [RdKey](#rdkey-fd0c)
*   [RdChar](#rdchar-fd35)
*   [GetLn](#getln1-fd6f)
*   [GetLn1](#getln1-fd6f)
*   [INBUF](#inbuf)
*   [PROMPT](#prompt)
*   [CH](#ch)
*   [CV](#cv)
*   [KSWL/KSWH](#kswl-kswh)
*   [CSWL/CSWH](#cswl-cswh)
*   [WNDLFT](#wndlft)
*   [WNDWDTH](#wndwdth)
*   [BASL/BASH](#basl-bash)
*   [INVFLG](#invflg)
*   [VFACTV](#vfactv)