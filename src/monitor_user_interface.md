## <a id="monitor-user-interface"></a>Monitor User Interface and Command Dispatcher

### Overview

Apple II-family system firmware includes a system monitor (commonly entered from BASIC with `CALL -151`, which jumps to [MonZ](#monz-ff69) at `$FF69`). The Monitor provides a command-line interface for inspecting and manipulating memory, running code, and invoking firmware I/O subroutines.

Many standard firmware I/O entry points are used by system software (and may also be called directly by user programs) via their fixed entry addresses.

The Monitor command system uses a pair of lookup tables (commonly at fixed firmware addresses) to dispatch commands:

- **ASCII Command Table (CHRTBL)** at `$FFCC` — Contains the command character codes used by the Monitor command parser (typically ASCII with bit 7 set, matching keyboard input convention).
- **Dispatch Table (SUBTBL)** at `$FFE3` — Contains per-command dispatch bytes used by the `TOSUB` dispatcher (an RTS-based dispatch mechanism). The high byte is supplied by `TOSUB` (commonly the high byte of the `GO` routine’s address).

### Monitor Entry Points

The Monitor is entered through the following entry points:

#### [Mon](#mon-ff65) ($FF65)

Initialization routine that prepares the processor to enter the Monitor. Clears the decimal mode flag, activates the speaker, and transfers control to [MonZ](#monz-ff69).

#### [MonZ](#monz-ff69) ($FF69)

Primary entry point for the System Monitor. Displays the prompt (`*`), reads a command line from the user, and passes control to the Monitor's command-line parser.

#### [MonZ4](#monz4-ff70) ($FF70)

Alternative entry point that bypasses the initial prompt display and mode clearing, going directly to the command parser.

### Command Structure

When the Monitor is running, it displays its prompt character (`*`) at the left edge of the screen, followed by a cursor. The user then enters a command line and presses Return.

The Monitor accepts the line using the standard line-input routine [GetLn](#getln-fd6a) (typically reached via [GetLnZ](#getlnz-fd67)). A command line can be up to 255 characters long and is terminated by a carriage return.

A Monitor command line is made up of:

- **Addresses** (hexadecimal)
- **Data values** (hexadecimal)
- **Command characters** (letters, punctuation, and control characters)

#### Hexadecimal parsing rules

When parsing addresses and byte values from the input line:

- Address expressions with fewer than four hex digits are treated as if they had leading zeros.
- Address expressions with more than four hex digits use only the last four hex digits.
- When a byte value is expected, fewer than two digits are treated as if they had a leading zero; more than two digits use only the last two hex digits.

These behaviors are provided by the Monitor’s hex-scanning routines (notably [GetNum](#getnum-ffa7) working with [NxtChr](#nxtchr-ffad) / [Dig](#dig-ff8a)), which build values in a 16-bit accumulator.

#### Command characters and implicit operations

Note: While entering a command line, control characters are interpreted by the Monitor’s input/editor logic and are not normally echoed as printable glyphs.

A Monitor input line generally includes a command character (often the first character of the command name). Some operations are implied by syntax; for example, a line beginning with a hexadecimal address expression can request an examine/open operation without an explicit command letter.

#### Common command-line patterns

The Monitor command language is expression- and delimiter-driven, and many commands can be written without spaces. Common patterns include:

- **Implicit examine/open:** A line that begins with hexadecimal digits is treated as an address expression and sets the “current address” (commonly tracked via A1L/A1H). If the line ends at that point (CR), the Monitor examines the contents at that address and leaves the address “open” for subsequent examine/store operations.
- **Examine a range:** `start.end` (a period followed by an ending address) examines a range of memory locations (e.g., `300.30F`).
- **Store/edit memory:** `addr: ...` enters store mode at `addr` and consumes subsequent byte/word values from the same line.
- **Concatenation:** Delimiters like `.` and `:` allow multiple operations to be written in a single line without spaces when the syntax is unambiguous.

The exact command set (which command characters are recognized) is system- and firmware-revision dependent.

### Command Dispatch Tables (CHRTBL/SUBTBL)

The Monitor’s command dispatcher is table-driven:

- [CHRTBL](#chrtbl-ffcc) at `$FFCC` holds the command characters.
- [SUBTBL](#subtbl-ffe3) at `$FFE3` holds the corresponding dispatch entries.
- The dispatcher is typically implemented by [TOSUB](#tosub-ffbe).

The detailed data formats and dispatcher mechanics are documented in the linked entries above; this section focuses on the user-visible Monitor behavior and how the pieces fit together.

### Monitor parse loop overview

The Monitor reads a line into [INBUF](#inbuf) and then scans it left-to-right, repeatedly decoding a hexadecimal value and/or a command token.

- The current scan index is tracked in [YSAV](#ysav).
- Command tokens are dispatched through [CHRTBL](#chrtbl-ffcc)/[SUBTBL](#subtbl-ffe3) via [TOSUB](#tosub-ffbe).

Several small internal routines work together to keep this loop compact:

- [CRMon](#crmon-fef6) handles carriage return by transferring into the shared blank/end-of-item path and then returning to the Monitor loop.
- [BL1](#bl1-fe00) is a shared helper used by this path; it adjusts the scan state (via [YSAV](#ysav)) and then either:
  - transfers control into the main item-processing logic, or
  - falls through into [BLANK](#blank-fe04).
- [BLANK](#blank-fe04) is the continuation of the shared blank/skip logic used while scanning a line.

As part of main item processing, the current mode byte ([MODE](#mode)) selects the high-level behavior:

- If [MODE](#mode) indicates normal examine behavior, the Monitor prints memory contents.
- If [MODE](#mode) was set by `:` (via [SetMode](#setmode-fe18)), the Monitor stores parsed values to memory.
- If [MODE](#mode) was set by `+` or `-` (via [SetMode](#setmode-fe18)), the Monitor performs the documented “expression” behavior: it combines the next parsed value with the current address value and prints the result.

### Monitor commands (command-table entries)

The command set varies across systems and firmware revisions. The matrix below is a compact view of command characters that commonly appear in Monitor command tables.

Notes:

- Many handlers (e.g., [BASCONT](#bascont-feb3), [USR](#usr-feca), [REGZ](#regz-febf), [SetMode](#setmode-fe18), [CRMon](#crmon-fef6)) are Monitor-internal routines, but they are required for a usable Monitor.
- The table below links command characters to the handler routines typically selected by `CHRTBL`/`SUBTBL` dispatch (see [TOSUB](#tosub-ffbe)).
- If a mini-assembler is present, it is entered via the Monitor (for example, via a `+!` command-table entry handled by [Mini](#mini-fe6c)).

| Command (as typed) | Typical meaning | Common across many systems | Early cassette-oriented systems | Later firmware revisions (examples) |
|---|---|:---:|:---:|:---:|
| `Ctrl+C` | [BASCONT](#bascont-feb3) — BASIC warm start/continue | ✓ | ✓ | ✓ |
| `Ctrl+Y` | [USR](#usr-feca) — user vector | ✓ | ✓ | ✓ |
| `Ctrl+E` | [REGZ](#regz-febf) — display/edit registers | ✓ | ✓ | ✓ |
| `Ctrl+K` | [INPRT](#inprt-fe8d) / [InPort](#inport-fe8b) — `IN#` (input slot) | ✓ | ✓ | ✓ |
| `Ctrl+P` | [OUTPRT](#outprt-fe97) / [OutPort](#outport-fe95) — `PR#` (output slot) | ✓ | ✓ | ✓ |
| `Ctrl+B` | `XBASIC` — BASIC cold start (IIc/IIe family handler; not currently documented) | ✓ | ✓ | ✓ |
| `G` | [Go](#go-feb6) — execute code | ✓ | ✓ | ✓ |
| `L` | [List](#list-fe5e) — disassemble | ✓ | ✓ | ✓ |
| `M` | [Move](#move-fe2c) — move/copy memory | ✓ | ✓ | ✓ |
| `V` | [Verify](#verify-fe36) — compare memory | ✓ | ✓ | ✓ |
| `I` | [SetInv](#setinv-fe80) — inverse text | ✓ | ✓ | ✓ |
| `N` | [SetNorm](#setnorm-fe84) — normal text | ✓ | ✓ | ✓ |
| `<` | [LT](#lt-fe20) — delimiter used by [Move](#move-fe2c)/[Verify](#verify-fe36) | ✓ | ✓ | ✓ |
| `:` | [SetMode](#setmode-fe18) — enter store/fill mode | ✓ | ✓ | ✓ |
| `.` | [SetMode](#setmode-fe18) — address delimiter mode | ✓ | ✓ | ✓ |
| `+` / `-` | [SetMode](#setmode-fe18) — expression add/subtract mode | ✓ | ✓ | ✓ |
| `CR` | [CRMon](#crmon-fef6) — end of line / return to Monitor | ✓ | ✓ | ✓ |
| `BLANK` | [BLANK](#blank-fe04) — blank/skip in parser | ✓ | ✓ | ✓ |
| `W` | Cassette write (variant) | — | ✓ | — |
| `R` | Cassette read (variant) | — | ✓ | — |
| `S` | Step / single-step control (variant) | — | ✓ | — |
| `T` | Trace control (variant) | — | ✓ | — |
| `+S` | [StepZ](#stepz-fe71) — single-step (IIc command-table entry; not listed in the IIc reference manual) | — | — | ✓ |
| `+T` | [Trace](#trace-fe6f) — trace (IIc command-table entry; not listed in the IIc reference manual) | — | — | ✓ |
| `+!` | [Mini](#mini-fe6c) — mini-assembler (where implemented) | — | — | ✓ |

In all cases, the authoritative definition for a particular system is the `CHRTBL`/`SUBTBL` contents it provides.

### <a id="standard-register-display"></a>Standard register display format

The Monitor’s register-display command prints the saved 6502 register state in a single, conventional line. The format is:

- A leading carriage return (new line).
- Five fields, in this order: `A`, `X`, `Y`, `P`, `S`.
- Each field is printed as a letter, an equals sign, and a two-digit hexadecimal byte value.
- Fields are separated by spaces.

Conceptually, the line has the form:

`A=HH X=HH Y=HH P=HH S=HH`

The bytes displayed are the Monitor’s saved copies of these registers (see [Save](#save-ff4a) / [Restore](#restore-ff3f)), which are commonly updated when entering the Monitor via [Break](#break-fa4c) and may also be edited via the register command.

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

### Invoking and exiting the Monitor

- **Enter:** Typically from BASIC with `CALL -151` (Monitor entry at `$FF69`).
- **Exit to BASIC / resident language:** Systems commonly provide multiple ways to return to the previously-running language environment (for example, a warm-start key sequence, an escape-return sequence, or executing the jump instruction at `$0300` (e.g., `300G`) which commonly transfers control to the resident language environment).
- **Ctrl-Reset behavior (soft entry vector):** On systems that support the RAM-based soft entry vector [SOFTEV](#softev) (`$03F2-$03F3`) and the validity-check byte [PWREDUP](#pwredup) (`$03F4`), you can route Ctrl-Reset back into the Monitor by writing `$69` to `$03F2`, `$FF` to `$03F3`, and the corresponding validity-check value to `$03F4`. On systems using the standard validity rule, `$03F4` must equal (high byte XOR `$A5`), which yields `$5A` for `$FF69`.

### Implementation Requirements (clean-room)

A firmware implementation that claims Monitor compatibility should provide:

- **Entry points:** [Mon](#mon-ff65), [MonZ](#monz-ff69), and [MonZ4](#monz4-ff70) at their documented addresses.
- **Table-driven dispatch:** a working `CHRTBL`/`SUBTBL` pair and a dispatcher (typically [TOSUB](#tosub-ffbe)). For maximum compatibility with historical tooling, place the tables at `$FFCC` and `$FFE3`.
- **Usable interactive environment:** command input (typically via [GetLnZ](#getlnz-fd67)), character output through the standard output hook, and the ability to inspect/modify memory and CPU state (the exact command set is system- and revision-dependent).

### See also

- [CHRTBL](#chrtbl-ffcc) — Monitor command-character table
- [SUBTBL](#subtbl-ffe3) — Monitor dispatch table
- [TOSUB](#tosub-ffbe) — RTS-based dispatcher used by the Monitor
- [GetLnZ](#getlnz-fd67) — Line input with escape-sequence support
- [INBUF](#inbuf) — Input buffer
