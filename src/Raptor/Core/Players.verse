Players<public> := module:
    using { /Verse.org/Simulation }

    # Saves a value string that can be looked up with a key for the player. Returns a 'save_result' representing whether or not the data was able to fit inside the player weak map.
    # Fails if player isn't active.
    (Player: player).Save<public>(Key: string, Value: string)<decides><transacts>: save_result =
        Player.IsActive[]
        if:
            Data := FitsInPlayerMap at persistent_player_data:
                BackingMap := ConcatenateMaps of:
                    PlayerPersistence[Player].BackingMap or map{},
                    map { Key => Value }
        then:
            set PlayerPersistence[Player] = Data
            save_result.Saved
        else:
            save_result.Failed

    # Loads the saved value given a key. Fails if player isn't active.
    (Player: player).LoadSaved<public>(Key: string)<decides><transacts>: string =
        Player.IsActive[]
        PlayerPersistence[Player].BackingMap[Key]

    # Type that represents whether or not a save was successful.
    save_result<public> := enum<internal>:
        Failed
        Saved

    var PlayerPersistence: weak_map(player, persistent_player_data) = map{}

    persistent_player_data := class<final><persistable>:
        BackingMap: [string]string = map{}