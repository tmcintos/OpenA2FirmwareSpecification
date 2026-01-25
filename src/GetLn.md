### <a id="getln-fd6a"></a>GetLn ($FD6A)

**Description:**

This routine is a standard input subroutine for reading entire lines of characters from the keyboard. It displays a prompt character (which must be set at [PROMPT](#prompt) ($33) by the calling program) and allows the user to input a line of text, which is stored in an internal buffer. The routine provides on-screen editing features before the line is finalized by a carriage return.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:**
    *   [PROMPT](#prompt) (address $33): The character to be used as the prompt.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Contains the length of the input line (0-255).
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Input buffer ($0200-$02FF): Contains the entered line of characters, terminated by a carriage return.

**Side Effects:**

*   Displays a prompt character.
*   Reads a line of input from the keyboard into the input buffer.
*   Provides on-screen editing features.

**See also:**

*   [GetLnZ ($FD67)](#getlnz-fd67)
*   [PROMPT](#prompt)
