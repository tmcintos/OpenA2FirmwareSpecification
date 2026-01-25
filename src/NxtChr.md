### <a id="nxtchr-ffad"></a>NxtChr ($FFAD)

**Description:**

This routine plays a crucial role in parsing hexadecimal input from the Monitor's input buffer. It tests each character (starting from the offset in the Y register) to determine if it is an ASCII code for a hexadecimal digit (0-9, A-F). If a valid hexadecimal character is found, `NxtChr` preprocesses it (including converting lowercase to uppercase) and then calls the [Dig ($FF8A)](#dig-ff8a) routine to decode the ASCII value into its corresponding hexadecimal number, which is stored in [A2L/A2H](#a2l-a2h). `NxtChr` then continues to the next character in the buffer.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: The offset into the input buffer ($0200) for the character to test.
*   **Memory:**
    *   Input buffer ($0200): The start of the Monitor's input buffer.

**Output:**

*   **Registers:**
    *   A: Contains the ASCII character of the next non-hexadecimal digit encountered, or the current character if it was not a hexadecimal digit.
    *   X: Undefined.
    *   Y: The offset into the input buffer for the next character after the tested/decoded character.
    *   P: Undefined.
*   **Memory:**
    *   [A2L/A2H](#a2l-a2h) (addresses $3E-$3F): Stores the hexadecimal number decoded from the ASCII character (set by [Dig ($FF8A)](#dig-ff8a)).

**Side Effects:**

*   Processes characters from the Monitor's input buffer.
*   Converts lowercase hexadecimal ASCII to uppercase.
*   Calls [Dig ($FF8A)](#dig-ff8a) to decode hexadecimal digits.
*   Stores decoded hexadecimal numbers in [A2L/A2H](#a2l-a2h).
*   Updates the Y register to point to the next character in the input buffer.

**See also:**

*   [Dig ($FF8A)](#dig-ff8a)
*   [GetNum ($FFA7)](#getnum-ffa7)
*   [A2L/A2H](#a2l-a2h)