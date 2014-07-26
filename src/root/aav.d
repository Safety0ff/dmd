
module root.aav;

import root.rmem;

private
{
alias Key = void*;
alias Value = void*;

size_t hash(size_t a)
{
    a ^= (a >> 20) ^ (a >> 12);
    return a ^ (a >> 7) ^ (a >> 4);
}
}

struct aaA
{
    aaA* next;
    Key key;
    Value value;
};

struct AA
{
    aaA*[] b;
    size_t nodes;       // total number of aaA nodes
    aaA*[4] bsmall;     // storage for small AA's

    aaA aafirst;        // a lot of these AA's have only one entry
};

/****************************************************
 * Determine number of entries in associative array.
 */

size_t dmd_aaLen(AA* aa)
{
    return aa ? aa.nodes : 0;
}


/*************************************************
 * Get pointer to value in associative array indexed by key.
 * Add entry for key if it is not already there.
 */

Value* dmd_aaGet(AA** paa, Key key)
{
    //printf("paa = %p\n", paa);

    if (!*paa)
    {   AA* a = new AA();
        a.b = a.bsmall[];
        *paa = a;
    }
    //printf("paa = %p, *paa = %p\n", paa, *paa);

    assert((*paa).b.length);
    size_t i = hash(cast(size_t)key) % (*paa).b.length;
    aaA** pe = &(*paa).b[i];
    aaA* e;
    while ((e = *pe) !is null)
    {
        if (key is e.key)
            return &e.value;
        pe = &e.next;
    }

    // Not found, create new elem
    //printf("create new one\n");

    size_t nodes = ++(*paa).nodes;
    e = (nodes != 1) ? new aaA() : &(*paa).aafirst;
    e.key = key;
    *pe = e;

    //printf("length = %zu, nodes = %d\n", (*paa).b.length, nodes);
    if (nodes > (*paa).b.length * 2)
    {
        //printf("rehash\n");
        dmd_aaRehash(paa);
    }

    return &e.value;
}


/*************************************************
 * Get value in associative array indexed by key.
 * Returns null if it is not already there.
 */

Value dmd_aaGetRvalue(AA* aa, Key key)
{
    //printf("_aaGetRvalue(key = %p)\n", key);
    if (aa)
    {
        size_t i;
        size_t len = aa.b.length;
        i = hash(cast(size_t)key) % len;
        aaA* e = aa.b[i];
        while (e)
        {
            if (key is e.key)
                return e.value;
            e = e.next;
        }
    }
    return null;    // not found
}

/********************************************
 * Rehash an array.
 */

void dmd_aaRehash(AA** paa)
{
    //printf("Rehash\n");
    if (*paa)
    {
        AA *aa = *paa;
        if (aa)
        {
            size_t len = aa.b.length;
            if (len == 4)
                len = 32;
            else
                len *= 4;
            auto ptr = cast(aaA**)mem.calloc(len, (aaA*).sizeof);
            aaA*[] newb = ptr[0 .. len];

            foreach (e; aa.b)
            {
                while (e)
                {   aaA* enext = e.next;
                    size_t j = hash(cast(size_t)e.key) % len;
                    e.next = newb[j];
                    newb[j] = e;
                    e = enext;
                }
            }

            if (aa.b.ptr !is aa.bsmall.ptr)
                mem.free(aa.b.ptr);

            aa.b = newb;
        }
    }
}


unittest
{
    AA* aa;
    Value v = dmd_aaGetRvalue(aa, null);
    assert(!v);
    Value *pv = dmd_aaGet(&aa, null);
    assert(pv);
    *pv = cast(void *)3;
    v = dmd_aaGetRvalue(aa, null);
    assert(v is cast(void *)3);
}