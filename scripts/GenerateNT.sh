#!/usr/bin/env bash

enumerate()
{
    cat openzwave/cpp/src/Notification.h | sed -n "/enum NotificationType/,/}/p" | sed -n "s/^.*Type_//p" | tr -d \\015 | sed "s/[^A-Za-z].*//g"
}

symbol()
{
    local t=$1
    echo $(echo $t | sed "s/\(.\)\([A-Z]\)/\1_\2/g" | tr [a-z] [A-Z])
}

mkdir -p NT && cat > NT/NT.go <<EOF
package NT;

//
// *** generated by scripts/$(basename $0)
//

// DO NOT EDIT THIS FILE

import "fmt"

const (
$(x=0; enumerate | while read t; do echo "   $(symbol $t) = $x"; let x=x+1; done)
)

var names = [...]string{
$(x=0; enumerate | while read t; do echo "      \"NT.$(symbol $t)\","; let x=x+1; done)
		"NT.UNKNOWN" }

const UNKNOWN = len(names)

type Enum struct {
     Code int
     Name string
}

func ToEnum(code int) Enum {	
     var x int;
     if code < 0 || code >= UNKNOWN {
     	x = UNKNOWN-1
     } else {
	x = code
     }	
     return Enum{code,names[x]}
}

func (val Enum) IsValid() bool {
    return val.Code >= 0 && val.Code < UNKNOWN;
}

func (val Enum) String() string {
     if val.IsValid() {
	return val.Name
     } else { 
        return fmt.Sprintf("%s[%d]", names[UNKNOWN-1], val.Code);
     }	
}

EOF
gofmt -s -w NT/NT.go && go build NT/NT.go
