-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                 AMI.Std                                   --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                     Copyright (C) 2012-, AdaHeads K/S                     --
--                                                                           --
--  This is free software;  you can redistribute it and/or modify it         --
--  under terms of the  GNU General Public License  as published by the      --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Exceptions;
with AMI.Action;
with AMI.Event;
with AWS.Net.Std;
with AWS.Net.Buffered;
with My_Configuration;
with Yolk.Log;

package body AMI.Std is
   use My_Configuration;
   AMI_Action_Error : exception;
   AMI_Event_Error : exception;

   Action_Socket : AWS.Net.Std.Socket_Type;
   Event_Socket  : AWS.Net.Std.Socket_Type;
   Reconnect_Delay   : constant Duration := 1.0;
   Socket_Connect_Timeout : constant Duration := 2.0;
   Task_Start_Timeout     : constant Duration := 3.0;
   Shutdown      : Boolean := False;

   Timed_Out_Message : constant String :=
        "Connecting to " &
        Config.Get (PBX_Host) & ":" & Config.Get (PBX_Port)
        & " timed out";

   task AMI_Action_Task is
      entry Start;
      --  TODO: Write comment
   end AMI_Action_Task;

   task AMI_Event_Task is
      entry Start;
      --  TODO: Write comment.
   end AMI_Event_Task;

   -----------------------
   --  AMI_Action_Task  --
   -----------------------

   task body AMI_Action_Task
   is
      use Yolk.Log;

      Connected : Boolean := False;
   begin
      select
         accept Start do
            select
               delay Socket_Connect_Timeout;
               raise AMI_Action_Error with Timed_Out_Message;
            then abort
               AWS.Net.Std.Connect (Socket => Action_Socket,
                                    Host   => Config.Get (PBX_Host),
                                    Port   => Config.Get (PBX_Port));
               Connected := True;
            end select;
         end Start;
      or
         delay Task_Start_Timeout;
         raise AMI_Action_Error with "Start entry not called within time";
      end select;

      Reconnect :
      loop
         begin
            if not Connected then
               AWS.Net.Std.Connect (Socket => Action_Socket,
                                    Host   => Config.Get (PBX_Host),
                                    Port   => Config.Get (PBX_Port));
            else
               Trace (Info, "DEBUG, action is connected, and do not try.");
            end if;

            Trace (Info,
                   "AMI action socket connected - Host: "
                   & Config.Get (PBX_Host)
                   & " Port: " & Config.Get (PBX_Port));

            Trace (Info, "DEBUG, Calling Action Start");
            AMI.Action.Start (Socket   => Action_Socket,
                              Username => Config.Get (PBX_Action_User),
                              Secret   => Config.Get (PBX_Action_Secret));
            Trace (Debug, "AMI action returned out of start");

         exception
            when AWS.Net.Socket_Error =>
               Trace (Error, "AMI.Action lost connection");
            when Err : others =>
               Trace (Error,
                      "ami-std, AMI Action, " &
                        "ExceptionName: " &
                        Ada.Exceptions.Exception_Name (Err));
         end;
         Connected := False;
         if Shutdown then
            Trace (Info, "AMI action connection Closed");
            exit Reconnect;
         end if;

         delay Reconnect_Delay;
      end loop Reconnect;
   end AMI_Action_Task;

   ----------------------
   --  AMI_Event_Task  --
   ----------------------

   task body AMI_Event_Task
   is
      use Yolk.Log;

      Connected : Boolean := False;
   begin
      select
         accept Start do
            select
               delay Socket_Connect_Timeout;
               raise AMI_Event_Error with Timed_Out_Message;
            then abort
               AWS.Net.Std.Connect (Socket => Event_Socket,
                                    Host   => Config.Get (PBX_Host),
                                    Port   => Config.Get (PBX_Port));
               Connected := True;
            end select;
         end Start;
      or
         delay Task_Start_Timeout;
         raise AMI_Event_Error with "Start entry not called within time";
      end select;

      Reconnect :
      loop
         begin
            if not Connected then
               AWS.Net.Std.Connect (Socket => Event_Socket,
                                    Host   => Config.Get (PBX_Host),
                                    Port   => Config.Get (PBX_Port));
            end if;
            Trace (Info,
                   "AMI event socket connected - Host: "
                   & Config.Get (PBX_Host)
                   & " Port: " & Config.Get (PBX_Port));

            AMI.Event.Start (Channel  => Event_Socket,
                             Username => Config.Get (PBX_Event_User),
                             Secret   => Config.Get (PBX_Event_Secret));
            Connected := False;
         exception
            when AWS.Net.Socket_Error =>
               Connected := False;

         end;

         if Shutdown then
            Trace (Info, "AMI socket connection closed.");
            exit Reconnect;
         else
            --  send message out to websocket about system failure.
            Trace (Error, "No connection to AMI.Event");
         end if;

         delay Reconnect_Delay;
      end loop Reconnect;
   end AMI_Event_Task;

   ---------------
   --  Connect  --
   ---------------

   procedure Connect
   is
      use Yolk.Log;
   begin
      AMI_Event_Task.Start;
      AMI_Action_Task.Start;
   end Connect;

   ------------------
   --  Disconnect  --
   ------------------

   procedure Disconnect
   is
   begin
      Shutdown := True;
      AWS.Net.Buffered.Shutdown (Event_Socket);
      AWS.Net.Buffered.Shutdown (Action_Socket);
   end Disconnect;

end AMI.Std;
