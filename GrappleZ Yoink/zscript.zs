version "4.10.0"

// ============================================================================
// GRAPPLEZ YOINK - Instant-Pull Grappling Hook System
// ============================================================================

// HookShooter - Inventory item that fires the hook
class HookShooter : CustomInventory
{
    States
    {
        Pickup:
            TNT1 A 0 A_FireProjectile("HookShot", 0, 0);
            Stop;
    }
}

// Grappling Hook Event Handler with Cooldown System
class GrapplingHookHandler : EventHandler
{
    // Per-player cooldown tracking
    Array<double> playerLastFireTime;

    override void OnRegister()
    {
        // Initialize cooldown arrays for all players
        playerLastFireTime.Clear();
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            playerLastFireTime.Push(0.0);
        }
    }

    override void WorldLoaded(WorldEvent e)
    {
        // Reset cooldowns when map loads
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (i < playerLastFireTime.Size())
            {
                playerLastFireTime[i] = 0.0;
            }
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name == "grapplez_yoink_fire")
        {
            if (!playeringame[e.Player])
                return;

            PlayerInfo player = players[e.Player];
            if (!player || !player.mo)
                return;

            // Check if hookshot is allowed via CVar
            CVar allowCVar = CVar.GetCVar('sv_allowhookshot', player);
            if (allowCVar && !allowCVar.GetBool())
                return;

            // Check cooldown
            CVar cooldownCVar = CVar.GetCVar('grapplez_cooldown', player);
            double cooldownSeconds = cooldownCVar ? cooldownCVar.GetFloat() : 0.8;

            double currentTime = double(level.totaltime) / 35.0; // Convert tics to seconds
            double lastFireTime = playerLastFireTime[e.Player];
            double timeSinceFire = currentTime - lastFireTime;

            if (timeSinceFire < cooldownSeconds)
            {
                // Still on cooldown
                return;
            }

            // Update last fire time
            playerLastFireTime[e.Player] = currentTime;

            // Give the player the HookShooter inventory item which fires the hook
            player.mo.GiveInventory("HookShooter", 1);
        }
    }
}

// ============================================================================
// HOOK TRAIL - Visual effect actor for the grappling chain
// ============================================================================

class HookTrail : Actor
{
    Default
    {
        +NOINTERACTION  // No collision, no physics
        +NOBLOCKMAP     // Don't add to blockmap
        +NOGRAVITY      // Don't fall
        RenderStyle "Translucent";
        Alpha 0.8;
    }

    States
    {
        Spawn:
            CCTT A -1;
            Stop;
    }
}

// ============================================================================
// HOOK SHOT - Instant-Yank Grappling Hook Projectile
// ============================================================================

class HookShot : FastProjectile
{
    Vector3 originPos;  // Starting position for range checking
    Array<Actor> trailActors;  // Visual trail chain
    const TRAIL_COUNT = 10;

    Default
    {
        Height 14;
        Radius 10;
        Projectile;
        +HITTRACER
        +PAINLESS
        MaxTargetRange 10;
        MaxStepHeight 4;
        SeeSound "hookshot/fire";
        ActiveSound "hookshot/swish";
        Speed 40;
        Damage 0;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Store origin position for range checking
        originPos = pos;

        // Spawn trail actors
        trailActors.Clear();
        for (int i = 0; i < TRAIL_COUNT; i++)
        {
            Actor trail = Actor.Spawn("HookTrail", (0, 0, 0));
            if (trail)
            {
                trailActors.Push(trail);
            }
        }
    }

    override void OnDestroy()
    {
        // Clean up trail actors when hook is destroyed
        for (int i = 0; i < trailActors.Size(); i++)
        {
            Actor trail = trailActors[i];
            if (trail && !trail.bDESTROYED)
            {
                trail.Destroy();
            }
        }
        trailActors.Clear();

        Super.OnDestroy();
    }

    void UpdateTrailPositions()
    {
        if (!target)
            return;

        Actor playerActor = target;

        // Calculate vector from player to hook
        Vector3 playerPos = playerActor.pos + (0, 0, playerActor.height * 0.5);  // Player center
        Vector3 hookPos = pos;

        double dx = hookPos.x - playerPos.x;
        double dy = hookPos.y - playerPos.y;
        double dz = hookPos.z - playerPos.z;

        // Calculate angle for sprite rotation
        double angle = atan2(dy, dx) * (180.0 / 3.14159265);

        // Position each trail actor evenly along the chain
        for (int i = 0; i < trailActors.Size(); i++)
        {
            Actor trail = trailActors[i];
            if (!trail || trail.bDESTROYED)
                continue;

            // Calculate position along the line (i+1 to avoid placing at player position)
            double t = double(i + 1) / double(TRAIL_COUNT + 1);

            Vector3 trailPos;
            trailPos.x = playerPos.x + dx * t;
            trailPos.y = playerPos.y + dy * t;
            trailPos.z = playerPos.z + dz * t;

            trail.SetOrigin(trailPos, false);
            trail.angle = angle;
        }
    }

    States
    {
        Spawn:
            OCLW AA 2
            {
                A_PlaySound("hookshot/loop", CHAN_BODY);

                // Update visual trail positions
                invoker.UpdateTrailPositions();

                // Check max range during flight
                if (target && target.player)
                {
                    PlayerInfo player = target.player;
                    CVar maxRangeCVar = CVar.GetCVar('grapplez_max_range', player);
                    double maxRange = maxRangeCVar ? maxRangeCVar.GetFloat() : 2048.0;

                    // Calculate 3D distance from origin
                    double dx = pos.x - originPos.x;
                    double dy = pos.y - originPos.y;
                    double dz = pos.z - originPos.z;
                    double distFromOrigin = sqrt(dx * dx + dy * dy + dz * dz);

                    if (distFromOrigin > maxRange)
                    {
                        // Exceeded range - destroy without yanking
                        Destroy();
                        return;
                    }
                }
            }
            Loop;

        Crash:
            CCLW A 0 A_PlaySound("hookshot/hit/terrain");
            Goto RealDeath;

        XDeath:
            CCLW A 0 A_PlaySound("hookshot/hit/flesh");
            Goto RealDeath;

        RealDeath:
            CCLW A 0 A_HookHitEnemy();
            CCLW A 16;
            Stop;

        Death:
            CCLW A 0 A_PlaySound("hookshot/hit/terrain");
            CCLW A 0 A_HookHitWall();
            CCLW A 16;
            Stop;
    }

    // Pull player toward wall
    action void A_HookHitWall()
    {
        if (!target || !target.player)
            return;

        PlayerInfo player = target.player;
        Actor playerActor = target;
        Actor hook = self;

        // Check if item pulling is enabled - if so, pull nearby items even on wall hits
        CVar itemYoinkCVar = CVar.GetCVar('grapplez_yoink_items', player);
        bool itemYoinkEnabled = itemYoinkCVar ? itemYoinkCVar.GetBool() : false;

        if (itemYoinkEnabled)
        {
            // Pull all items in a radius around the hook impact point
            PullNearbyItems(player, playerActor, hook);
        }

        // Check if wall yanking is enabled
        CVar wallYoinkCVar = CVar.GetCVar('grapplez_yoink_walls', player);
        if (wallYoinkCVar && !wallYoinkCVar.GetBool())
            return; // Wall yanking disabled

        // Get pull strength
        CVar strengthCVar = CVar.GetCVar('grapplez_wall_pull_strength', player);
        double strength = strengthCVar ? strengthCVar.GetFloat() : 1.0;

        // Calculate distance and angle FROM player TO hook
        double dist = playerActor.Distance2D(hook);
        double angle = playerActor.AngleTo(hook);
        double zDiff = hook.pos.z - playerActor.pos.z;

        // Apply instant yank impulse (scaled by strength)
        playerActor.Vel.XY += AngleToVector(angle, (dist / 12.0) * strength);
        playerActor.Vel.Z += (zDiff / 4.0) * strength;
    }

    // Helper: Pull all items in radius around hook impact
    action void PullNearbyItems(PlayerInfo player, Actor playerActor, Actor hook)
    {
        CVar itemStrengthCVar = CVar.GetCVar('grapplez_item_pull_strength', player);
        double itemStrength = itemStrengthCVar ? itemStrengthCVar.GetFloat() : 1.0;

        // Search radius - generous enough to catch items near hook impact
        double searchRadius = 128.0;

        // Iterate through all nearby actors
        BlockThingsIterator it = BlockThingsIterator.Create(hook, searchRadius);
        Actor mo;

        while (it.Next())
        {
            mo = it.thing;
            if (!mo || mo.bDESTROYED)
                continue;

            // Check if this is an item (Inventory)
            if (!(mo is "Inventory"))
                continue;

            // Skip if it's already been picked up or is not available
            Inventory item = Inventory(mo);
            if (!item || item.Owner)
                continue; // Already owned by someone

            // Calculate distance to hook impact point
            double distToHook = mo.Distance3D(hook);
            if (distToHook > searchRadius)
                continue;

            // Calculate pull vector FROM item TO player
            double dist = mo.Distance2D(playerActor);
            double angle = mo.AngleTo(playerActor);
            double zDiff = playerActor.pos.z - mo.pos.z;

            // Apply yank impulse to item
            mo.Vel.XY += AngleToVector(angle, (dist / 12.0) * itemStrength);
            mo.Vel.Z += (zDiff / 2.0) * itemStrength;

            // Make sure item can be moved
            mo.bNOGRAVITY = false; // Re-enable gravity so it falls naturally after pull
        }
    }

    // Pull enemy toward player (or player to enemy, based on weight)
    action void A_HookHitEnemy()
    {
        if (!target || !target.player)
            return;

        PlayerInfo player = target.player;
        Actor playerActor = target;
        Actor hook = self;

        // Check if item pulling is enabled - if so, pull nearby items regardless of direct hit
        CVar itemYoinkCVar = CVar.GetCVar('grapplez_yoink_items', player);
        bool itemYoinkEnabled = itemYoinkCVar ? itemYoinkCVar.GetBool() : false;

        if (itemYoinkEnabled)
        {
            // Pull all items in a radius around the hook impact point
            PullNearbyItems(player, playerActor, hook);
        }

        // Get the tracer (actor that was hit)
        if (!tracer)
            return;

        Actor hitActor = tracer;

        // Check if we hit an enemy (items are handled via AoE above)
        bool isEnemy = (hitActor.bSHOOTABLE || hitActor.bPUSHABLE) && !(hitActor is "Inventory");

        // Check target filtering CVARs
        CVar enemyYoinkCVar = CVar.GetCVar('grapplez_yoink_enemies', player);
        bool enemyYoinkEnabled = enemyYoinkCVar ? enemyYoinkCVar.GetBool() : true;

        if (isEnemy)
        {
            // Hit an enemy
            if (!enemyYoinkEnabled)
                return; // Enemy yanking disabled

            // Get pull mode and weight calculation settings
            CVar pullModeCVar = CVar.GetCVar('grapplez_pull_mode', player);
            int pullMode = pullModeCVar ? pullModeCVar.GetInt() : 0;

            CVar weightCalcCVar = CVar.GetCVar('grapplez_weight_calculation', player);
            int weightCalcMethod = weightCalcCVar ? weightCalcCVar.GetInt() : 0;

            // Calculate enemy weight
            double weight = GetActorWeight(hitActor, weightCalcMethod == 1);
            int weightClass = GetWeightClass(player, weight);

            // Determine pull direction based on mode and weight
            bool pullPlayerToEnemy = false;

            if (pullMode == 0) // Smart Pull
            {
                pullPlayerToEnemy = (weightClass == 2); // WEIGHT_HEAVY
            }
            else if (pullMode == 1) // Always Pull Enemy
            {
                pullPlayerToEnemy = false;
            }
            else if (pullMode == 2) // Always Pull Player
            {
                pullPlayerToEnemy = true;
            }

            if (pullPlayerToEnemy)
            {
                // Pull player toward enemy (heavy enemy)
                CVar wallStrengthCVar = CVar.GetCVar('grapplez_wall_pull_strength', player);
                double strength = wallStrengthCVar ? wallStrengthCVar.GetFloat() : 1.0;

                double dist = playerActor.Distance2D(hitActor);
                double angle = playerActor.AngleTo(hitActor);
                double zDiff = hitActor.pos.z - playerActor.pos.z;

                playerActor.Vel.XY += AngleToVector(angle, (dist / 12.0) * strength);
                playerActor.Vel.Z += (zDiff / 4.0) * strength;
            }
            else
            {
                // Pull enemy toward player (light/medium enemy)
                CVar enemyStrengthCVar = CVar.GetCVar('grapplez_enemy_pull_strength', player);
                double baseStrength = enemyStrengthCVar ? enemyStrengthCVar.GetFloat() : 1.0;

                // Scale strength by weight class
                double strength = CalculatePullStrength(baseStrength, weightClass);

                double dist = hitActor.Distance2D(playerActor);
                double angle = hitActor.AngleTo(playerActor);
                double zDiff = playerActor.pos.z - hitActor.pos.z;

                hitActor.Vel.XY += AngleToVector(angle, (dist / 12.0) * strength);
                hitActor.Vel.Z += (zDiff / 2.0) * strength;
            }
        }
    }

    // Helper: Get actor weight
    static double GetActorWeight(Actor a, bool useHealth)
    {
        if (useHealth)
        {
            return a.SpawnHealth();
        }
        else
        {
            return a.Mass;
        }
    }

    // Helper: Determine weight class
    static int GetWeightClass(PlayerInfo player, double weight)
    {
        CVar lightThreshCVar = CVar.GetCVar('grapplez_light_threshold', player);
        double lightThresh = lightThreshCVar ? lightThreshCVar.GetFloat() : 550.0;

        CVar heavyThreshCVar = CVar.GetCVar('grapplez_heavy_threshold', player);
        double heavyThresh = heavyThreshCVar ? heavyThreshCVar.GetFloat() : 900.0;

        if (weight < lightThresh)
            return 0; // WEIGHT_LIGHT
        else if (weight < heavyThresh)
            return 1; // WEIGHT_MEDIUM
        else
            return 2; // WEIGHT_HEAVY
    }

    // Helper: Calculate pull strength based on weight class
    static double CalculatePullStrength(double baseStrength, int weightClass)
    {
        double scale = 1.0;

        if (weightClass == 0) // WEIGHT_LIGHT
            scale = 1.5;  // 50% stronger pull
        else if (weightClass == 1) // WEIGHT_MEDIUM
            scale = 1.0;  // Normal pull
        else if (weightClass == 2) // WEIGHT_HEAVY
            scale = 0.5;  // 50% weaker pull

        return baseStrength * scale;
    }
}
