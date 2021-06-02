mutable struct UpdateTimer
    warm_up::Int
    update_wait::Int
    t::Int
    UpdateTimer(warm_up, update_wait) = new(warm_up, update_wait, 0)
end

(ut::UpdateTimer)(replay_len) =
    replay_len >= ut.warm_up && (ut.t % ut.update_wait == 0)

next!(ut::UpdateTimer) = ut.t += 1
restart!(ut::UpdateTimer) = ut.t = 0
