#!/usr/bin/env bash

PREFIX=VT

enumerate()
{
    cat openzwave/cpp/src/value_classes/ValueID.h | grep ValueType_ | grep -v _Max | sed "s/.*_//" | sed "s/^\([A-Za-z]*\).*/\1/" | number
}

number()
{
    local x
    x=0; while read n; do echo $x $n; let x=x+1; done
}

symbol()
{
    local t=$1
    echo $(echo $t | sed "s/\(.\)\([A-Z]\)/\1_\2/g" | tr [a-z] [A-Z])
}

mkdir -p $PREFIX && cat > $PREFIX/$PREFIX.go <<EOF
package $PREFIX;

//
// *** generated by scripts/$(basename $0)
//

// DO NOT EDIT THIS FILE

import "fmt"

const (
$(enumerate | while read x n; do echo "   $(symbol $n) = $x"; done)
)

var UNKNOWN_ENUM = Enum{ -1, "UNKNOWN" }

var enums = [...]Enum{
$(enumerate | while read x n; do echo "      Enum{ $x, \"$PREFIX.$(symbol $n)\" },"; done)
		UNKNOWN_ENUM }

const UNKNOWN = len(enums)-1

type Enum struct {
     Code int
     Name string
}

func ToEnum(code int) *Enum {	
     var x int;
     if code < 0 || code >= UNKNOWN {
     	x = UNKNOWN
     } else {
	x = code
     }	
     return &enums[x]
}

func (val Enum) IsValid() bool {
    return val.Code >= 0 && val.Code < UNKNOWN;
}

func (val Enum) String() string {
     if val.IsValid() {
	return val.Name
     } else { 
        return fmt.Sprintf("%s[%d]", enums[UNKNOWN].Name, val.Code);
     }	
}

EOF
gofmt -s -w $PREFIX/$PREFIX.go && cd $PREFIX && go install 
