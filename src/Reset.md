### <a id="reset-fa62"></a>Reset ($FA62)

**Description:**

This routine, called by the processor's reset vector, initializes the system and determines whether to perform a warm or cold start. It performs the following initialization sequence:

1. **Core Initialization (all variants):**
   - Calls [SetNorm](#setnorm-fe84) to clear the decimal mode flag and set standard mode
   - Calls [Init](#init-fb2f) to clear the STATUS register and configure the video mode switches

2. **Video and Input Configuration (variant-specific):**
   - **Apple II+/IIe variants**: Calls [SetVid](#setvid-fe93) and [SetKbd](#setkbd-fe89) separately, then configures analog input ports (AN0-AN3)
   - **Apple IIc variant**: Calls ZZQUIT (which combines video and keyboard setup), initializes the mouse, clears port configuration, and calls RESET_X to handle additional device initialization and button detection

3. **Warm/Cold Start Decision:**
   - Clears the keyboard strobe register
   - Calls [Bell](#bell-ff3a) (delay to account for key bounces)
   - Checks the SOFTEV soft entry vector ($03F2-$03F3) and PWREDUP validity byte ($03F4) to determine if a cold start is needed
   - For IIc variant: RESET_X additionally checks the open apple and closed apple buttons; if both are pressed, enters exerciser mode; if only open apple is pressed, forces cold start

4. **Transfer Control:**
   - If cold start is required: Jumps to [PwrUp](#pwrup-faa6)
   - If warm start: Jumps to the address in [SOFTEV](#softev) ($03F2-$03F3)

Reset does not return to its caller in normal operation; it ends by transferring control via one of the jumps above.

**Input:**

*   **Registers:**
     *   A: N/A
     *   X: N/A
     *   Y: N/A
*   **Memory:**
     *   [SOFTEV](#softev) (address $03F2-$03F3): User soft entry vector; checked to determine warm vs cold start
     *   [PWREDUP](#validity-check-byte) (address $03F4): Validity byte; used to verify SOFTEV integrity

**Output:**

*   **Registers:**
     *   A: Undefined
     *   X: Undefined
     *   Y: Undefined
     *   P: Undefined
*   **Memory:**
     *   System memory initialized:
         - [STATUS](#status) ($48): Cleared
         - [BASL/BASH](#basl-bash) ($28-$29): Set to display line base address
         - [CH/CV](#ch) ($24-$25): Cursor position set to home
         - Video mode configured per system type
         - Keyboard input configured
     - Analog input ports configured (Apple II+/IIe)
     - IIc-specific: Mouse initialized, port configuration cleared, VMODE setup

**Side Effects:**

*   Clears [KBDSTRB](#kbdstrb-c010) to acknowledge any pending keyboard input
*   Calls [Bell](#bell-ff3a) to sound system bell (aids in detecting key bounces during reset)
*   May transfer control to [PwrUp](#pwrup-faa6) for cold start, or to the address in [SOFTEV](#softev)
*   IIc variant: Checks button state (BUTN0, BUTN1) to enable exerciser mode if both apple keys are pressed
*   Calls variant-specific initialization routines ([SetVid](#setvid-fe93), [SetKbd](#setkbd-fe89), or ZZQUIT)

**Hardware Registers and Soft Switches Accessed:**

During execution and through its subroutine calls, Reset accesses the following hardware locations (actual accesses depend on variant):

*   **Video Mode Soft Switches (through [Init](#init-fb2f) and [SetTxt](#settxt-fb39)):**
    - `LORES` ($C056): Read to detect low-resolution graphics mode
    - `TXTPAGE1` ($C054): Read to detect text page 1 status
    - `TXTSET` ($C051): Read to set text mode
    - `TXTCLR` ($C050): Read to clear text mode for graphics
    - `MIXSET` ($C053): Read to enable mixed graphics/text display

*   **Keyboard (through [SetKbd](#setkbd-fe89) or ZZQUIT):**
    - `KBDSTRB` ($C010): Write ($00) to clear keyboard strobe and acknowledge input

*   **Analog Inputs (Apple II+/IIe):**
    - `AN0` ($C064): Analog input 0 configuration
    - `AN1` ($C065): Analog input 1 configuration  
    - `AN2` ($C066): Analog input 2 configuration
    - `AN3` ($C067): Read via `SETAN3` soft switch (sets AN3 to TTL high)

*   **Slot and I/O Configuration:**
    - Slot-based I/O addresses are configured through [SetVid](#setvid-fe93) and [SetKbd](#setkbd-fe89) (or ZZQUIT)

*   **IIc-Specific Registers (only in Apple IIc variant):**
    - `BUTN0`/`BUTN1`: Button inputs checked by RESET_X for exerciser mode detection
    - Mouse hardware initialized (MPADDLE, etc.)
    - Serial/comm port registers cleared by CLRPORT

See the documentation for called routines ([SetNorm](#setnorm-fe84), [Init](#init-fb2f), [SetVid](#setvid-fe93), [SetKbd](#setkbd-fe89)) for detailed memory location modifications.

**See also:**

*   [PwrUp](#pwrup-faa6)
*   [SOFTEV](#softev)
*   [SetNorm](#setnorm-fe84)
*   [Init](#init-fb2f)
*   [SetVid](#setvid-fe93)
*   [SetKbd](#setkbd-fe89)
*   [Bell](#bell-ff3a)