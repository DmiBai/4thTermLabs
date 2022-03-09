
#include <stdio.h>
#include <stdlib.h>
#include <features.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char *argv[], char* envp[])
{
    
    for(int k = 0; k < argc; k++){
        printf("--Argv[%i] is %s\n", k, argv[k]);
    }
    int i = 0;

    while(envp[i++])
    {
        printf("%s\n", envp[i]);
    }
    
    return 0;
}
