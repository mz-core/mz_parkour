MZParkourConfig = {
    Enabled = true,
    Debug = false,
    StateKey = 'mz:parkour',

    -- Esta versão usa a tarefa nativa do GTA V. Ela escolhe e executa a
    -- animação de vault/escalada do próprio jogo, evitando congelar ou
    -- reposicionar o ped manualmente.
    Mode = 'native_taskclimb',

    Controls = {
        Trigger = 22 -- SPACE / salto
    },

    NativeTaskClimb = {
        Enabled = true,
        ReachLength = 1.10,
        CooldownMs = 650,
        InputDebounceMs = 120,
        StartTimeoutMs = 650,
        MaximumDurationMs = 4200,
        RequireAirborne = true,
        RequireSecondJumpPress = true,
        ClearTasksBeforeClimb = true,
        DisableJumpAfterTriggerMs = 240,

        Probe = {
            CollisionFlags = 17,
            Radius = 0.18,
            ChestHeight = 0.85,
            UpperHeight = 1.35,
            ForwardStart = 0.10,
            ForwardEnd = 1.10,
            MaximumWallNormalZ = 0.55,
            ResultTimeoutFrames = 30
        }
    },

    -- O controlador antigo fica disponível apenas como fallback técnico.
    -- Não o ative junto com NativeTaskClimb.
    LegacyHanging = {
        Enabled = false
    },

    RestrictedStateKeys = {
        'dead',
        'cuffed',
        'handcuffed',
        'carrying',
        'beingCarried',
        'inventoryBusy',
        'menuBusy'
    },

    Notifications = {
        Prefix = '~b~MZ Parkour~s~',
        Enabled = 'Parkour ativado.',
        Disabled = 'Parkour desativado.',
        NoLedge = 'Nenhum obstáculo escalável foi encontrado.',
        DebugOn = 'Debug ativado.',
        DebugOff = 'Debug desativado.'
    }
}
