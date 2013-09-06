#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#define _LARGEFILE_SOURCE
#define _FILE_OFFSET_BITS 64
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#ifdef __cplusplus
}
#endif

MODULE = Sys::PageCache     PACKAGE = Sys::PageCache

HV*
_fincore(fd, offset, length)
    int fd;
    size_t offset;
    size_t length;
  CODE:
    void *pa = (char *)0;
    unsigned char *vec = (unsigned char *)0;
    size_t page_size = getpagesize();
    size_t page_index;
    size_t cached = 0;

    RETVAL = (HV *)sv_2mortal((SV *)newHV());

    pa = mmap((void *)0, length, PROT_NONE, MAP_SHARED, fd, offset);
    if (pa == MAP_FAILED) {
        perror("mmap");
        exit(EXIT_FAILURE); // fixme
    }

    vec = calloc(1, (length + page_size - 1) / page_size);
    if (vec == NULL) {
        perror("calloc");
        exit(EXIT_FAILURE); // fixme
    }

    if (mincore(pa, length, vec) != 0) {
        perror("mincore");
        exit(EXIT_FAILURE); // fixme
  //        fprintf(stderr, "mincore(%p, %llu, %p): %s\n",
  //                pa, (unsigned long long)off_limit, vec, strerror(errno));
  //        free(vec);
  //        close(fd);
  //        exit(EXIT_FAILURE);
    }

    for (page_index = 0; page_index <= length / page_size; page_index++) {
        if (vec[page_index] & 1) {
            //printf("%lu\n", (unsigned long)page_index);
            cached++;
        }
    }

    free(vec);
    munmap(pa, length);

    hv_store(RETVAL, "page_size",     9, newSViv(page_size), 0);
    hv_store(RETVAL, "cached_pages", 12, newSViv(cached), 0);
    hv_store(RETVAL, "cached_size",  11, newSViv((unsigned long long)cached * page_size), 0);
  OUTPUT:
    RETVAL

int
_fadvise(fd, offset, length, advice)
    int fd;
    size_t offset;
    size_t length;
    int advice
  CODE:
    int r;

    r = fdatasync(fd);
    if (r != 0) {
        // fixme
        //fputs("(fdatasync failed) ", stderr);
        //perror(fname);
        perror("fdatasync");
    }
    r = posix_fadvise(fd, offset, length, POSIX_FADV_DONTNEED);//fixme
    if (r != 0) {
      fputs("(posix_fadvise failed) ", stderr);
      perror("fadvise");
    }

    RETVAL = r;
  OUTPUT:
    RETVAL
