--cinclude--
#include(<lib/sj-lib-json/rapidjson/document.h>)
#include(<lib/sj-lib-json/rapidjson/writer.h>)
#include(<lib/sj-lib-json/rapidjson/stringbuffer.h>)
--cinclude--

--cfunction--
typedef rapidjson::GenericValue<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<> > JsonValue;
--cfunction--

package json {
    load(s : 'string)'heap document {
        s.nullTerminate()
        d := nullptr
        --c--
        d = new rapidjson::Document();
        ((rapidjson::Document*)d)->Parse(string_char(s));
        --c--
        heap document(d)
    }

    @heap
    document(
        d : nullptr

        root() {
            v : value(parent)
            --c--
            v.v = _parent->d;
            --c--
            v
        }
    ) { 
        this 
    } copy {
        halt("copy is not allowed")
    } destroy {
        --c--
        if (_this->d) {
            delete (rapidjson::Document*)_this->d;
        }
        --c--
    }

    value(
        root : heap document()
        v : nullptr

        getAt(key : 'string)'value? {
            key.nullTerminate()
            hasValue := false
            --c--
            hasvalue = ((JsonValue*)_parent->v)->HasMember(string_char(key));
            --c--
            if hasValue {
                childv := nullptr 
                --c--
                childv = &(*((JsonValue*)_parent->v))[string_char(key)];
                --c--
                valid(value(root, childv))
            } else {
                empty'value
            }
        }

        each(cb : '(:value)void) {
            arraySize := 0
            --c--
            arraysize = ((JsonValue*)_parent->v)->Size();
            --c--
            for i : 0 to arraySize {
                childv := nullptr 
                --c--
                childv = &(*((JsonValue*)_parent->v))[i];
                --c--
                cb(value(root, childv))
            }
        }
        
        asi32() {
            --c--
            if (_parent->v) {
                #return(i32, ((JsonValue*)_parent->v)->GetInt());
            } else {
                #return(i32, 0);
            }
            --c--
        }

        asu32() {
            --c--
            if (_parent->v) {
                #return(u32, ((JsonValue*)_parent->v)->GetUint())
            } else {
                #return(u32, 0);
            }
            --c--
        }

        asi64() {
            --c--
            if (_parent->v) {
                #return(i64, ((JsonValue*)_parent->v)->GetInt64())
            } else {
                #return(i64, 0);
            }
            --c--
        }

        asu64() {
            --c--
            if (_parent->v) {
                #return(u64, ((JsonValue*)_parent->v)->GetUint64())
            } else {
                #return(u64, 0);
            }
            --c--
        }

        asf32() {
            --c--
            if (_parent->v) {
                #return(f32, ((JsonValue*)_parent->v)->GetFloat())
            } else {
                #return(f32, 0);
            }
            --c--
        }

        asf64() {
            --c--
            if (_parent->v) {
                #return(f64, ((JsonValue*)_parent->v)->GetDouble())
            } else {
                #return(f64, 0);
            }
            --c--
        }

        asString() {
            if v != nullptr {
                vresult := nullptr
                count := 0
                --c--
                count = ((JsonValue*)_parent->v)->GetStringLength();
                int datasize = (((count - 1) / 256) + 1) * 256;
                sjs_array* arr = createarray(1, datasize);
                vresult = (void*)arr;
                arr->count = count;
                memcpy(arr->data, ((JsonValue*)_parent->v)->GetString(), count);
                --c--
                string(count := count, data := array!char(vresult))
            } else {
                string()
            }
        }
    ) { this }
}