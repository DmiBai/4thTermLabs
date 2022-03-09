#define _DEFAULT_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <features.h>
#include <sys/ipc.h>
#include <sys/shm.h>

int main()
{
    pid_t pid;
    char *word;

    char *taskWithNoSense = getenv("HOME");
    if (taskWithNoSense)
    {
        printf("GETTING $HOME VARIABLE FROM ENVIROMENT \n%s\n", taskWithNoSense);
    }

    printf("Enter any word\n");
    word = (char *)malloc(sizeof(char));
    int i = 0;
    char c = 'a';
    while (c != '\n')
    {
        scanf("%c", &c);
        word[i] = c;
        i++;
        word = (char *)realloc(word, i * sizeof(char));
        // printf("%c",c);
    }
    i--;
    word[i] = '\0';

    switch (pid = fork())
    {
    case -1:
    {
        perror("fork");
        exit(1);
        break;
    }
    case 0:
    {
        printf("Child process  ID is: %i\n", getpid());
        printf("ID of parent process is: %i\n", getppid());
        char **myEnvp = (char **)malloc(2 * sizeof(char *));
        myEnvp[0] = "word";
        myEnvp[0] = (char *)malloc(sizeof(char));
        for (int j = 0; j < i; j++)
        {
            myEnvp[0][j] = word[j];
        }
        myEnvp[1] = NULL;

        //char *const *myEnvp1 = myEnvp;

        char **myArgv = (char **)malloc(3 * sizeof(char *));
        myArgv[0] = "lab2";
        myArgv[1] = word;
        myArgv[2] = NULL;

        setenv("WORD", word, 1);

        execve("lab2", myArgv, __environ);
        // execl("lab2", "lab2", "abcd");
        // execle("lab2", "lab2", NULL, myEnvp1);
        break;
    }
    default:
    {
        printf("-Parent process with ID %i has been started\n", getpid());
        wait(&pid);
        printf("-Child exit code: %d\n", WEXITSTATUS(pid));
        break;
    }
    }

    return 0;
}
