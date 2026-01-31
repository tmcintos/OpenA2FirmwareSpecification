### <a id="rdchar-fd35"></a>RdChar ($FD35)

**Description:**

Reads a keypress for Monitor input, with recognition of the Monitor escape character.

`RdChar` reads a key via [RdKey](#rdkey-fd0c). On systems that implement the Monitor escape sequences, if the key read is the escape character, `RdChar` transfers control to the Monitor’s escape handler, which reads the following character and performs the corresponding cursor/screen operation.

**Input:**

*   **Registers:** A/X/Y: Undefined.
*   **Memory:**
    *   [CH](#ch) (address $24): Cursor column (used indirectly by [RdKey](#rdkey-fd0c) / the configured input path).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Text line base (used indirectly by [RdKey](#rdkey-fd0c) / the configured input path).

**Output:**

*   **Registers:**
    *   A: Contains the ASCII code of the key pressed.
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags affected.
*   **Memory:** None.

**Side Effects:**

*   Calls (or transfers control through) [RdKey](#rdkey-fd0c).
*   On systems that implement the Monitor escape sequences, detects the escape character and transfers control to the escape handler.

**Notes:**

- `RdChar` itself reads only a single key; escape-sequence dispatch is performed by the escape handler it transfers to.
- The escape-sequence mapping itself is part of the Monitor user interface contract; see [Table: Escape sequences](#table-escape-sequences).

**See also:**

*   [RdKey](#rdkey-fd0c)
*   [KeyIn](#keyin-fd1b)
*   [Table: Escape sequences](#table-escape-sequences)