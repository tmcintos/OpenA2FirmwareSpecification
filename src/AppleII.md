### <a id="appleii-fb60"></a>AppleII ($FB60)

**Description:**

This routine clears the text display and shows the machine's "Apple II" family identification string (e.g., "Apple //e", "Apple IIGS") on the first line. It operates only in text modes and will not function in graphics or mixed modes. Note that on earlier Apple II-family firmware, the code at this address (`$FB60`) served a different purpose (a multiplication routine often labeled `MULPM`) rather than the identification-string routine.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags affected
*   **Memory:**
    *   Text screen memory is modified to display the machine name.

**Side Effects:**

*   Modifies the text screen display.
*   Functionality depends on the display being in text mode.

**See also:**

*   [Home](#home-fc58)
*   [SetTxt](#settxt-fb39)
*   [Mon ($FF65)](#mon-ff65)
