--cinclude--
#include(<lib/sj-lib-json/rapidjson/document.h>)
#include(<lib/sj-lib-json/rapidjson/writer.h>)
#include(<lib/sj-lib-json/rapidjson/stringbuffer.h>)
--cinclude--

// package json {
    document_load(s : 'string) {
        s.nullTerminate()
        d : document()
        --c--
        d.d.Parse((char*)s->data.data);
        --c--
        d
    }

    document(
        --cvar--
        rapidjson::Document d;
        --cvar--

        getAt(key : 'string) {
            key.nullTerminate()
            v : value(parent)
            --c--
            v.v = &_parent->d[(char*)key->data.data];
            --c--
            v
        }
    ) { 
        this 
    } copy {
        --c--
        _this->d.CopyFrom(_from->d, _this->d.GetAllocator());
        --c--
    } destroy { }

    value(
        root : 'document
        --cvar--
        rapidjson::Value* v;
        --cvar--

        asi32() {
            --c--
            #return(i32, _parent->v->GetInt())
            --c--
        }

        asu32() {
            --c--
            #return(u32, _parent->v->GetUint())
            --c--
        }

        asi64() {
            --c--
            #return(i64, _parent->v->GetInt64())
            --c--
        }

        asu64() {
            --c--
            #return(u64, _parent->v->GetUint64())
            --c--
        }

        asf32() {
            --c--
            #return(f32, _parent->v->GetFloat())
            --c--
        }

        asf64() {
            --c--
            #return(f64, _parent->v->GetDouble())
            --c--
        }

        asString() {
            data := nullptr
            count := 0
            dataSize := 0
            --c--
            count = _parent->v->GetStringLength();
            datasize = (((count - 1) / 256) + 1) * 256;
            data = (char*)malloc(datasize);
            memcpy(data, _parent->v->GetString(), count);
            --c--
            string(count := count, data := array!char(dataSize := dataSize, data := data, count := count))
        }
    ) { 
        this 
    } copy {
        --c--
        _this->v = _from->v;
        --c--
    } destroy { }
// }