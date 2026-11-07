package f

import "gitee.com/ivfzhou/learning/golang/language_specification/mvs/e"

func Version() string {
	_ = e.Version()
	return "v1.1.0"
}
