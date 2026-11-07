package b

import "gitee.com/ivfzhou/learning/golang/language_specification/mvs/c"

func Version() string {
	_ = c.Version()
	return "v1.2.0"
}
