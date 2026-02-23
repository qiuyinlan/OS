# Makefile

A `Makefile` is a special file that contains a set of rules and dependencies for building a software project. It is used by the `make` build automation tool.

## Core Concepts
- **Rules**: A rule specifies how to create or update a target file. It consists of a target, dependencies, and commands.
- **Target**: The file to be created, e.g., an executable or an object file.
- **Dependencies**: The files that the target depends on. If any dependency has been modified more recently than the target, the target is considered out-of-date.
- **Commands**: The shell commands to be executed to create the target.

### Example Rule
```makefile
target: dependency1 dependency2
    # Commands to create target from dependencies
    gcc -o target dependency1.c dependency2.c
```

## How `make` Works
When you run the `make` command, it looks for a `Makefile` in the current directory. It then:
1.  Reads the rules in the `Makefile`.
2.  Determines the target to build (by default, the first target in the file).
3.  Checks the modification times of the target and its dependencies.
4.  If the target does not exist, or if any dependency is newer than the target, `make` executes the commands for that rule.
5.  This process is applied recursively to the dependencies, building a dependency tree.

## Benefits
- **Automation**: Automates the build process, saving developers from manually typing compilation commands.
- **Efficiency**: Only rebuilds the parts of the project that have changed, saving significant time on large projects.
- **Consistency**: Ensures that the project is built in a consistent and reproducible way.

## In This Project
In this project, we use a `Makefile` to:
- Compile assembly (`.asm`) and C (`.c`) source files into object files (`.o`).
- Link the object files together to create the final kernel executable.
- Generate the final disk image (`.img`) by combining the bootloader and the kernel.

## Associated Knowledge
- [[编译]] (Compilation)
- [[链接]] (Linking)
- [[gcc]]
- [[nasm]]
- [[Shell]]
- [[mtime]]
