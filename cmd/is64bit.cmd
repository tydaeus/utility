@Echo Off

if defined ProgramFiles(x86) (
    echo host is 64-bit
) else (
    echo host is 32-bit
)