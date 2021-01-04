module dvector;

version(LDC){
    pragma(LDC_no_moduleinfo);
}

import clib: wfree = free, malloc, realloc, memcpy, memmove;

private enum CAPACITY = 4;

struct Dvector(T) {
    private T* chunks;
    private size_t total;
    size_t capacity;

    @property T front() @nogc nothrow {
        return chunks[0];
    }

    @property T back() @nogc nothrow {
        return chunks[length-1];
    }

    size_t length() @nogc nothrow pure const {
        return total;
    }

    alias opDollar = length;
    
    @property bool empty() const @nogc nothrow {
        return total == 0;
    }

    void popFront() @nogc nothrow {
        remove(0);
    }

    void popBack() @nogc nothrow {
        remove(length-1);
    }

    /** !!! WARNING !!!
    Allocates a new array.
    Use it carefully with the standard library.
    Be sure that the standard library functions don't implicitly copy it.
    But, it is Ok if the standard library functions return a handle of copied range
    so that you can free it manually. Otherwise, you leak memory.
    */
    Dvector!T save() @nogc nothrow {
        T* cc_chunks = cast(T*)malloc(T.sizeof * this.capacity);
        memcpy(cc_chunks, chunks, capacity * T.sizeof);
        return Dvector!T(cc_chunks, this.total, this.capacity);
    }

    this(T* chunks, size_t total, size_t capacity) @nogc nothrow {
        this.chunks = chunks;
        this.total = total;
        this.capacity = capacity;
    }
    
    /// for array literals
    this(T, size_t N)(const T[N] rhs) @nogc nothrow {
        reserve(rhs.length);
        foreach(ref elem; rhs)
            pushBack(elem);
    }

    // use it to avoid a lot of resizes. remember that reserve allocates.
    void reserve(size_t n) @nogc nothrow {
        allocIfneeded();
        if(n > capacity){
            resize(nextPowerOfTwo(n));
        }
    }

    void pushBack(T elem) @nogc nothrow {
        allocIfneeded();
        if (capacity == total)
            resize(capacity * 2);
        chunks[total++] = elem;
    }
    
    alias pBack = pushBack;

    ref T opIndex(size_t i) @nogc nothrow {
        return chunks[i];
    }
    
    void opIndexAssign(T elem, size_t i) @nogc nothrow {
        chunks[i] = elem;
    }
    
    int indexOf(T elem) @nogc nothrow {
        foreach(int i; 0..cast(int)length)
            if (chunks[i] is elem)
                return i;
        return -1;
    }

    void remove(size_t index) @nogc nothrow {
        for (size_t i = index; i < total - 1; i++) {
            chunks[i] = chunks[i + 1];
        }

        total--;

        if (total > 0 && total == capacity / 4){
            resize(capacity / 2);
        }
    }
    
    void remove(size_t index, size_t n) @nogc nothrow{
        memmove(&chunks[index], &chunks[index+n], T.sizeof*(length-index-n));
        total -= n;

        if (total > 0 && total == capacity / 4)
            resize(capacity / 2);
    }

    void allocIfneeded() @nogc nothrow {
        if(chunks is null){
            capacity = CAPACITY;
            T* _chunks = cast(T*)malloc(T.sizeof * CAPACITY);
            this.chunks = _chunks;
        }
    }

    void resize(size_t capacity) @nogc nothrow {
        version(Debug){
            
            //printf("resize: %d to %d\n", this.capacity, capacity);
        }

        T* chunks = cast(T*)realloc(this.chunks, T.sizeof * capacity);
        if (chunks) {
            this.chunks = chunks;
            this.capacity = capacity;
        }
    }

    void free() @nogc nothrow {
        if(chunks !is null){
            total = 0;
            capacity = CAPACITY;
            wfree(chunks);
            chunks = null;
        }
    }

    alias clear = typeof(this).free;
    
    int opApply(int delegate(ref T) @nogc nothrow dg) @nogc nothrow{
        int result = 0;

        for (size_t k = 0; k < total; ++k) {
            result = dg(chunks[k]);

            if (result) {
                break;
            }
        }
        return result;
    }
    
    int opApply(int delegate(size_t i, ref T) @nogc nothrow dg) @nogc nothrow{
        int result = 0;

        for (size_t k = 0; k < total; ++k) {
            result = dg(k, chunks[k]);

            if (result) {
                break;
            }
        }
        return result;
    }
    
    // overloads for gc usages:
    int opApply(int delegate(ref T) dg){
        int result = 0;

        for (size_t k = 0; k < total; ++k) {
            result = dg(chunks[k]);

            if (result) {
                break;
            }
        }
        return result;
    }
    
    int opApply(int delegate(size_t i, ref T) dg){
        int result = 0;

        for (size_t k = 0; k < total; ++k) {
            result = dg(k, chunks[k]);

            if (result) {
                break;
            }
        }
        return result;
    }
    
    Dvector!T opBinary(string op)(ref Dvector!T rhs) @nogc nothrow{
        static if (op == "~"){
            foreach(elem; rhs)
                pushBack(elem);
            return this;
        } 
        else static assert(0, "Operator "~op~" not implemented");
    }
    
    Dvector!T opBinary(string op)(T rhs) @nogc nothrow {
        static if (op == "~"){
            pushBack(rhs);
            return this;
        } 
        else static assert(0, "Operator "~op~" not implemented");
    }

    @nogc nothrow Dvector!T opOpAssign(string op)(ref Dvector!T rhs) if (op == "~"){
        foreach(elem; rhs)
            pushBack(elem);
        return this;
    }

    @nogc nothrow Dvector!T opOpAssign(string op)(T rhs) if (op == "~"){
        pushBack(rhs);
        return this;
    }

    void pushFront(T elem) @nogc nothrow {
        pushBack(T.init);

        for(size_t i = length-1; i > 0; i--){
            chunks[i] = chunks[i - 1];
        }
        chunks[0] = elem;
    }
    
    void insert(T elem, size_t position) @nogc nothrow {
        pushBack(T.init);

        for (size_t k = length-1; k > position; k--)
            chunks[k] = chunks[k - 1];
        chunks[position] = elem;
    }

    void insert(ref Dvector!T other, size_t position) @nogc nothrow{
        const oldlen = length;
        foreach(i; 0..other.length)
            pushBack(T.init);
        memmove(&chunks[position+other.length], &chunks[position], (oldlen-position)*T.sizeof);
        memcpy(&chunks[position], other.slice.ptr, other.length*T.sizeof);
    }

    void insert(T[] other, size_t position) @nogc nothrow{
        const oldlen = length;
        foreach(i; 0..other.length)
            pushBack(T.init);
        memmove(&chunks[position+other.length], &chunks[position], (oldlen-position)*T.sizeof);
        memcpy(&chunks[position], other.ptr, other.length*T.sizeof);
    }

    // allocates new sub vector removes elements from the original vector. partially similar to splice of javascript.
    // instead of this it is better to use myvec[start..end] without extra memory if possible.
    Dvector!T splice(size_t index, size_t n) @nogc nothrow {
        /+
        auto new_chunks = cast(T*)malloc(n*T.sizeof);
        memcpy(new_chunks, &chunks[index], n*T.sizeof);
        memmove(&chunks[index], &chunks[index+n], T.sizeof*(length-index-n));
        total -= n;

        if (total > 0 && total == capacity / 4)
            resize(capacity / 2);

        return Dvector!T(new_chunks, n, n);
        +/

        /// workaround 
        Dvector!T narr;
    
        foreach(i; index..index + n)
            narr.pushBack(chunks[i]);
        foreach(i; 0..n){
            remove(index);
        }
        return narr;
    }

    // use std.range.retro if it is possible, otherwise use this and free returning vec with free 
    Dvector!T reversed_copy() @nogc nothrow{
        T* cc_chunks = cast(T*)malloc(T.sizeof * this.capacity);
        auto ret = Dvector!T(cc_chunks, this.total, this.capacity);
        
        size_t k;
        for(size_t i = length; i-- > 0; )
            ret[k++]= chunks[i];
        return ret;
    }
    
    T[] slice() @nogc nothrow{
        return chunks[0..length];
    }

    inout(T)[] opSlice(size_t start, size_t end) inout @nogc nothrow {
        return chunks[start..end];
    }

    inout(T)[] opSlice() inout @nogc nothrow {
        return opSlice(0, length);
    }

    T[] release() @nogc nothrow {
        T[] data = chunks[0..total];
        
        chunks = null;
        total = 0;
        capacity = 0;
        
        return data;
    }
}

private size_t nextPowerOfTwo(size_t v) @nogc nothrow {
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    return ++v;
}
