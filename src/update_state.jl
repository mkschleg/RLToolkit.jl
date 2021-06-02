mutable struct UpdateState{LT, GT, PST, OPT}
    loss::LT
    grads::GT
    params::PST
    opt::OPT
end

UpdateState() = UpdateState(nothing, nothing, nothing, nothing)
