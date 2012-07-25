with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar;
with Ada.Containers;
with Asterisk_AMI_IO; use Asterisk_AMI_IO;
with Protocol; use Protocol;
with AWS.Net.Buffered, AWS.Net;
with Task_Controller;

package body Socket is
   use Call_Queue;

   Asterisk         : Asterisk_AMI_Type;
   Last_Action      : Action := None;
   Peer_List        : Peer_List_Type.Map;
   Consistency      : Queue_Type.Vector;

   --  Callback maps
   Callback_Routine : Action_Callback_Routine_Table :=
     (Login       => Login_Callback'Access,
      QueueStatus => QueueStatus_Callback'Access,
      others      => null);

   Event_Callback_Routine : constant Event_Callback_Routine_Table :=
     (Dial                 => Dial_Callback'Access,
      Hangup               => Hangup_Callback'Access,
      Join                 => Join_Callback'Access,
      QueueMemberPaused    => QueueMemberPaused_Callback'Access,
      PeerStatus           => PeerStatus_Callback'Access,
      Unlink               => Unlink_Callback'Access,
      QueueEntry           => QueueEntry_Callback'Access,
      QueueStatusComplete  => QueueStatusComplete_CallBack'Access,
      others               => null);

   --  Lists agents
   procedure Agents is
   begin
      Put_Line ("Not implemented");
      raise NOT_IMPLEMENTED;
   end Agents;

   procedure Bridge (AMI       : in Asterisk_AMI_Type;
                     ChannelA : in Unbounded_String;
                     ChannelB : in Unbounded_String) is
      Command : constant String := Protocol.Bridge (To_String (ChannelA),
                                                    To_String (ChannelB));

   begin
      --        String'Write (AMI.Channel,
      --                     Command);
      SendCommand (Socket => AMI.Channel,
                   Item => Command);
   end Bridge;

   --  Takes two channels, and bridge the them together.
   procedure Bridge_Call (Channel1 : in Unbounded_String;
                          Channel2 : in Unbounded_String) is
   begin
      --  TODO, Jeg er ikke sikker, at jeg bare kan hive Asterisk her
      Bridge (Asterisk, Channel1, Channel2);
   end Bridge_Call;

   --  Event: Bridge
   --  Privilege: call,all
   --  Bridgestate: Link
   --  Bridgetype: core
   --  Channel1: SIP/softphone2-0000000a
   --  Channel2: SIP/softphone1-0000000b
   --  Uniqueid1: 1340097427.10
   --  Uniqueid2: 1340097427.11
   --  CallerID1: softphone2
   --  CallerID2: 100
   procedure Bridge_Callback is
   begin
      Put_Line ("Not implemented");
      raise NOT_IMPLEMENTED;
   end Bridge_Callback;

   procedure Consistency_Check is
      Command : constant String := Protocol.QueueStatus ("Consistency");
   begin
      SendCommand (Asterisk.Channel, Command);
   end Consistency_Check;

   procedure CoreSettings_Callback (Event_List : in Event_List_Type) is
      Current_Key : Unbounded_String;
   begin
      for i in Event_List'Range loop
         Current_Key := Event_List (i, Key);
         if To_String (Current_Key) = "AsteriskVersion" then
            Put_Line ("AsteriskVersion: " & To_String (Event_List (i, Value)));
         end if;
      end loop;
      raise NOT_IMPLEMENTED;
   end CoreSettings_Callback;

   --  Event: Dial
   --  Privilege: call,all
   --  SubEvent: Begin
   --  Channel: SIP/softphone2-0000000a
   --  Destination: SIP/softphone1-0000000b
   --  CallerIDNum: softphone2
   --  CallerIDName: <unknown>
   --  UniqueID: 1340097427.10
   --  DestUniqueID: 1340097427.11
   --  Dialstring: softphone1
   procedure Dial_Callback (Event_List : in Event_List_Type) is
   begin
      --  Now we play a game called; Find the message!
      for i in Event_List'First + 1 .. Event_List'Last loop
         if To_String (Event_List (i, Key)) = "Message" and
         then To_String (Event_List (i, Value)) =
           "Authentication accepted" then
            Asterisk.Logged_In := True;
         end if;
      end loop;
   end Dial_Callback;

   --  Get the specific call with UniqueId matching
   --  If unitqueID is null, then the first call in the queue is taken.
   procedure Get_Call (Uniqueid : in     Unbounded_String;
                       Agent    : in     Unbounded_String;
                       Call     :    out Call_Queue.Call_Type) is

      temp_Call : Call_Type;
      Peer : Peer_Type;
      Peer_List_Index : constant Peer_List_Type.Cursor :=
        Peer_List_Type.Find (Peer_List, Agent);
   begin
      --  Check if there exsist an Agent by that name.
      if not Peer_List_Type.Has_Element
        (Position => Peer_List_Index) then
         Put_Line ("We have no agent registred by the name: " &
                     To_String (Agent));
         Call := null_Call;
         return;
--           raise Program_Error;
      end if;

      --  Now that we know that there exists an agent,
      --   is the SIP phone registreted
      Peer := Peer_List_Type.Element (Peer_List_Index);
      if Peer.Status = Unregistered then
         Put_Line ("The following agent is unregistred: " &
                     To_String (Agent));
         raise Program_Error;
      end if;

      --  TESTING
      Put (To_String (Call_Queue.Queue_ToString));
      --  TESTING

      --  If Uniqueueid parameter is null,
      --   then take the next call in the call queue.
      if Uniqueid = Null_Unbounded_String then
         Call_Queue.Dequeue (Call => temp_Call);
      else
         Call_Queue.Dequeue (Uniqueid => Uniqueid, Call => temp_Call);
      end if;

      --  If there is a call to anwser.
      if temp_Call /= Call_Queue.null_Call then
         --  TESTING
         Put_Line ("Got Call");
         Call_Queue.printCall (Call => temp_Call);
         --  TESTING

         temp_Call.Picked_Up := Ada.Calendar.Clock;
         temp_Call.Is_Picked_Up := True;

         Peer.Call := temp_Call;
         Peer_List_Type.Replace_Element (Container => Peer_List,
                                         Position => Peer_List_Index,
                                         New_Item => Peer);

         Call := temp_Call;

         --  Send the call out to the phone
         Redirect (Asterisk_AMI => Asterisk,
                   Channel => temp_Call.Channel,
                   Exten => Peer.Exten);
      else
         Put_Line ("No Call to take");

         Call := null_Call;
      end if;
   end Get_Call;

   --  Scaffolding
   procedure Get_Version (AMI : in Asterisk_AMI_Type) is
      Command : constant String := Protocol.CoreSettings;
   begin
      null;
      --  The following sequence will return a string with Asterisk version.
      --  Action: Command
      --  Command: core show version
      --
      --  OR!
      --  Action: CoreSettings
      --
      --  This can be very useful in detecting the different capabilities of
      --  different versions of Asterisk - and perhaps even FreeSwitch?

      --        String'Write (AMI.Channel, Command);
      SendCommand (AMI.Channel, Command);
      --        Last_Action := CoreSettings;
   end Get_Version;

   --  Event: Hangup
   --  Privilege: call,all
   --  Channel: SIP/softphone1-0000000b
   --  Uniqueid: 1340097427.11
   --  CallerIDNum: 100
   --  CallerIDName: <unknown>
   --  Cause: 16
   --  Cause-txt: Normal Clearing
   procedure Hangup_Callback (Event_List : in Event_List_Type) is
      --        Call : Call_Type;
   begin
      --        Put ("Hangup Callback - ");
      for i in Event_List'Range loop
         if To_String (Event_List (i, Key)) = "Uniqueid" then
            --              Put_Line (To_String (Event_List (i, Value)));
            --  If we did't remove it from the list,
            --   we needed to add a Ended time and set Is_Ended.
            Call_Queue.Remove (Uniqueid => Event_List (i, Value));
            --              Call := Calls.Get_Call(Call_Queue => Call_Queue,
            --                                Channel => Event_List(i,Value));
            --              if Call /= Calls.null_Call then
            --                 Calls.Remove(Call_Queue => Call_Queue,
            --                              Call => Call);
            --              end if;
         end if;
      end loop;
      --        raise NOT_IMPLEMENTED;
   end Hangup_Callback;

   --  Event: Join
   --  Channel: SIP/TP-Softphone-00000021
   --  CallerIDNum: TP-Softphone
   --  CallerIDName: unknown
   --  Queue: testqueue1
   --  Position: 1
   --  Count 1
   --  Uniqueid: 1340807150.33
   procedure Join_Callback (Event_List : in Event_List_Type) is
      Call : Call_Queue.Call_Type;
      Event_Key : Unbounded_String;
   begin
      --  TODO, det kan skrives om, hvis vi stoler p� opbygningen af eventen.
      for i in Event_List'First .. Event_List'Last loop
         Event_Key := Event_List (i, Key);

         if To_String (Event_Key) = "Channel" then
            Call.Channel := Event_List (i, Value);

         elsif To_String (Event_Key) = "CallerIDNum" then
            Call.CallerIDNum := Event_List (i, Value);

         elsif To_String (Event_Key) = "CallerIDName" then
            Call.CallerIDName := Event_List (i, Value);

         elsif To_String (Event_Key) = "Queue" then
            Call.Queue := Event_List (i, Value);

         elsif To_String (Event_Key) = "Position" then
            Call.Position := Integer'Value (To_String (Event_List (i, Value)));

         elsif To_String (Event_Key) = "Count" then
            Call.Count := Integer'Value (To_String (Event_List (i, Value)));

         elsif To_String (Event_Key) = "Uniqueid" then
            Call.Uniqueid := Event_List (i, Value);
         end if;
      end loop;
      Call.Arrived := Ada.Calendar.Clock;

      --        Put ("New in queue: ");
      --        Calls.printCall (Call);

      Call_Queue.Enqueue (Call => Call);
      --        Calls.Add(Call_Queue => Call_Queue, Call => Call);

      --        Put (To_String (Call_Queue.Queue_ToString));
   end Join_Callback;

   procedure Login (AMI      : in Asterisk_AMI_Type;
                    Username : in String;
                    Secret   : in String;
                    Callback : in Callback_Type := null;
                    Persist  : in Boolean       := True) is
      Command : constant String := Protocol.Login (Username => Username,
                                                   Secret => Secret);

   begin
      SendCommand (AMI.Channel, Command);

      --  Update the table if we were asked to used this as standard callback
      if Callback /= null and then Persist then
         Callback_Routine (Login) := Callback;
      end if;

      Last_Action := Login;
   end Login;

   procedure Login_Callback (Event_List : in Event_List_Type) is
   begin
      --  Now we play a game called; Find the message!
      for i in Event_List'First + 1 .. Event_List'Last loop
         if To_String (Event_List (i, Key)) = "Message" and
         then To_String (Event_List (i, Value)) =
           "Authentication accepted" then
            Asterisk.Logged_In := True;
         end if;
      end loop;
   end Login_Callback;

   procedure Logoff (AMI      : in     Asterisk_AMI_Type;
                     Callback : access Callback_Type := null) is
      Command : constant String := Protocol.Logoff;
   begin
      SendCommand (AMI.Channel, Command);
      Last_Action := Logoff;

      if Callback /= null then
         --  Callback;
         null;
      end if;
   end Logoff;

   --  Event: Newstate
   --  Privilege: call,all
   --  Channel: SIP/softphone1-0000000b
   --  ChannelState: 5
   --  ChannelStateDesc: Ringing
   --  CallerIDNum: 100
   --  CallerIDName:
   --  Uniqueid: 1340097427.11
   procedure NewState_Callback is
   begin
      Put_Line ("Not implemented");
      raise NOT_IMPLEMENTED;
   end NewState_Callback;

   --  Event: PeerStatus
   --  Peer: SIP/2005
   --  PeerStatus: Registered
   procedure PeerStatus_Callback (Event_List : in Event_List_Type) is
      Peer    : Peer_Type;
      Map_Key : Unbounded_String;
   begin
      Put_Line ("Peer status update");
      for i in Event_List'First + 1 .. Event_List'Last loop
         if To_String (Event_List (i, Key)) = "Peer" then
            Peer.Peer := Event_List (i, Value);
            Map_Key := Event_List (i, Value);

         elsif To_String (Event_List (i, Key)) = "ChannelType" then
            Peer.ChannelType := Event_List (i, Value);

         elsif To_String (Event_List (i, Key)) = "Address" then
            Peer.Address := Event_List (i, Value);

         elsif To_String (Event_List (i, Key)) = "Port" then
            Peer.Port := Event_List (i, Value);

         elsif To_String (Event_List (i, Key)) = "PeerStatus" then
            if To_String (Event_List (i, Value)) = "Unregistered"  then
               Peer.Status := Unregistered;
            elsif To_String (Event_List (i, Value)) = "Registered"  then
               Peer.Status := Registered;
            else
               Put_Line ("SIP client to unknown state: " &
                           To_String (Event_List (i, Value)));
            end if;
         end if;
      end loop;

      declare
         Exten : Unbounded_String;
         --  Hent Extension.
      begin
         Exten := Peers.Get_Exten (Peer.Peer);
         if Exten = Null_Unbounded_String then
            Put_Line ("There is not registrated any extension to agent: " &
                        To_String (Peer.Peer));
            raise Program_Error;
         else
            Put_Line ("Peer got Exten => " & To_String (Exten));
            Peer.Exten := Exten;
         end if;
      end;

      --  Update the timestamp
      Peer.Last_Seen := Ada.Calendar.Clock;

      --  Update the peer list
      if Peer_List_Type.Contains (Container => Peer_List,
                                  Key       => Map_Key) then
         Peer_List_Type.Replace (Container => Peer_List,
                                 Key       => Map_Key,
                                 New_Item  => Peer);
      else

         Peer_List_Type.Insert (Container => Peer_List,
                                Key       => Map_Key,
                                New_Item  => Peer);
      end if;

      Print_Peer (Peer_List_Type.Element (Container => Peer_List,
                                          Key       => Map_Key));
   end PeerStatus_Callback;

   procedure Ping (Asterisk_AMI : in Asterisk_AMI_Type) is
      Command : constant String := Protocol.Ping;
   begin
      --        String'Write (Asterisk_AMI.Channel, Command);
      SendCommand (Asterisk_AMI.Channel, Command);
      Last_Action := Ping;
   end Ping;

   --  Event: QueueEntry
   --  Queue: testqueue1
   --  Position: 1
   --  Channel: SIP/TP-Softphone-00000017
   --  Uniqueid: 1341827264.23
   --  CallerIDNum: TP-Softphone
   --  CallerIDName: unknown
   --  Wait: 98
   --
   --  It assummes that the Call_Queue is empty, therefor
   --  it should only get called when the program startes.
   procedure QueueEntry_Callback (Event_List : in Event_List_Type) is
      Key_Text : Unbounded_String;
      Call : Call_Type;
      Is_Start_Up : Boolean := False;
   begin
      for i in Event_List'Range loop
         Key_Text := Event_List (i, Key);
         if To_String (Key_Text) = "Queue" then
            Call.Queue := Event_List (i, Value);
         elsif To_String (Key_Text) = "Channel" then
            Call.Channel := Event_List (i, Value);
         elsif To_String (Key_Text) = "Uniqueid" then
            Call.Uniqueid := Event_List (i, Value);
         elsif To_String (Key_Text) = "CallerIDNum" then
            Call.CallerIDNum := Event_List (i, Value);
         elsif To_String (Key_Text) = "CallerIDName" then
            Call.CallerIDName := Event_List (i, Value);
         elsif To_String (Key_Text) = "Position" then
            Call.Position := Integer'Value (To_String (Event_List (i, Value)));
         elsif To_String (Key_Text) = "ActionID" then
            if To_String (Event_List (i, Value)) = "StartUp" then
               Is_Start_Up := True;
            end if;
         elsif To_String (Key_Text) = "Wait" then
            declare
               use Ada.Calendar;
               Waited_In_Seconds : Duration;
               Now : constant Ada.Calendar.Time := Ada.Calendar.Clock;
            begin
               Waited_In_Seconds := Duration'Value (To_String
                                                    (Event_List (i, Value)));
               Call.Arrived := Now - Waited_In_Seconds;
            exception
               when others =>
                  Ada.Text_IO.Put_Line
                    ("QueueEntry: wait is not an Duration, and that is wrong"
                     & To_String (Event_List (i, Value)));
            end;
         end if;
      end loop;
      if Is_Start_Up then
         Call_Queue.Enqueue (Call);
      else
         --  Then it must be a consistency tjek.
         Consistency.Append (Call);
      end if;
   end QueueEntry_Callback;

   --  Event: QueueMemberPaused
   --  Privilege: agent,all
   --  Queue: myqueue
   --  Location: SIP/testphone
   --  MemberName: Jared Smith
   --  Paused: 1
   procedure QueueMemberPaused_Callback (Event_List : in Event_List_Type) is
      Peer_Phone : Unbounded_String;
      paused : Boolean := False;
      Peer_Cursor : Peer_List_Type.Cursor;
      Peer : Peer_Type;
   begin
      for i in Event_List'Range loop
         if To_String (Event_List (i, Key)) = "Location" then
            Peer_Phone := Event_List (i, Value);

         elsif To_String (Event_List (i, Key)) = "Paused" then
            if To_String (Event_List (i, Value)) = "0" then
               paused := False;

            elsif To_String (Event_List (i, Value)) = "1" then
               paused := True;
            end if;
         end if;
      end loop;

      Peer_Cursor :=  Peer_List_Type.Find (Peer_List, Peer_Phone);
      Peer := Peer_List_Type.Element (Peer_Cursor);

      Peer.Paused := paused;
      Peer_List_Type.Replace_Element (Container => Peer_List,
                                      Position => Peer_Cursor,
                                      New_Item => Peer);

      Put_Line ("Not implemented - QueueMemberPaused_Callback");
      --  raise NOT_IMPLEMENTED;
   end QueueMemberPaused_Callback;

   procedure QueuePause (Asterisk_AMI : in Asterisk_AMI_Type;
                         Peer : in Peer_Type) is
      Command : constant String := Protocol.QueuePause
        (DeviceName => To_String (Peer.Peer),
         State => Pause);

   begin
      SendCommand (Asterisk_AMI.Channel, Command);
   end QueuePause;

   procedure QueueStatus (Asterisk_AMI : in Asterisk_AMI_Type;
                         ActionID : in String := "") is
      Command : constant String := Protocol.QueueStatus (ActionID);
   begin
      SendCommand (Asterisk_AMI.Channel, Command);
      Last_Action := QueueStatus;
   end QueueStatus;

   --  Response: Success
   --  Message: Queue status will follow
   procedure QueueStatus_Callback (Event_List : in Event_List_Type) is
   begin
      for i in Event_List'Range loop
         if Event_List (i, Key) = "Message" then
            if Event_List (i, Value) = "Queue status will follow" then
               Consistency.Clear;
            end if;
         end if;
      end loop;
   end QueueStatus_Callback;

   procedure QueueStatusComplete_CallBack (Event_List : in Event_List_Type) is
      use Ada.Containers;
      Queue : constant Call_Queue_Type := Call_Queue.Get_Queue;
      function Check_Call (Call : in Call_Type) return Boolean;
      function Check_Call (Call : in Call_Type) return Boolean is
      begin
         for Queue_Priority in Queue'Range loop
            for Queue_Index in
              1 .. Integer (Queue (Queue_Priority).Length) loop
               if Call.Uniqueid =
                 Queue (Queue_Priority).Element (Queue_Index).Uniqueid
               then
                  return True;
               end if;
            end loop;
         end loop;
         return False;
      end Check_Call;
   begin
      for i in Event_List'Range loop
         if To_String (Event_List (i, Key)) = "ActionID" then
            if To_String (Event_List (i, Value)) = "Consistency" then
               Put_Line ("Consistency Check");
               if Call_Queue.Queue_Length /= Consistency.Length then
                  Put_Line ("-----------------------------------------------");
                  Put_Line ("         Consistency check - Length failed     ");
                  Put_Line ("Call Queue Length: " &
                              Call_Queue.Queue_Length'Img);
                  Put_Line ("Asterisk Queue Length: " &
                              Consistency.Length'Img);
                  Put_Line ("-----------------------------------------------");
               end if;
               --  TODO Error Correction
               --  XXX Der er en chance for det her er langsomst.

               for Cons_Index in 1 .. Integer (Consistency.Length) loop
                  if not Check_Call (Consistency.Element (Cons_Index)) then
                     Put_Line ("--------------------------------------------");
                     Put_Line ("    Consistency check - Not Equal failed    ");
                     printCall (Consistency.Element (Cons_Index));
                     Put_Line ("Does not exsist in our call queue");
                     Put_Line ("--------------------------------------------");
                  end if;
               end loop;
               Put_Line ("The system is consistent");
            end if;
         end if;
      end loop;

   end QueueStatusComplete_CallBack;

   procedure QueueUnpause (Asterisk_AMI : in Asterisk_AMI_Type;
                           Peer : in Peer_Type) is
      Command : constant String := Protocol.QueuePause
        (DeviceName => To_String (Peer.Peer),
         State => UnPause);
   begin
      SendCommand (Asterisk_AMI.Channel, Command);
   end QueueUnpause;

   procedure Redirect (Asterisk_AMI : in Asterisk_AMI_Type;
                       Channel : in Unbounded_String;
                       Exten : in Unbounded_String;
                       Context : in Unbounded_String :=
                         To_Unbounded_String ("LocalSets")) is
      Command : constant String := Protocol.Redirect
        (Channel => To_String (Channel),
         Context => To_String (Context),
         Exten => To_String (Exten),
         Priority => 1);

   begin
      Put_Line ("Redirecting " & To_String (Channel)
                & " => " & To_String (Context) & ", " & To_String (Exten));
      Put_Line ("-------------" & ASCII.LF & Command);
      SendCommand (Asterisk_AMI.Channel, Command);
      --        Last_Action := Redirect;
   end Redirect;

   procedure Register_Agent (PhoneName   : in Unbounded_String;
                             Computer_ID : in Unbounded_String) is
      Peer : Peer_Type;
      Peer_Index : Peer_List_Type.Cursor;
   begin
      Peer_Index := Peer_List_Type.Find (Container => Peer_List,
                                         Key => PhoneName);
      if Peer_List_Type.Has_Element (Peer_Index) then
         --  The phone allready exsist in the list.
         Peer := Peer_List_Type.Element (Position => Peer_Index);
         Peer.Computer_ID := Computer_ID;
         Peer_List_Type.Replace_Element (Container => Peer_List,
                                         Position => Peer_Index,
                                         New_Item => Peer);
      else
         Peer.Peer := PhoneName;
         Peer.Computer_ID := Computer_ID;
         Peer_List_Type.Insert (Container => Peer_List,
                                Key => PhoneName,
                                New_Item => Peer);
      end if;
   end Register_Agent;

   procedure SendCommand (Socket : in AWS.Net.Std.Socket_Type;
                          Item : in String) is
   begin
      AWS.Net.Buffered.Put (Socket, Item);
      AWS.Net.Buffered.Flush (Socket);
   end SendCommand;

   --  Lists the SIP peers. Returns a PeerEntry event for each
   --  SIP peer, and a PeerlistComplete event upon completetion
   --  Event: PeerEntry
   --  Channeltype: SIP
   --  ObjectName: softphone2
   --  ChanObjectType: peer
   --  IPaddress: 90.184.227.68
   --  IPport: 59028
   --  Dynamic: yes
   --  Natsupport: yes
   --  VideoSupport: no
   --  TextSupport: no
   --  ACL: no
   --  Status: Unmonitored
   --  RealtimeDevice: no
   --
   --  Event: PeerlistComplete
   --  EventList: Complete
   --  ListItems: 2
   procedure SIPPeers_Callback is
   begin
      Put_Line ("Not implemented");
      raise NOT_IMPLEMENTED;
   end SIPPeers_Callback;

   --  TODO: Write up and
   --    architecture that uses a queue to send requests, or blocks
   procedure Start (channel  : in AWS.Net.Std.Socket_Type;
                    Username : in String;
                    Secret   : in String) is
      use Task_Controller;
--        Username : constant String := "filtertest"; --  "admin";
--        Secret : constant String := "filtertest"; --  "amp111";
   begin
      Asterisk := (Greeting  => new String'(Read_Line (channel)),
                   Channel   => channel,
                   Logged_In => False);

      --  Send login
      Login (AMI      => Asterisk,
             Username => Username,
             Secret   => Secret);

      QueueStatus (Asterisk, "StartUp");
      loop
         exit when Task_State = Down;
         declare
            Event_String : constant Unbounded_String := Read_Package (channel);
            Event_List : constant Event_List_Type := Parse (Event_String);
         begin
            --  Basically we have responses, or events
            if Event_List (Event_List'First, Key)  = "Event" then
               --  Put_Line (To_String (Event_List (Event_List'First, Key)) &
               --  ": " & To_String (Event_List (Event_List'First, Value)));
               begin
                  Event_Callback_Routine
                    (Socket.Event'Value (To_String
                     (Event_List (Event_List'First, Value)))) (Event_List);
               exception
                  when Error : others =>
                     Put_Line ("Event not implemented: " &
                                 To_String (Event_List (1, Value)));
                     Put_Line (Exception_Message (Error));
               end;

            elsif Event_List (Event_List'First, Key)  = "Response" then
               --  Lookup the callback, and pass the value.
               Callback_Routine (Last_Action)(Event_List);
               --  Direct it to the callback associated
               --    with the previous commmand
            end if;
         exception
            when Error : others =>
               Put_Line (Ada.Exceptions.Exception_Name (Error));
               Put_Line (Exception_Message (Error));
               Put_Line ("Socket.Start.declare: ");
         end;
      end loop;
   exception
      when Error : others =>
         Put_Line (Exception_Message (Error));
         Put_Line ("Socket.Start: ");
   end Start;

   procedure TEST_StatusPrint is
   begin
      Put_Line ("----------- Peers --------------");
      for Peer in Peer_List.Iterate loop
         Peers.Print_Peer (Peer_List_Type.Element (Peer));
      end loop;

      Put (To_String (Call_Queue.Queue_ToString));
      Put_Line ("Queue length" & Integer (Call_Queue.Queue_Length)'Img);
   end TEST_StatusPrint;

   --  Event: Unlink
   --  Privilege: call,all
   --  Channel1: SIP/softphone2-0000000a
   --  Channel2: SIP/softphone1-0000000b
   --  Uniqueid1: 1340097427.10
   --  Uniqueid2: 1340097427.11
   --  CallerID1: softphone2
   --  CallerID2: 100
   procedure Unlink_Callback (Event_List : in Event_List_Type) is
   begin
      Put_Line ("Not implemented " &
                  To_String (Event_List (Event_List'First, Value)));
      raise NOT_IMPLEMENTED;
   end Unlink_Callback;

end Socket;
