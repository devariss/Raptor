Runtime<public> := module:
    using { /Fortnite.com/Devices }
    using { /Verse.org/Concurrency }
    using { /Verse.org/Simulation }

    # Getter for session runtime instance.
    GetRuntime<public>()<transacts>: runtime = SessionRuntime[GetSession()] or Err("Runtime not set.")

    # A creative device that safely interacts with this module.
    runtime_device<public> := class(creative_device):
        var OptRuntimeRef<private>: ?runtime = false

        OnBegin<override><final>()<suspends>: void =
            if (not SessionRuntime[GetSession()]):
                (local:)Runtime := runtime{}
                set OptRuntimeRef = option { (local:)Runtime }
                (set SessionRuntime[GetSession()] = (local:)Runtime) or ()
                spawn:
                    Playspaces.SetPlayspace((/Fortnite.com/Devices:)GetPlayspace())
            OnStart()

        OnEnd<override><final>(): void =
            if ((local:)Runtime := OptRuntimeRef?):
                (local:)Runtime.InternalEndEvent.Signal()

        # Device entry point after this module has been set up. Defers on session end.
        OnStart<protected>()<suspends>: void = {}

    # Represents the runtime of a session. 
    runtime<public> := class<internal><final>:
        InternalEndEvent: event(void) = event(void){}

        # Event that's signaled on session end.
        EndEvent<public>()<transacts>: awaitable(void) = InternalEndEvent

    var SessionRuntime: weak_map(session, runtime) = map{}