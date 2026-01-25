### <a id="getln0-fd6c"></a>GetLn0 ($FD6C)

**Description:**

This routine displays a prompt character, whose ASCII code is provided in the A register, by calling [COut](#cout-fded). After displaying the prompt, it implicitly transfers control to the [GetLn1](#getln1-fd6f) routine, which handles reading a line of text from the keyboard.

**Input:**

*   **Registers:**
    *   A: The ASCII code of the prompt character to be displayed.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): The 16-bit address of the currently active standard character output routine, used by [COut](#cout-fded).

**Output:**

*   **Registers:**
    *   A: Undefined (consumed by [COut](#cout-fded)).
    *   X: Undefined (will be modified by [GetLn1](#getln1-fd6f)).
    *   Y: Undefined (will be modified by [GetLn1](#getln1-fd6f)).
    *   P: Flags affected by [COut](#cout-fded).
*   **Memory:**
    *   Screen memory: Modified by displaying the prompt character.
    *   Memory locations modified by [GetLn1](#getln1-fd6f) (e.g., [INBUF](#inbuf), [CH](#ch), [CV](#cv)).

**Side Effects:**

*   Displays a character on the screen via [COut](#cout-fded).
*   Transfers control to [GetLn1](#getln1-fd6f).

**See also:**

*   [COut](#cout-fded)
*   [GetLn1](#getln1-fd6f)
*   [CSWL/CSWH](#cswl-cswh)