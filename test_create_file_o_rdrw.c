#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    char *buf = "test";
    int file_descriptor = open("myfile.txt", O_RDWR | O_CREAT | O_TRUNC, 0444 );
    printf("INFO: myfile.txt created\n");
    write(file_descriptor, buf, strlen(buf));
    close(file_descriptor);
    return 0;
}

/*
 Example code
 int main (void)
{
    int fd1, fd2, sz;
    char *buf = "hello world !!!";
    char *buf2 = malloc(strlen(buf) + 1); // space for '\0'

    fd1 = open ("test.txt", (O_RDWR | O_CREAT), 777); // 3rd arg is the permissions
    printf("file fd1 created\n");
    write(fd1, buf, strlen(buf));
    lseek(fd1, 0, SEEK_SET);            // reposition the file pointer
    printf("write %s, in filedescpror %d\n", buf, fd1);
    sz = read(fd1, buf2, strlen(buf));
    buf[sz] = '\0';
    printf("read %s, with %d bytes from file descriptor %d\n", buf2, sz, fd1);
    close(fd1);
    fd2 = open ("testcpy.txt", (O_RDWR | O_CREAT));
    write(fd2, buf2, strlen(buf));
    close(fd2);
    return 0;
}*/
