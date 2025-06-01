Containers<public> := module:
    (Map: [k]v where k: subtype(comparable), v: type).(Containers:)RemoveKey<public>(Target: k)<decides><transacts>: [k]v =
        Map[Target]
        var NewMap: [k]v = map{}
        for (K->V : Map, K <> Target):
            set NewMap[K] = V
        NewMap

    (Map: [k]v where k: subtype(comparable), v: type).GetKeys<public>()<transacts>: []k = 
        for (K->V : Map):
            K