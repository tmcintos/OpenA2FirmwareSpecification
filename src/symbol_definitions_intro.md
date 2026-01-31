## <a id="symbol-definitions"></a>Symbol Definitions

This section documents the memory locations, variables, and hardware registers used by the Apple II firmware. These symbols are referenced throughout the firmware entry point specifications and provide the standard interface between firmware and software.

The symbols are organized into two categories:

- **Zero-Page Definitions** - Variables stored in the fast-access zero-page memory ($0000-$00FF)
- **Other Definitions** - System variables, hardware registers, and memory buffers located elsewhere in the address space

Understanding these symbols is essential for implementing compatible firmware or writing software that interacts directly with the firmware entry points.

