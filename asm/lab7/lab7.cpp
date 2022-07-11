#include <conio.h>
#include <dos.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#pragma inline

#define SIZE 10

float array[SIZE];
float power;

void inputArray();
void outputArray();
void asmAlgorithm();

int main() {
    inputArray();
    printf("Input array: \n");
    outputArray();

    asmAlgorithm();

    printf("\nResult array: \n");
    outputArray();

    return 0;
}

void inputArray() {
    int res;
    printf("Input 10 elements: \n");

    for (int i = 0; i < SIZE; ++i) {
        do {
            res = scanf("%f", &array[i]);
            while (getchar() != '\n')
                if (res != 1) printf("Invalid input\n");
        } while (res != 1);
    }
    printf("Input a power num: \n");
    do {
        res = scanf("%f", &power);
        while (getchar() != '\n')
            if (res != 1) printf("Invalid input\n");
    } while (res != 1);
}

void outputArray() {
    for (int i = 0; i < SIZE; ++i) {
        printf("%.3f ", array[i]);
    }
}

void asmAlgorithm() {

    asm{
        finit
        xor cx, cx
        mov cx, SIZE
        lea bx, array
    }
    calculate:
    asm{
        fld dword ptr power
        fld dword ptr[bx]	
        fyl2x       		
        fld st(0)   		
        frndint     		
        fxch st(1)			
        fsub st(0),st(1)	
        f2xm1           	
        fld1            	
        faddp st(1),st  	
        fscale 				
        fstp dword ptr[bx]
        add bx, 4
        loop calculate
    }
    end:
    asm fwait
}
