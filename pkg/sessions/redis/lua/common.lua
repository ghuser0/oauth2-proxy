-- Common functions
local function remove_session(ticket_id)
    -- Use the list of existing sign out keys for this ticket ID
    -- (t2s) to remove this ticket ID from any existing sign out
    -- keys (s2t).
    local old_sign_out_keys = redis.call("SMEMBERS", "t2s:" .. ticket_id)
    for i = 1, #old_sign_out_keys do
        local sign_out_key = old_sign_out_keys[i]
        redis.call("ZREM", "s2t:" .. sign_out_key, ticket_id)
        redis.call("SREM", "t2s:" .. ticket_id, sign_out_key)
    end

    -- Remove the session itself
    redis.call("DEL", "tckt:" .. ticket_id)
end
