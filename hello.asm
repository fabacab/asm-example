;
; FILE: hello.asm
;
; This is a Netwide Assembler (NASM) assembly language source file
; for a simple Linux program that prints the single line:
;
;     "Hello, world!"
;
; It is thoroughly commented in an attempt to explain what almost all
; other Assembly tutorials fail to clearly describe: how Assembly
; actually works. This example uses 32-bit (`i386`) conventions for
; GNU/Linux-like operating systems. It won't work on FreeBSD/macOS.
;
; A program written in Assembly is one of the most rudimentary ways
; to describe what you would like a computer to do. It contains a
; series of instructions, organized into sections (sometimes also
; called "code segments"), that are interpreted by another program
; called an *assembler* which is responsible for converting the
; short mnemonic phrases into a sequence of ones and zeroes that is
; ingested by the computer and executed as commands therein.
;
; The two most important code segments ("sections") are the "text"
; section (denoted as `.text` in Assembly language), and the "data"
; section (denoted as `.data` in Assembly language). The former of
; these sections (`.text`) contains the actual instructions for the
; computer to execute, while the latter (`.data`) describes the state
; of the environment in which the program should begin executing. In
; other words, the `.data` section lists the variables that should be
; set and what values they should have before the first instruction
; in the program is executed. It is therefor sometimes also called the
; "initialized data" section, because it holds initialized variables.
;
; Sections can be placed in any order, but they must be declared with
; a `section` keyword, followed by the section name. For example, to
; declare the `.text` section of a program in an Assembly source file,
; the programmer needs to write `section .text` on a line by itself.


; Data segment (the `.data` section).
;
; This section contains initialized variables, i.e., variables and
; other definitions whose values are already defined the moment the
; program is loaded but has not yet begun executing.
;
; You define variables using one of a number of "define directives,"
; which are Assembly language instructions that reserve a certain
; amount of space for the variable being defined. The syntax for the
; define directives is:
;
;     variable_name define_directive initial_value[, additional_appended_value]
;
; where `variable_name` is the name you'd like the variable to have,
; `define_directive` is one of the define directive keywords (listed
; below), and `initial_value` is the value you'd like the variable to
; when the program is first loaded and before it begins executing.
;
; The `initial_value` can also be the special value `?` (a literal
; question mark), to indicate that some space in memory should be
; reserved for the variable, but that its value should not yet be set.
;
; The `define_directive` can be one of the following,  each of which
; allocate a specific amount of memory for the storage of the value:
;
; * `db`: "Define byte" allocates a single byte of memory (typically 8 bits).
; * `dw`: "Define word" allocates a single word of memory (two bytes).
; * `dd`: "Define double word" allocates a DWORD (two words, i.e., four bytes).
; * `dq`: "Define quadruple word" allocates a QWORD (four words, i.e., eight bytes).
; * `dt`: "Define ten bytes" allocates ten bytes of memory.
;
; Constants, which are variables that cannot be redefined later on,
; are declared in a similar fashion.
section .data
    ; Define the variable `msg` as a single byte, and set its value
    ; to be the starting address of the memory into which the literal
    ; ASCII string `Hello, world!`, followed by the hexadecimal value
    ; `A` is written. When converted to ASCII, the value `0xA` is the
    ; linefeed ("newline") character.
    ;
    ; Together, the string `Hello, world!` and a linefeed character is
    ; exactly 14 bytes long (since each character consumes one byte in
    ; memory), and the variable `msg` now points to the address of the
    ; first character (the `H`).
    msg db  'Hello, world!', 0xA

    ; Define the variable `len` as a constant whose value is the
    ; memory address of the current location (expressed as the `$`
    ; sign) minus the value of the `msg` variable (` - msg`). Since
    ; the `msg` variable is less than the current location in memory
    ; (it was defined earlier and we have since moved fourteen bytes
    ; "forward" or "higher" in memory), subtracting its value from
    ; the current location gives us the difference between the start
    ; address and the end address of the string, which is the length
    ; of the string (i.e., fourteen bytes). Defining `len` this way
    ; means that we do not have to manually change the value of `len`
    ; if we change the size (length) of the message we want to write.
    len equ $ - msg

; Text segment (the `.text` section).
;
; This section contains the program instructions themselves. These
; are the commands the program tells the computer to perform when the
; program is loaded and is executed by the Operating System kernel.
section .text

; By convention, the label `_start` indicates where in our program
; the computer should actually begin executing instructions. A label
; is simply the name of a certain point in the program. There isn't
; anything particularly special about the `_start` label except that
; it is universally understood to be the location of the very first
; instruction in our program. If we don't include the `_start` label,
; the computer will not know which line in our `.text` section to run
; first.
;
; Different systems will look for a different label here. For example,
; the linker on macOS will look for `start` (no underscore) by default
; but you can typically explicitly inform the linker as to the value
; of your starting label with the `-e` option to the `ld` command.
; TODO: What is the `global` keyword?
global _start

_start:
    ; In order to write output to the screen, our program will need to
    ; request that the Operating System's kernel do the actual writing
    ; to the screen, since only the kernel has permission to do this.
    ; Thankfully, every OS kernel implements an interface between user
    ; programs like ours and privileged functions like writing output.
    ; This interface is known as a "system call" or "syscall" because
    ; it is a way for a regular user's program to "call" the kernel up
    ; with a request. Each system call has a unique decimal number
    ; assigned to it. The one we care about is the `write` syscall,
    ; which is assigned the number 4.
    ;
    ; System calls are generally documented in their own section of a
    ; system's manual, much like any other command. Try `man 2 write`
    ; to look up the manual page in section 2 (the system call section)
    ; regarding the `write` system call. These manual pages describe
    ; how a program written in higher-level language such as C might
    ; use the system call interface. To find the system call number in
    ; decimal for the specific system call itself, you need to locate
    ; the C header file that declares the mapping between the syscall
    ; name and its number. On UNIX-like systems, this is usually in a
    ; file called `syscall.h`. For example on a macOS system, the file
    ; at `/usr/include/sys/syscall.h` contains the following snippet:
    ;
    ; ```C
    ; #define SYS_syscall        0
    ; #define SYS_exit           1
    ; #define SYS_fork           2
    ; #define SYS_read           3
    ; #define SYS_write          4
    ; #define SYS_open           5
    ; #define SYS_close          6
    ; ```
    ;
    ; Here you can plainly see a C-language `#define` macro that is
    ; associating a system call name (like `SYS_write`) with a decimal
    ; value (like `4`). This tells us that the system call number for
    ; the `write` syscall on this macoS system is `4`. In fact, `4` is
    ; the conventional value for the `write` system call on most UNIX
    ; systems. (But it doesn't have to be, so check on your computer!)

    ; In order to actually invoke this system call, we need to prepare
    ; a number of things so that when we do actually call the `write`
    ; function in the kernel, that function will have what it needs to
    ; successfully write what we intended it to write. We do this by
    ; placing certain values in certain *registers* in the computer. A
    ; register is simply a place to store ("register") a certain value
    ; that is immediately accessible to the central processing unit.
    ; You can think of it like extremely fast, but very small, RAM.

    ; Different registers have different purposes, and different CPUs,
    ; system calls, and other functions will expect to find certain
    ; values in certain registers. Which registers are available on a
    ; given system will vary depending on the architecture, that is,
    ; *physical* implementation, of that system. This example uses an
    ; Intel-compatible architecture called x86.
    ;
    ; For our purposes, the `write` system call expects 3 arguments,
    ; which you can see from its manual page. The first argument is
    ; the numeric file descriptor to write to. The second is the
    ; address in memory to begin copying from ("writing"). The third
    ; is how many bytes to copy from the address pointed to in the
    ; second argument.

    ; The system call expects each of these values to be in one of the
    ; general purpose registers. Specifically, it expects its first
    ; argument (the file descriptor number) to be in the register we
    ; call `ebx` ("extended B general purpose register"). Its second
    ; argument should be in the next register, `ecx`. Finally, its
    ; third argument should be in the register after that, `edx`.

    ; Place the message length, which was stored into the variable
    ; `len` when the program loaded, into the `edx` register.
    mov edx, len

    ; Place the starting address of the message to write, pointed to
    ; by the `msg` variable, into the `ecx` register.
    mov ecx, msg

    ; Place the decimal number `1` (which is conventionally
    ; `STDOUT`, i.e., the "standard output" file stream) into `ebx`.
    mov ebx, 1

    ; Place the decimal number `4` into the `eax` register. This is
    ; the value of the system call number we are going to execute.
    mov eax, 4

    ; Now that the registers are populated with the appropriate values
    ; for the `write` syscall, we need to request that the kernel
    ; actually stop running our program and start executing part of
    ; its own code exactly where the `write` function begins. Since
    ; we have already placed the decimal value `4` in `eax`, we can
    ; signal the kernel that we are ready to hand over control of the
    ; processor by instructing the processor to execute a software
    ; interrupt instruction (`int`) with a specific value (`0x80`, for
    ; the "syscall interrupt" instruction).
    int 0x80

    ; If we are still running, it means that the kernel executed our
    ; request and, assuming everything went smoothly, we can now begin
    ; to exit our program. We do this using another system call, the
    ; `exit` system call, which has decimal number `1`. Let's set that
    ; up in the same way as the prior system call.
    mov eax, 1

    ; Again, execute the prepared system call, exiting our program.
    int 0x80
