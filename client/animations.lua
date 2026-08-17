-- A versão 0.2 não força clipes manualmente. TASK_CLIMB seleciona e executa
-- as animações nativas adequadas ao obstáculo detectado pelo próprio GTA V.
MZParkourAnimations = MZParkourAnimations or {}

function MZParkourAnimations.Stop(ped, immediate)
    if immediate then
        ClearPedTasksImmediately(ped)
    else
        ClearPedTasks(ped)
    end
end
