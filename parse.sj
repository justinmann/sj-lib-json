package json {
    parse_whitespace(s : 'string, startIndex : 'i32)'i32 {
        index := startIndex
        isMatched := true
        while index < s.count && isMatched {
            ch : s.getAt(index)
            if ch == '\r' || ch == '\n' || ch == '\t' || ch == ' ' {
                index++
            } else {
                isMatched = false
            }
        }
        index
    }

    parse_string(s : 'string, startIndex : 'i32)'tuple2![i32, string] {
        isEscaped := false
        index := startIndex + 1
        isMatched := false
        while index < s.count && !isMatched {
            ch : s[index]
            if !isEscaped && ch == '\\' {
                isEscaped = true
            } else {
                if ch == '\"' {
                    isMatched = true
                }
                isEscaped = false
            }
            index++
        }
        
        if isMatched {
            (index, s.substr(startIndex, index - startIndex))
        } else {
            (s.count + 1, "")
        }
    }

    parse_number(s : 'string, startIndex : 'i32)'tuple2![i32, string] {
        isEscaped := false
        index := startIndex
        isMatched := true
        while index < s.count && isMatched {
            ch : s[index]
            if (ch >= '0' && ch <= '9') || ch == '.' || (ch >= 'a' && ch <= 'z') {
                index++
            } else {
                isMatched = false
            }
        }
        
        (index, s.substr(startIndex, index - startIndex))
    }

    parse_value(s : 'string, startIndex : 'i32)'tuple2![i32, value] {
        // skip whitespace
        index := parse_whitespace(s, startIndex)
        switch s[index] {
            '{' {
                // hash
                h : hash![string, value]()
                index++
                isFirst := true
                shouldContinue := true
                while index < s.count && shouldContinue {
                    index = parse_whitespace(s, index)
                    if isFirst {
                        isFirst = false
                        if index < s.count && s[index] == '}' {
                            index++
                            shouldContinue = false
                        }
                    } else {
                        if s[index] == ',' {
                            index++
                            index = parse_whitespace(s, index)
                        } else {
                            index = s.count + 1
                        }
                    }

                    if shouldContinue {
                        if index < s.count && s[index] == '\"' {
                            keyResult : parse_string(s, index)
                            index = keyResult.item1 + 1
                            key : if keyResult.item2.count > 0 { keyResult.item2.substr(1, keyResult.item2.count - 2) } else { "" }

                            index = parse_whitespace(s, index)

                            if s[index] == ':' {
                                index++
                            } else {
                                index = s.count + 1
                            }

                            index = parse_whitespace(s, index)

                            valueResult : parse_value(s, index)
                            index = valueResult.item1
                            value : valueResult.item2

                            h[key] = value

                            index = parse_whitespace(s, index)
                            
                            if index < s.count && s[index] == '}' {
                                index++
                                shouldContinue = false
                            }
                        } else {
                            index = s.count + 1
                        }
                    }
                }
                (index, value(h : h))
            }
            '[' {
                // array
                l : list![value]()
                index++
                isFirst := true
                shouldContinue := true
                while index < s.count && shouldContinue {
                    index = parse_whitespace(s, index)
                    if isFirst {
                        isFirst = false
                        if index < s.count && s[index] == ']' {
                            index++
                            shouldContinue = false
                        }
                    } else {
                        if s[index] == ',' {
                            index++
                        } else {
                            index = s.count + 1
                        }
                    }

                    valueResult : parse_value(s, index)
                    index = valueResult.item1
                    value : valueResult.item2

                    l.add(value)

                    index = parse_whitespace(s, index)

                    if index < s.count && s[index] == ']' {
                        index++
                        shouldContinue = false
                    }
                }
                (index, value(a : l.arr))
            }
            '\"' {
                // string
                result : parse_string(s, index)
                (result.item1, value(s : result.item2))
            } 
            default{
                // number
                result : parse_number(s, index)                
                (result.item1, value(s : result.item2))
            }
        }
    }

    parse(s : 'string)'value? {
        result : parse_value(s, 0)
        if result.item1 == s.count {
            valid(optionalCopy result.item2)
        } else {
            empty'value
        }
    }
}