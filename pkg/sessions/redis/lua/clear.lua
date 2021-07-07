--SessionStore Clear(
--  ticketID string)

remove_session(KEYS[1])

-- Success
return redis.status_reply("OK")
