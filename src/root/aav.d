
module root.aav;

import root.rootobject;

struct AA;

extern(C++) size_t dmd_aaLen(AA*);
extern(C++) void* dmd_aaGetRvalue(AA*, void*);
extern(C++) void** dmd_aaGet(AA**, void*);
