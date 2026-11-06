package protobuf_test

import (
	"fmt"
	"testing"

	"gitee.com/ivfzhou/learning/golang/protobuf"
)

func TestEncode(t *testing.T) {
	fmt.Printf("%b", protobuf.Encode(1))
}
