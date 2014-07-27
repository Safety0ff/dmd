#include <cstdlib>
#include <stdint.h>

extern "C"
{
    void* gc_malloc(std::size_t, uint32_t ba = 0, void* ti = 0);
    void gc_free(void*);
}

void* operator new(std::size_t sz)
{
    return gc_malloc(sz);
}

void operator delete(void* ptr)
{
    gc_free(ptr);
}