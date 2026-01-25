### <a id="bell-ff3a"></a>Bell ($FF3A)

**Description:**

This routine transmits an ASCII bell character (`$87`) to the standard output by loading the character into the A register and jumping to [COut](#cout-fded), which handles the actual output operation. This typically generates an audible tone when the output device supports bell character handling.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the bell character `$87`
    *   X: Preserved (by COut)
    *   Y: Preserved (by COut)
    *   P: Flags affected by output operations
*   **Memory:** None.

**Side Effects:**

*   Calls [COut](#cout-fded) to output the bell character.
*   Generates an audible tone (or other bell response depending on output device).

**See also:**

*   [Bell1](#bell1-fbdd)
*   [Bell1_2](#bell1-2-fbe2)
*   [Bell2](#bell2-fbe4)
