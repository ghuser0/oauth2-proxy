--SessionStore Save(
--  ticketID string,
--  signOutKeys []string,
--  value []byte,
--  exp time.Duration)

-- Save stores the key with this value, with the
-- given expiration, and also updates the sign out
-- keys which index to this key.
local ticket_id = KEYS[1]
local value = ARGV[1]
local exp_at = ARGV[2]
local time_now = ARGV[3]

-- First, remove the existing session and indexes for this
-- ticket ID.  The indexes must be cleared even if we will
-- re-add the same ones later because we need to update their
-- expiration in the sorted set.
remove_session(ticket_id)

-- Next, store the session by its ticket ID.
redis.call("SET", "tckt:" .. ticket_id, value)
redis.call("EXPIREAT", "tckt:" .. ticket_id, exp_at)

-- Finally, add this ticket ID to all of the sign out keys (s2t),
-- and store the list of sign out keys for this ticket ID (t2s),
-- and update the expirations on all s2t keys, cull expired s2t
-- values, and update the expiration on the t2s key.
for i = 2, #KEYS do
    local sign_out_key = KEYS[i]
    redis.call("ZADD", "s2t:" .. sign_out_key, exp_at, ticket_id)
    redis.call("EXPIREAT", "s2t:" .. sign_out_key, exp_at)
    redis.call("ZREMRANGEBYSCORE", "s2t:" .. sign_out_key, 0, time_now)
    redis.call("SADD", "t2s:" .. ticket_id, sign_out_key)
end
redis.call("EXPIREAT", "t2s:" .. ticket_id, exp_at)

-- Success
return redis.status_reply("OK")
