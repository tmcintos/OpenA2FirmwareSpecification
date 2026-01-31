### <a id="subtbl-ffe3"></a>SUBTBL ($FFE3)

**Description:**

This is the **Monitor dispatch table** used by the Monitor command dispatcher. It contains one byte per Monitor command character listed in the paired ASCII Command Table ([CHRTBL](#chrtbl-ffcc) at $FFCC). When a user enters a Monitor command, the character is looked up in CHRTBL to find its index, then that same index is used to retrieve the corresponding dispatch byte from SUBTBL; the dispatcher (typically [TOSUB](#tosub-ffbe)) uses that byte to transfer control to the matching command handler.

This table is commonly located at a fixed address (`$FFE3`) for compatibility with historical tooling and to maintain consistent command dispatch behavior across systems.

**Structure:**

The table consists of single-byte dispatch values. In common Monitor implementations, these values are used as low-order return-address bytes for an RTS-based dispatcher (see [TOSUB](#tosub-ffbe)).

**Compatibility note (address):** Many systems place this table at `$FFE3`, but some IIc-family implementations place it at `$FFE0`. For maximum compatibility with historical tooling, a unified firmware should prefer placing the dispatch table at `$FFE3`.

**Input:** N/A (this is a data table, not a routine).

**Output:** N/A

**Side Effects:** N/A

**See also:**

*   [CHRTBL](#chrtbl-ffcc) — ASCII Command Table at $FFCC (paired with SUBTBL)
*   [MonZ](#monz-ff69) — Monitor entry point that uses these tables
*   [TOSUB](#tosub-ffbe) — Generic subroutine dispatcher
*   [monitor_user_interface](#monitor-user-interface) — Documentation of Monitor command structure