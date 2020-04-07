package coturn

import (
	"io"
	"time"
)

type UserDB interface {
	io.Closer
	AddLongTermCred(realm, user, cred string, ttl time.Duration) error
}
