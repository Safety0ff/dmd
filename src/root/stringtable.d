
module root.stringtable;

import root.rmem;

extern(C++)
struct StringValue
{
    void *ptrvalue;
private:
    size_t length;
    char[0] lstring;
public:
    size_t len() const { return length; }
    const(char)* toDchars() const { return lstring.ptr; }
};

extern(C++)
struct StringTable
{
private:
    void **table;
    size_t count;
    size_t tabledim;

public:
    void _init(size_t size = 37);
    ~this()
    {
        for (size_t i = 0; i < count; i++)
            table[i] = null;

        mem.free(table);
        table = null;
    }

    StringValue* lookup(const(char)* s, size_t len);
    StringValue* insert(const(char)* s, size_t len);
    StringValue* update(const(char)* s, size_t len);
};
