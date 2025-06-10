// Minimal system call stubs for FreeRTOS embedded system
#include <sys/stat.h>

void *_sbrk(int incr) { 
    extern char _end; 
    static char *heap_end = &_end;
    char *prev_heap_end = heap_end;
    heap_end += incr;
    return (void*)prev_heap_end;
}

int _write(int fd, const void *buf, int count) { 
    return count; 
}

int _close(int fd) { 
    return 0; 
}

int _lseek(int fd, int offset, int whence) { 
    return 0; 
}

int _read(int fd, void *buf, int count) { 
    return 0; 
}

int _fstat(int fd, struct stat *st) { 
    st->st_mode = S_IFCHR;
    return 0; 
}

int _isatty(int fd) { 
    return 1; 
}
