using { Containers }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Teams }
using { /Verse.org/Concurrency }
using { /Verse.org/Simulation }

# Getter for session playspace instance.
Playspace<public>()<transacts>: playspace = SessionPlayspace[GetSession()] or Err("Playspace not set.")

# A safe fort_playspace wrapper. Each session has one global reference to a playspace.
#TODO write method for getting creative objects in a playspace.
playspace<public> := class<internal><final>:
    TeamCollection: fort_team_collection

    ParticipantAddEvent<private>: event(agent) = event(agent){}
    ParticipantRemoveEvent<private>: event(agent) = event(agent){}

    var ParticipantRemovedEventMap<private>: [agent]event(agent) = map{}
    var Participants<private>: []agent = array{}

    # Some agents inside the referenced fort_team_collection may not be initialized in this playspace.
    #TODO Write fort_team_collection wrapper and return that reference instead.
    GetTeamCollection<public>()<transacts>: fort_team_collection = TeamCollection

    ParticipantAddedEvent<public>()<transacts>: awaitable(agent) = ParticipantAddEvent

    ParticipantRemovedEvent<public>()<transacts>: awaitable(agent) = ParticipantRemoveEvent

    ParticipantRemovedEvent<public>(Participant: agent)<decides><transacts>: awaitable(agent) = ParticipantRemovedEventMap[Participant]

    GetParticipants<public>()<transacts>: []agent = Participants

    OnParticipantAdded(Participant: agent): void =
        RemoveEvent := event(agent){}
        (set ParticipantRemovedEventMap[Participant] = RemoveEvent) or ()
        if (Player := player[Participant]):
            spawn:
                HandleAddedPlayer(Player, RemoveEvent)
            return
        OnParticipantReady(Participant)

    OnParticipantRemoved(Participant: agent): void =
        set Participants = Participants.RemoveFirstElement[Participant] or Participants
        set ParticipantRemovedEventMap = ParticipantRemovedEventMap.RemoveKey[Participant] or ParticipantRemovedEventMap
        ParticipantRemoveEvent.Signal(Participant)

    OnParticipantReady<private>(Participant: agent): void =
        set Participants += array { Participant }
        ParticipantAddEvent.Signal(Participant)

    HandleAddedPlayer<private>(Player: player, RemovedEvent: event(agent))<suspends>: void =
        race:
            loop:
                if (Player.IsActive[]):
                    OnParticipantReady(Player)
                    return
                Sleep(0.0)
            RemovedEvent.Await()

var SessionPlayspace: weak_map(session, playspace) = map{}

SetPlayspace(FortPlayspace: fort_playspace)<suspends>: void =
    (local:)Playspace := playspace { TeamCollection := FortPlayspace.GetTeamCollection() }
    (set SessionPlayspace[GetSession()] = (local:)Playspace) or ()
    FortPlayspace.ParticipantAddedEvent().Subscribe((local:)Playspace.OnParticipantAdded)
    FortPlayspace.ParticipantRemovedEvent().Subscribe((local:)Playspace.OnParticipantRemoved)
    Sleep(0.0)
    for (Participant : FortPlayspace.GetParticipants()):
        (local:)Playspace.OnParticipantAdded(Participant)
