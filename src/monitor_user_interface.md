## Monitor User Interface and Command Dispatcher

### Overview

The Apple II ROM includes a system monitor (accessed via `CALL -151` in Applesoft BASIC or by entering the Monitor from the cold start sequence). The Monitor provides a command-line interface for inspecting and manipulating memory, running code, and performing system diagnostics.

The Monitor command system uses a pair of lookup tables at fixed ROM addresses to dispatch commands:

- **ASCII Command Table (CHRTBL)** at `$FFCC` — Contains the ASCII character codes for each supported command
- **Routine Offset Table (SUBTBL)** at `$FFE3` — Contains the 16-bit offsets to the routine that handles each command

### Entry Points

The Monitor is entered through the following entry points:

#### [Mon](#mon-ff65) ($FF65)
Initialization routine that prepares the processor to enter the Monitor. Clears the decimal mode flag, activates the speaker, and transfers control to [MonZ](#monz-ff69).

#### [MonZ](#monz-ff69) ($FF69)
Primary entry point for the System Monitor. Displays the prompt (`*`), reads a command line from the user, and passes control to the Monitor's command-line parser.

#### [MonZ4](#monz4-ff70) ($FF70)
Alternative entry point that bypasses the initial prompt display and mode clearing, going directly to the command parser.

### Command Structure

The Monitor command system works as follows:

1. **User Input:** The user types a command character at the Monitor prompt (`*`)
2. **Command Lookup:** The [MonZ](#monz-ff69) routine reads the input via [GetLnZ](#getlnz-fd67)
3. **Table Scan:** The command character is searched in the ASCII Command Table at `$FFCC`
4. **Offset Retrieval:** If found, the matching index is used to look up the routine offset in the Offset Table at `$FFE3`
5. **Routine Execution:** The offset is used to calculate the routine address, and control is transferred to that routine

### Lookup Tables (Fixed Addresses)

#### ASCII Command Table ($FFCC)

This table contains the ASCII codes for each supported Monitor command. Typical commands include:

- `G` — Go (execute code at specified address)
- `L` — List (display hex dump of memory)
- `M` — Modify memory
- `R` — Run (resume execution)
- `S` — Substitute (replace memory contents)
- `X` — Examine registers
- `A` — Assemble (6502 assembly input)
- Others as implemented by the ROM variant

**Format:** Each entry is a single byte containing the ASCII code of the command character.

#### Routine Offset Table ($FFE3)

This table contains 16-bit offsets corresponding to the routine that handles each command. The index in this table matches the index found in the ASCII Command Table.

**Format:** Each entry is a 16-bit offset (low byte, then high byte).

**Fixed Location:** This table **must** remain at `$FFE3` for compatibility with external diagnostic tools and software that may reference this address directly.

### Monitor Commands (Examples)

The following are typical commands found in Apple II ROMs (exact set varies by variant):

| Command | ASCII | Function |
|---------|-------|----------|
| G | $47 | **Go** — Execute code at specified address |
| L | $4C | **List** — Display hex dump of memory range |
| M | $4D | **Modify** — Change memory contents |
| R | $52 | **Run** — Resume execution from [PCL/PCH](#pcl-pch) |
| S | $53 | **Substitute** — Replace memory values |
| X | $58 | **Examine** — Display saved CPU registers |
| A | $41 | **Assemble** — Enter 6502 assembly instructions |
| T | $54 | **Trace** — Execute single instruction with display |
| . | $2E | **Full-stop** — Return to prompt (stop tracing) |

### <a id="escape-sequences-control-characters"></a>Escape Sequences and Control Characters

The Monitor supports escape sequences for advanced display and input control. These are sequences that begin with the &nbsp;␛⃣&nbsp; character (ASCII $1B) followed by a command character. &nbsp;⌃⃣&nbsp; indicates a control character.

### <a id="escape-sequences-with-rdchar"></a>Table: Escape sequences

| Escape Sequence           | Function                                                     |
| :---------------------- | :----------------------------------------------------------- |
| ␛⃣ , @⃣                   | Clears the current window, homes the cursor (moves it to the upper-left corner of the screen), and exits escape mode. |
| ␛⃣ , A⃣ or ␛⃣ , a⃣       | Moves the cursor right one character position and exits escape mode. |
| ␛⃣ , B⃣ or ␛⃣ , b⃣       | Moves the cursor left one character position and exits escape mode. |
| ␛⃣ , C⃣ or ␛⃣ , c⃣       | Moves the cursor down one line and exits escape mode.        |
| ␛⃣ , D⃣ or ␛⃣ , d⃣       | Moves the cursor up one line and exits escape mode.          |
| ␛⃣ , E⃣ or ␛⃣ , e⃣       | Clears the current line from the cursor position to the end, then exits escape mode. |
| ␛⃣ , F⃣ or ␛⃣ , f⃣       | Clears the current window from the cursor position to the bottom, then exits escape mode. |
| ␛⃣ , I⃣ or ␛⃣ , i⃣ or ␛⃣ , ↑⃣ | Moves the cursor up one line and remains in escape mode.     |
| ␛⃣ , J⃣ or ␛⃣ , j⃣ or ␛⃣ , ←⃣ | Moves the cursor left one character position and remains in escape mode. |
| ␛⃣ , K⃣ or ␛⃣ , k⃣ or ␛⃣ , →⃣ | Moves the cursor right one character position and remains in escape mode. |
| ␛⃣ , M⃣ or ␛⃣ , m⃣ or ␛⃣ , ↓⃣ | Moves the cursor down one line and remains in escape mode.   |
| ␛⃣ , 4⃣                  | Switches to 40-column text mode, sets the input/output links to `C3KeyIn` and `C3COut1`, restores the normal window size and then exits escape mode. |
| ␛⃣ , 8⃣                  | Switches to 80-column text mode, sets the input/output links to `C3KeyIn` and `C3COut1`, restores the normal window size and then exits escape mode. |
| ␛⃣ , ⌃⃣ - D⃣            | Disables control characters, allowing only carriage return, linefeed, bell, and backspace to have an effect when printed. |
| ␛⃣ , ⌃⃣ - E⃣            | Reactivates control characters.                              |
| ␛⃣ , ⌃⃣ - Q⃣            | Deactivates the enhanced video firmware, sets the input/output links to `KeyIn` and `COut1`, restores the normal window size and then exits escape mode. |

*Note: The commands ␛⃣ 4⃣, ␛⃣ 8⃣, and ␛⃣ ⌃⃣ - Q⃣ only function when enhanced video firmware is active.*

### Implementation Requirements for Clean-Room ROM

To implement a Monitor-compatible ROM:

1. **Fixed Table Locations:** The ASCII Command Table MUST be at `$FFCC` and the Routine Offset Table MUST be at `$FFE3`. This is essential for external diagnostic tools that may have these addresses hard-coded.

2. **Entry Point Availability:** The routines [Mon](#mon-ff65), [MonZ](#monz-ff69), and [MonZ4](#monz4-ff70) must be available at their documented addresses.

3. **Command Dispatch Mechanism:** A command dispatcher (typically similar to [TOSUB](#tosub-ffbe)) must use the pair of tables to route command characters to their handler routines.

4. **Register Preservation:** The Monitor should preserve CPU registers and provide mechanisms to inspect and modify them via the appropriate commands (typically the `X` command for examine).

5. **Memory Interaction:** The Monitor must provide access to all addressable memory via commands like `L` (list) and `M` (modify) or `S` (substitute).

### Related Routines

- [TOSUB](#tosub-ffbe) — Generic subroutine dispatcher using table lookup
- [GetLnZ](#getlnz-fd67) — Reads a line from user input (used by Monitor)
- [MonZ4](#monz4-ff70) — Alternative Monitor entry point
- [INPRT](#inprt-fe8d), [OUTPRT](#outport-fe95) — I/O port configuration for Monitor I/O

### Notes

- The Monitor is a critical system component and its command structure is relied upon by external diagnostic tools.
- The fixed table locations at `$FFCC` and `$FFE3` are essential for ROM compatibility.
- Different Apple II variants (II, II+, IIe, IIc) may have different sets of commands implemented, but the table structure remains consistent.

### See also

- [Mon](#mon-ff65) — Monitor initialization
- [MonZ](#monz-ff69) — Monitor entry point
- [SUBTBL](#subtbl-ffe3) — Routine offset table documentation
- [CHRTBL](#chrtbl-ffcc) — ASCII command table documentation
- [TOSUB](#tosub-ffbe) — Command dispatcher
- [INBUF](#inbuf) — Input buffer
