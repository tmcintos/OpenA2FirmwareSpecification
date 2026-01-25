### <a id="subtbl-ffe3"></a>SUBTBL ($FFE3)

**Description:**

This is the **Monitor Routine Offset Table** used by the Monitor command dispatcher. It contains a series of 16-bit offsets corresponding to each command character in the ASCII Command Table ([CHRTBL](#chrtbl-ffcc) at $FFCC). When a user enters a Monitor command, the character is looked up in CHRTBL to find its index, then that same index is used to retrieve the corresponding offset from SUBTBL, which is used to dispatch to the appropriate handler routine.

This table is located at a fixed address ($FFE3) to ensure compatibility with external diagnostic tools and to maintain consistent command dispatch behavior across Apple II ROM variants.

**Structure:**

The table consists of 16-bit offset values (low byte, then high byte). Each offset corresponds to a routine that handles the associated command from CHRTBL.

**Fixed Address:** This table **must** remain at `$FFE3` for compatibility with external diagnostic tools and software that may reference this address directly.

**Input:** N/A (this is a data table, not a routine).

**Output:** N/A

**Side Effects:** N/A

**See also:**

*   [CHRTBL](#chrtbl-ffcc) — ASCII Command Table at $FFCC (paired with SUBTBL)
*   [MonZ](#monz-ff69) — Monitor entry point that uses these tables
*   [TOSUB](#tosub-ffbe) — Generic subroutine dispatcher
*   [monitor_user_interface](#monitor-user-interface) — Documentation of Monitor command structure