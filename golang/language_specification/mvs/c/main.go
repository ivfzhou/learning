package c

import "gitee.com/ivfzhou/learning/golang/language_specification/mvs/d"

func Version() string {
	_ = d.Version()
	return "v1.2.0"
}
