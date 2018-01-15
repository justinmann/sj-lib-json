package json {
    value(
        s : empty'string
        a : empty'array!value
        h : empty'hash![string, value]

        getAt(key : 'string)'value? {
            ifValid h {
                h[key]
            } elseEmpty {
                empty'value
            }
        }

        asString()'string {
            ifValid s {
                if s[0] == '\"' && s[s.count - 1] == '\"' {
                    s.substr(1, s.count - 2)
                } else {
                    optionalCopy s
                }
            } elseEmpty {
                ""
            }
        }

        asi32()'i32 {
            asString() as i32
        }

        asf32()'f32 {
            asString() as f32
        }

        asbool()'bool {
            asString() as bool
        }

        render()'string {
            ifValid s {
                optionalCopy s
            } elseEmpty {
                ifValid a {
                    "[ " + a.map!string(^{ _.render() }) as string + " ]"
                } elseEmpty {
                    ifValid h {
                        "{ " + h.asArray!string(^{
                            "\"" + _1 + "\" : " + (_2.render()) 
                        }) as string + " }"
                    } elseEmpty {
                        ""
                    }
                }    
            }
        }

        pretty(level : 0)'string {
            ifValid s {
                optionalCopy s
            } elseEmpty {
                ifValid a {
                    "[" + a.map!string(^{ 
                        "\n" + spaces((level + 1) * 2) + _.pretty(level + 1) 
                    }) as string + "\n" + spaces(level * 2) + "]"
                } elseEmpty {
                    ifValid h {
                        "{" + spaces(level * 2) + h.asArray!string(^{
                            "\n" + spaces((level + 1) * 2) + "\"" + _1 + "\" : " + (_2.pretty(level + 1))
                        }) as string + "\n" + spaces(level * 2) + "}"
                    } elseEmpty {
                        ""
                    }
                }    
            }
        }
    ) { this }
}

allthespaces : "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                "
spaces(count : 'i32) {
    allthespaces.substr(0, count)
}

`string_asjson.value`(x : 'string)'json.value {
    json.value(
        s : "\"" + x + "\""
    )
}

`i32_asjson.value`(x : 'i32)'json.value {
    json.value(
        s : x as string
    )
}

`f32_asjson.value`(x : 'f32)'json.value {
    json.value(
        s : x as string
    )
}

`bool_asjson.value`(x : 'bool)'json.value {
    json.value(
        s : x as string
    )
}

`array!json.value_asjson.value`(x : 'array!json.value)'json.value {
    json.value(
        a : x
    )
}

`hash![string, json.value]_asjson.value`(x : 'hash![string, json.value])'json.value {
    json.value(
        h : x
    )
}