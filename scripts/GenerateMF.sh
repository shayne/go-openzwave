#!/usr/bin/env bash

PREFIX=MF

enumerate()
{
cat <<EOF
AEON_LABS 0086 
EOF
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

const UNKNOWN = "ffff"
var UNKNOWN_ENUM = Enum{UNKNOWN, "$PREFIX.ENUM"}

const (
$(x=0; enumerate | while read code value; do echo "   $code = \"$value\""; let x=x+1; done)
)

var enums = [...]Enum{
$(x=0; enumerate | while read code value; do echo "      { $code, \"$PREFIX.$code\" },"; let x=x+1; done)
		UNKNOWN_ENUM }

type Enum struct {
     Code string
     Name string
}


func ToEnum(code string) *Enum {	
     var needle *Enum = nil;
     for _, e := range enums {
       if code == e.Code {
         needle = &e
         break;
       }
     }
     if needle == nil {
        needle = &UNKNOWN_ENUM
     } 
     return needle
}

func (val Enum) IsValid() bool {
    return val != UNKNOWN_ENUM
}

func (val Enum) String() string {
     if val.IsValid() {
	return val.Name
     } else { 
        return fmt.Sprintf("%s[%d]", UNKNOWN_ENUM.Name, val.Code);
     }	
}

EOF
gofmt -s -w $PREFIX/$PREFIX.go && cd $PREFIX && go install 
