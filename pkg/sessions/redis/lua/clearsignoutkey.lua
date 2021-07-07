--SessionStore ClearSignOutKey(
--  signOutKey string)
local sign_out_key = KEYS[1]

-- Remove all keys that are indexed to by this sign out key
local ticket_ids = redis.call("ZRANGE", "s2t:" .. sign_out_key, 0, -1)
for i = 1, #ticket_ids do
    remove_session(ticket_ids[i])
end

-- Success
return redis.status_reply("OK")
