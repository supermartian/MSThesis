-------------------------------- MODULE Det --------------------------------

(***************************************************************************)
(* An algorithm for replicating multi-threaded applications as done in     *)
(* replicated Popcorn.  The application is made deterministic through the  *)
(* use of logical time.  Any inter-thread synchronization operation must   *)
(* be protected by calls to EnterSync and ExitSync.  Reads of the socket   *)
(* API are modeled by EnterRead.  The scheduler processes (one per kernel) *)
(* makes sure that the different copies of the application are consistent. *)
(***************************************************************************)


EXTENDS Naturals, Sequences, Integers, Library

CONSTANTS Pid, MaxTime, Kernel, SchedulerPID, Requests

ASSUME  SchedulerPID \notin Pid

InitLogTime == 1
LogTime == InitLogTime..MaxTime \* The set of logical time values

(***************************************************************************)
(* Processes are of the form <<k,pid>>, where k is the kernel the process  *)
(* is running on.                                                          *)
(***************************************************************************)
P == Kernel \times Pid
Primary == CHOOSE k \in Kernel : TRUE
Ker(p) == p[1]
PID(p) == p[2]
OnKernel(kernel) == {kernel} \times Pid

(***************************************************************************)
(* Logical time comparison, using PIDs to break ties.                      *)
(***************************************************************************)
Less(p, tp, q, tq) == 
    tp < tq \/ (tp = tq /\ PID(p) <= PID(q))

(***************************************************************************)
(* The sequence of TCP packets that will be received.  No duplicates       *)
(* allowed (therefore the set TcpData must be big enough) so that any      *)
(* misordering of the threads will lead to a different data read.          *)
(* For TCPMultiStream, each stream has different data.                     *)
(***************************************************************************)
StreamLength == 3
TcpData == 1..StreamLength*Requests
TcpStream == [i \in 1..StreamLength |-> i]
TcpMultiStream == [r \in 1..Requests |-> 
            ([i \in 1..StreamLength |-> i + (StreamLength * (r-1))])]
ASSUME NoDup(TcpStream)
ASSUME Len(TcpStream) = StreamLength

(***************************************************************************)
(* Shifts a sequence by 1: Shift(<<1,2,3>>) = <<2,3>> and Shift(<<>>) =    *)
(* <<>>.                                                                   *)
(***************************************************************************)
Shift(s) == 
    IF Len(s) > 1
    THEN [i \in 1..(Len(s)-1) |-> s[i+1]]
    ELSE <<>>

Shiftn(s) == 
    IF Len(s) > 1
    THEN [i \in 1..(Len(s)-1) |-> s[i+1]]
    ELSE <<-1>>   
    
(***************************************************************************)
(* The algorithm ReadAppend models a set of worker threads being scheduled *)
(* by the deterministic scheduler and executing the following code.        *)
(*                                                                         *)
(*     Code of worker w: While(true) {                                     *)
(*         x = read(socket);                                               *)
(*         append(<<w,x>>,file);                                           *)
(*     }                                                                   *)
(*                                                                         *)
(* Variables:                                                              *)
(*                                                                         *)
(* The variable bumps records all logical time bumps executed by the       *)
(* primary in order for the secondaries to do the same, i.e.  the initial  *)
(* logical time, the new logical time, and the value read from the tcp     *)
(* buffer.  <<t1,t2,d>> \in bumps[pid] means that the primary bumped       *)
(* process pid from logical time t1 to t2 and delivered the data d.  Note  *)
(* that the scheduler set bumps[pid] to a value that depends on the        *)
(* logical time of the processes on all replicas, and this value is then   *)
(* immediately available to all replicas.  A more detailed model would     *)
(* instead include a distributed implementation of the choice of the       *)
(* logical time to bump the process to.                                    *)
(*                                                                         *)
(* reads[p] stores the last value read by p from the socket.               *)
(*                                                                         *)
(* tcpBuff[k] represents the state of the tcp buffer on kernel k.  Each    *)
(* time a process reads from the buffer, the buffer shrinks by 1.          *)
(*                                                                         *)
(* Definitions:                                                            *)
(*                                                                         *)
(* Bumped(kernel) is the set of processes running on the kernel "kernel"   *)
(* which are waiting to execute a "bump" decided by the primary.           *)
(*                                                                         *)
(* If p \in Bumped(Ker(p)) then BumpedTo(p) is the logical time to which p *)
(* should be bumped to.                                                    *)
(*                                                                         *)
(* If p \in WaitingSync(Ker(p)) then IsNextProc(kernel, p) is true iff p   *)
(* is the process to be scheduled next, that is: (1) p has the lowest      *)
(* ltime among running and waiting-sync processes and (2) if q is on the   *)
(* same kernel and q is waiting for a read and the primary has already     *)
(* decided to which logical time tq to bump q, then ltime[p] must be less  *)
(* than tq.                                                                *)
(*                                                                         *)
(* BumpTo is the logical time to which to bump a process that needs        *)
(* bumping.  It is some logical time greater than all the logical times    *)
(* reached by any process on any kernel.                                   *)
(***************************************************************************)
    
(*
--algorithm ReadAppend {
    variables 
        status = [p \in P |-> "running"], 
        ltime = [p \in P |-> InitLogTime], 
        file = [k \in Kernel |-> <<>>],
        bumps = [p \in Pid |-> {}],
        reads = [p \in P |-> -1],
        tcpBuff = [k \in Kernel |-> TcpMultiStream],
        \* Queue for accepted connections  
        socketQueue = [k \in Kernel |-> <<>>],
        \* Queue for unhandled connections
        requestQueue = [k \in Kernel |-> [ r \in 1..Requests |-> r]],
        \* The socket that is handled by a process
        handledSocket = [p \in P |-> -1],
        connections = [k \in Kernel |-> <<>>]
    
    define {
        Run(p) == status[p] = "running"
        Running(kernel) == { p \in OnKernel(kernel) : Run(p) }
        WaitingSync(kernel) == 
            { p \in OnKernel(kernel) : status[p] = "waiting sync" }
        WaitingRead(kernel) == 
            { p \in OnKernel(kernel) : status[p] = "waiting read" }          
        Bumped(kernel) == {p \in OnKernel(kernel) : 
            /\  status[p] = "waiting read"
            /\  \E t \in LogTime : \E d \in TcpData : <<ltime[p],t,d>> \in bumps[PID(p)]}
        BumpedTo(p) == 
            CHOOSE t \in LogTime : \E d \in TcpData : <<ltime[p],t,d>> \in bumps[PID(p)]
        BumpData(p) ==
            CHOOSE d \in TcpData : \E t \in LogTime : <<ltime[p],t,d>> \in bumps[PID(p)]
        IsNextProc(kernel, p) ==
            /\  \A q \in Running(kernel) \cup WaitingSync(kernel) : 
                    q # p => Less(p, ltime[p], q, ltime[q])
            /\  \A q \in Bumped(kernel) : Less(p, ltime[p], q, BumpedTo(q))
        BumpTo == CHOOSE i \in LogTime : \A p \in P : ltime[p] < i 
    }

    macro EnterRead(p) {
        status[p] := "waiting read";
    }
    macro EnterSync(p) {
        status[p] := "waiting sync";
    }
    macro ExitSync(p) {
        ltime[p] := ltime[p]+1;
    }
    
    (* Processes consume a connection *)
    process (worker \in P) {
            ww1: while (TRUE) {
                    EnterSync(self);
            ww2:    await Run(self);
            ww3:    if(Len(requestQueue[Ker(self)]) > 0) {
                        handledSocket[self] := requestQueue[Ker(self)][1];
                        requestQueue[Ker(self)] := Shift(requestQueue[Ker(self)]);
                    };
            ww4:    ExitSync(self);
            ww5:    if (handledSocket[self] # -1) {
                    ww9:    while (Len(tcpBuff[Ker(self)][handledSocket[self]]) > 0) {
                                EnterRead(self);
                        ww10:   await Run(self);
                                EnterSync(self);
                        ww11:   await Run(self);
                                file[Ker(self)] :=
                                    Append(file[Ker(self)], <<PID(self), reads[self]>>);
                        ww12:   ExitSync(self);
                        }
                    };
            ww13:   handledSocket[self] := -1;
            };
        }
    
    process (scheduler \in {<<k,SchedulerPID>> : k \in Kernel}) { 
        s1: while (TRUE) {
                either { \* Schedule a process waiting for synchronization:
                    with (p \in {p \in WaitingSync(Ker(self)) : 
                            IsNextProc(Ker(self), p)}) {
                        status[p] := "running" }}
                or { \* Bump a process waiting for a read:
                    with (p \in WaitingRead(Ker(self))) {
                        if (Ker(self) = Primary) { \* On the primary.
                        (* Record the bump for the secondaries. *)
                            bumps[PID(p)] := 
                                bumps[PID(p)] \cup {<<ltime[p], BumpTo, tcpBuff[Ker(self)][handledSocket[p]][1]>>}; 
                            ltime[p] := BumpTo;
                        } else { \* On a replica:
(* Wait until the primary has bumped p and the data to be delivered to p in at the head of the tcp buffer *)
                            await p \in Bumped(Ker(self)) /\ BumpData(p) = tcpBuff[Ker(self)][handledSocket[p]][1];
                            ltime[p] := BumpedTo(p); \* Bump the process
                        };
                        reads[p] := tcpBuff[Ker(self)][handledSocket[p]][1];
                        tcpBuff[Ker(self)][handledSocket[p]] := 
                            Shift(tcpBuff[Ker(self)][handledSocket[p]]);
                        status[p] := "running"; \* Let p run.
                    }
                }
        }
    }
}

*)
\* BEGIN TRANSLATION
VARIABLES status, ltime, file, bumps, reads, tcpBuff, socketQueue, 
          requestQueue, handledSocket, connections, pc

(* define statement *)
Run(p) == status[p] = "running"
Running(kernel) == { p \in OnKernel(kernel) : Run(p) }
WaitingSync(kernel) ==
    { p \in OnKernel(kernel) : status[p] = "waiting sync" }
WaitingRead(kernel) ==
    { p \in OnKernel(kernel) : status[p] = "waiting read" }
Bumped(kernel) == {p \in OnKernel(kernel) :
    /\  status[p] = "waiting read"
    /\  \E t \in LogTime : \E d \in TcpData : <<ltime[p],t,d>> \in bumps[PID(p)]}
BumpedTo(p) ==
    CHOOSE t \in LogTime : \E d \in TcpData : <<ltime[p],t,d>> \in bumps[PID(p)]
BumpData(p) ==
    CHOOSE d \in TcpData : \E t \in LogTime : <<ltime[p],t,d>> \in bumps[PID(p)]
IsNextProc(kernel, p) ==
    /\  \A q \in Running(kernel) \cup WaitingSync(kernel) :
            q # p => Less(p, ltime[p], q, ltime[q])
    /\  \A q \in Bumped(kernel) : Less(p, ltime[p], q, BumpedTo(q))
BumpTo == CHOOSE i \in LogTime : \A p \in P : ltime[p] < i


vars == << status, ltime, file, bumps, reads, tcpBuff, socketQueue, 
           requestQueue, handledSocket, connections, pc >>

ProcSet == (P) \cup ({<<k,SchedulerPID>> : k \in Kernel})

Init == (* Global variables *)
        /\ status = [p \in P |-> "running"]
        /\ ltime = [p \in P |-> InitLogTime]
        /\ file = [k \in Kernel |-> <<>>]
        /\ bumps = [p \in Pid |-> {}]
        /\ reads = [p \in P |-> -1]
        /\ tcpBuff = [k \in Kernel |-> TcpMultiStream]
        /\ socketQueue = [k \in Kernel |-> <<>>]
        /\ requestQueue = [k \in Kernel |-> [ r \in 1..Requests |-> r]]
        /\ handledSocket = [p \in P |-> -1]
        /\ connections = [k \in Kernel |-> <<>>]
        /\ pc = [self \in ProcSet |-> CASE self \in P -> "ww1"
                                        [] self \in {<<k,SchedulerPID>> : k \in Kernel} -> "s1"]

ww1(self) == /\ pc[self] = "ww1"
             /\ status' = [status EXCEPT ![self] = "waiting sync"]
             /\ pc' = [pc EXCEPT ![self] = "ww2"]
             /\ UNCHANGED << ltime, file, bumps, reads, tcpBuff, socketQueue, 
                             requestQueue, handledSocket, connections >>

ww2(self) == /\ pc[self] = "ww2"
             /\ Run(self)
             /\ pc' = [pc EXCEPT ![self] = "ww3"]
             /\ UNCHANGED << status, ltime, file, bumps, reads, tcpBuff, 
                             socketQueue, requestQueue, handledSocket, 
                             connections >>

ww3(self) == /\ pc[self] = "ww3"
             /\ IF Len(requestQueue[Ker(self)]) > 0
                   THEN /\ handledSocket' = [handledSocket EXCEPT ![self] = requestQueue[Ker(self)][1]]
                        /\ requestQueue' = [requestQueue EXCEPT ![Ker(self)] = Shift(requestQueue[Ker(self)])]
                   ELSE /\ TRUE
                        /\ UNCHANGED << requestQueue, handledSocket >>
             /\ pc' = [pc EXCEPT ![self] = "ww4"]
             /\ UNCHANGED << status, ltime, file, bumps, reads, tcpBuff, 
                             socketQueue, connections >>

ww4(self) == /\ pc[self] = "ww4"
             /\ ltime' = [ltime EXCEPT ![self] = ltime[self]+1]
             /\ pc' = [pc EXCEPT ![self] = "ww5"]
             /\ UNCHANGED << status, file, bumps, reads, tcpBuff, socketQueue, 
                             requestQueue, handledSocket, connections >>

ww5(self) == /\ pc[self] = "ww5"
             /\ IF handledSocket[self] # -1
                   THEN /\ pc' = [pc EXCEPT ![self] = "ww9"]
                   ELSE /\ pc' = [pc EXCEPT ![self] = "ww13"]
             /\ UNCHANGED << status, ltime, file, bumps, reads, tcpBuff, 
                             socketQueue, requestQueue, handledSocket, 
                             connections >>

ww9(self) == /\ pc[self] = "ww9"
             /\ IF Len(tcpBuff[Ker(self)][handledSocket[self]]) > 0
                   THEN /\ status' = [status EXCEPT ![self] = "waiting read"]
                        /\ pc' = [pc EXCEPT ![self] = "ww10"]
                   ELSE /\ pc' = [pc EXCEPT ![self] = "ww13"]
                        /\ UNCHANGED status
             /\ UNCHANGED << ltime, file, bumps, reads, tcpBuff, socketQueue, 
                             requestQueue, handledSocket, connections >>

ww10(self) == /\ pc[self] = "ww10"
              /\ Run(self)
              /\ status' = [status EXCEPT ![self] = "waiting sync"]
              /\ pc' = [pc EXCEPT ![self] = "ww11"]
              /\ UNCHANGED << ltime, file, bumps, reads, tcpBuff, socketQueue, 
                              requestQueue, handledSocket, connections >>

ww11(self) == /\ pc[self] = "ww11"
              /\ Run(self)
              /\ file' = [file EXCEPT ![Ker(self)] = Append(file[Ker(self)], <<PID(self), reads[self]>>)]
              /\ pc' = [pc EXCEPT ![self] = "ww12"]
              /\ UNCHANGED << status, ltime, bumps, reads, tcpBuff, 
                              socketQueue, requestQueue, handledSocket, 
                              connections >>

ww12(self) == /\ pc[self] = "ww12"
              /\ ltime' = [ltime EXCEPT ![self] = ltime[self]+1]
              /\ pc' = [pc EXCEPT ![self] = "ww9"]
              /\ UNCHANGED << status, file, bumps, reads, tcpBuff, socketQueue, 
                              requestQueue, handledSocket, connections >>

ww13(self) == /\ pc[self] = "ww13"
              /\ handledSocket' = [handledSocket EXCEPT ![self] = -1]
              /\ pc' = [pc EXCEPT ![self] = "ww1"]
              /\ UNCHANGED << status, ltime, file, bumps, reads, tcpBuff, 
                              socketQueue, requestQueue, connections >>

worker(self) == ww1(self) \/ ww2(self) \/ ww3(self) \/ ww4(self)
                   \/ ww5(self) \/ ww9(self) \/ ww10(self) \/ ww11(self)
                   \/ ww12(self) \/ ww13(self)

s1(self) == /\ pc[self] = "s1"
            /\ \/ /\ \E p \in     {p \in WaitingSync(Ker(self)) :
                              IsNextProc(Ker(self), p)}:
                       status' = [status EXCEPT ![p] = "running"]
                  /\ UNCHANGED <<ltime, bumps, reads, tcpBuff>>
               \/ /\ \E p \in WaitingRead(Ker(self)):
                       /\ IF Ker(self) = Primary
                             THEN /\ bumps' = [bumps EXCEPT ![PID(p)] = bumps[PID(p)] \cup {<<ltime[p], BumpTo, tcpBuff[Ker(self)][handledSocket[p]][1]>>}]
                                  /\ ltime' = [ltime EXCEPT ![p] = BumpTo]
                             ELSE /\ p \in Bumped(Ker(self)) /\ BumpData(p) = tcpBuff[Ker(self)][handledSocket[p]][1]
                                  /\ ltime' = [ltime EXCEPT ![p] = BumpedTo(p)]
                                  /\ bumps' = bumps
                       /\ reads' = [reads EXCEPT ![p] = tcpBuff[Ker(self)][handledSocket[p]][1]]
                       /\ tcpBuff' = [tcpBuff EXCEPT ![Ker(self)][handledSocket[p]] = Shift(tcpBuff[Ker(self)][handledSocket[p]])]
                       /\ status' = [status EXCEPT ![p] = "running"]
            /\ pc' = [pc EXCEPT ![self] = "s1"]
            /\ UNCHANGED << file, socketQueue, requestQueue, handledSocket, 
                            connections >>

scheduler(self) == s1(self)

Next == (\E self \in P: worker(self))
           \/ (\E self \in {<<k,SchedulerPID>> : k \in Kernel}: scheduler(self))

Spec == Init /\ [][Next]_vars

\* END TRANSLATION
RequestSynchronized == \A k1,k2 \in Kernel :
    \/  Prefix(socketQueue[k1], socketQueue[k2])
    \/  Prefix(socketQueue[k2], socketQueue[k1])    

FilesSynchronized == \A k1,k2 \in Kernel :
    \/  Prefix(file[k1], file[k2])
    \/  Prefix(file[k2], file[k1])
    
ConnectionSynchronized == \A k1,k2 \in Kernel :
    \/  Prefix(connections[k1], connections[k2])
    \/  Prefix(connections[k2], connections[k1])    

=============================================================================
\* Modification History
\* Last modified Fri Oct 23 14:57:58 EDT 2015 by wen
\* Last modified Mon Oct 19 20:54:09 EDT 2015 by nano
\* Created Fri Oct 16 21:28:32 EDT 2015 by nano
