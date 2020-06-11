brainfuck compiler written in terra

limited to 8192 memory cells

completely unoptimized, but llvm makes it fast somehow

main thing that would speed stuff up is buffering stdin/stdout

```
terra fuck.t hello.bf

./hello-exe
```
