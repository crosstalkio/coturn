package goredis

import (
	"crypto/md5"
	"fmt"
	"time"

	"github.com/crosstalkio/coturn"
	"github.com/crosstalkio/log"
	"github.com/go-redis/redis"
)

type redisUserDB struct {
	log.Sugar
	client *redis.Client
}

func NewUserDB(logger log.Logger, options *redis.Options) (coturn.UserDB, error) {
	db := &redisUserDB{
		Sugar:  log.NewSugar(logger),
		client: redis.NewClient(options),
	}
	_, err := db.client.Ping().Result()
	if err != nil {
		db.Errorf("Failed to ping redis: %s", err.Error())
		return nil, err
	}
	return db, nil
}

func (db *redisUserDB) Close() error {
	return db.client.Close()
}

func (db *redisUserDB) AddLongTermCred(realm, user, cred string, ttl time.Duration) error {
	data := []byte(fmt.Sprintf("%s:%s:%s", user, realm, cred))
	val := fmt.Sprintf("%x", md5.Sum(data))
	key := fmt.Sprintf("turn/realm/%s/user/%s/key", realm, user)
	db.Infof("Adding long-term credential to redis: %s (TTL=%v)", key, ttl)
	err := db.client.Set(key, val, ttl).Err()
	if err != nil {
		db.Errorf("Failed to set '%s' to redis: %s", key, err.Error)
		return err
	}
	return nil
}
