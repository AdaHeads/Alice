-------------------------------------------------------------------------------
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

with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Common,
     HTTP_Codes,
     Model.Agent,
     Model.Agent_ID,
     Response;

with View.Call;

with PBX;
with PBX.Action;
with PBX.Call;
with System_Messages;
with System_Message.Critical;

package body Handlers.Call is
   use AWS.Status;
   use System_Messages;
   use View.Call;
   use Model;
   package HTTP renames HTTP_Codes;

   --------------
   --  Hangup  --
   --------------

   --  TODO: Add check for valid agent.
   function Hangup
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use Common;
      use PBX;

      Response_Object   : Response.Object := Response.Factory (Request);
      Requested_Call_ID : String renames Parameters (Request).Get ("call_id");
   begin
      PBX.Action.Hangup (ID => PBX.Call.Value (Item => Requested_Call_ID));

      Response_Object.HTTP_Status_Code (HTTP.OK);
      Response_Object.Content (Status_Message
                                 ("Status", "Hangup sent!"));

      return Response_Object.Build;

   exception
      when PBX.Call.Not_Found =>

         Response_Object.HTTP_Status_Code (HTTP.Not_Found);
         Response_Object.Content
           (Status_Message
              ("status", "not found"));
         return Response_Object.Build;

      when E : others =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => "Hangup failed",
            Response_Object => Response_Object);
         return Response_Object.Build;
   end Hangup;

   ------------
   --  List  --
   ------------

   function List
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use Common;

      Response_Object : Response.Object := Response.Factory (Request);
   begin
      --  Only return a call list when there actual calls in it.
      if not PBX.Call.List_Empty then
         Response_Object.HTTP_Status_Code (HTTP.OK);
         Response_Object.Content (To_JSON_String (PBX.Call.List));
      else
         Response_Object.HTTP_Status_Code (HTTP.No_Content);
      end if;

      return Response_Object.Build;
   exception
      when E : others =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => "List failed",
            Response_Object => Response_Object);
         return Response_Object.Build;
   end List;

   -----------------
   --  Originate  --
   -----------------

   function Originate
     (Request : in AWS.Status.Data)
      return AWS.Response.Data is
      use Common;
      use PBX.Call;

      Extension_String  : constant String :=
                            Parameters (Request).Get ("extension");
      Originating_Agent : Model.Agent.Agent_Type := Agent.Null_Agent;
      Response_Object   : Response.Object := Response.Factory (Request);
   begin
      Originating_Agent := Agent_Of (Request => Request);

      PBX.Action.Originate
        (Agent       => Originating_Agent,
         Extension   => Extension_String);

      Response_Object.HTTP_Status_Code (HTTP.OK);
      Response_Object.Content (Status_Message
                                 ("status", "ok"));

      return Response_Object.Build;
   exception
      when E : PBX.Action.Error | Model.Agent_ID.Invalid_ID =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => Ada.Exceptions.Exception_Message (E),
            Response_Object => Response_Object);
         return Response_Object.Build;
      when E : others =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => "Originate failed",
            Response_Object => Response_Object);
         return Response_Object.Build;

   end Originate;

   ------------
   --  Park  --
   ------------

   function Park (Request : in AWS.Status.Data)
                  return AWS.Response.Data is
      package Call_List renames PBX.Call;

      Response_Object   : Response.Object := Response.Factory (Request);
      Call_ID           : Call_List.Identification renames
                            Call_List.Value
                              (Parameters (Request).Get ("call_id"));
   begin
      --  Fetch the call from the call list.
      if not Call_List.Has (ID => Call_ID) then
         Response_Object.HTTP_Status_Code (HTTP.Not_Found);
         Response_Object.Content (Status_Message ("status", "not found"));
      else

         PBX.Action.Park (Call  => Call_ID,
                          Agent => Agent.Agent_Of (Request => Request));

         --  And let the user know that everything went according to plan.
         Response_Object.HTTP_Status_Code (HTTP.OK);
         Response_Object.Content (Status_Message ("status", "request sent!"));
      end if;

      return Response_Object.Build;
   exception
      when Call_List.Invalid_ID =>
         Response_Object.HTTP_Status_Code (HTTP.Bad_Request);
         Response_Object.Content (Status_Message
                                  ("status", "bad parameter ""Call_ID"""));
         return Response_Object.Build;
      when E : others =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => "Park failed",
            Response_Object => Response_Object);
         return Response_Object.Build;
   end Park;

   --------------
   --  Pickup  --
   --------------

   function Pickup
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use Ada.Strings.Unbounded;
      use Common;

      use Model.Agent_ID;
      use Model.Agent;

      Call_ID_String    : String renames
                            Parameters (Request).Get (Name => "call_id");
      Response_Object   : Response.Object   := Response.Factory (Request);
      Agent             : Agent_Type        := Null_Agent;
      Assigned_Call     : PBX.Call.Instance;
   begin
      --  We want a valid agent ID, so we let the exception propogate.
      Agent := Agent_Of (Request => Request);

      System_Messages.Notify
        (Information, "Looked up agent to be " & Agent.ID.To_String);

      --  If we do not have any calls at this point, return HTTP 204.
      if PBX.Call.List_Empty then
         Response_Object.HTTP_Status_Code (HTTP.No_Content);
         return Response_Object.Build;
      end if;

      System_Messages.Notify (Debug, "List is non-empty");

--        if not Peer.Available then
--           System_Messages.Notify
--             (Critical, "Get_Call: " &
--                "The following agent is unavailable: " &
--                Agent.ID.To_String);
--           Response_Object.HTTP_Status_Code (HTTP.Bad_Request);
--           Response_Object.Content
--             (Status_Message
--                ("Bad request", "Agent peer unavailable"));
--
--           return Response_Object.Build;
--        else
         --  We're good - transfer the call.
         --  Agent := Model.Agent.Get (Agent_ID => Agent_ID);

         if Call_ID_String /= "" then
            Assigned_Call := PBX.Call.Get
              (Call => PBX.Call.Value (Call_ID_String));
            Assigned_Call.Assign (Agent.ID);
         else
            Assigned_Call := PBX.Call.Highest_Prioirity;
            Assigned_Call.Assign (Agent.ID);
         end if;

         PBX.Action.Transfer (Assigned_Call.ID, Agent);

         Response_Object.HTTP_Status_Code (HTTP.OK);
         Response_Object.Content
           ((To_JSON_String (Assigned_Call.To_JSON)));
      --  end if;

      return Response_Object.Build;

   exception
      when E : Model.Agent_ID.Invalid_ID =>
         System_Messages.Notify
           (Error, Ada.Exceptions.Exception_Information (E));
         Response_Object.HTTP_Status_Code (HTTP.Server_Error);
         Response_Object.Content
           (Status_Message
              ("Uh-oh", "You don't seem to have a valid agent ID"));
         return Response_Object.Build;

      when PBX.Call.Already_Bridged =>
         Response_Object.HTTP_Status_Code (HTTP.Bad_Request);
         Response_Object.Content
           (Status_Message
              ("Already assigned",
               "Agent tried to claim call that is already assigned"));
         return Response_Object.Build;

      when E : others =>
         System_Messages.Notify
           (Error, Ada.Exceptions.Exception_Information (E));
         Response_Object.HTTP_Status_Code (HTTP.Server_Error);
         Response_Object.Content
           (Status_Message
              ("Woops", "Something went wrong at the server"));
         return Response_Object.Build;

   end Pickup;

   -------------
   --  Queue  --
   -------------
   --  TODO, extend the call list so that it will be able to return only
   --  inbound calls on this interface.

   function Queue
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use Common;
      package Call_List renames PBX.Call;

      Response_Object : Response.Object := Response.Factory (Request);
   begin
      --  Only return a call list when there actual calls in it.
      if not Call_List.List_Empty then
         Response_Object.HTTP_Status_Code (HTTP.OK);
         Response_Object.Content (To_JSON_String
                                    (PBX.Call.Queued_Calls));
      else
         Response_Object.HTTP_Status_Code (HTTP.No_Content);
      end if;

      return Response_Object.Build;
   exception
      when E : others =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => "List failed",
            Response_Object => Response_Object);
         return Response_Object.Build;

   end Queue;

   ----------------
   --  Transfer  --
   ----------------

   function Transfer
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use PBX.Call;

      Source          : PBX.Call.Identification := Null_Identification;
      Destination     : PBX.Call.Identification := Null_Identification;
      Response_Object : Response.Object :=
                          Response.Factory (Request);
   begin
      --  Check valitity of the call. (Will raise exception on invalid).
      Source      := Value (Parameters (Request).Get ("source"));
      Destination := Agent.Get
        (PBX.Call.Get
           (Source).Assigned_To).Current_Call;
      if
        Source      = Null_Identification or
        Destination = Null_Identification
      then
         raise PBX.Call.Invalid_ID;
      end if;

      PBX.Action.Bridge (Source      => Source,
                         Destination => Destination);

      Response_Object.HTTP_Status_Code (HTTP.OK);
      Response_Object.Content
        (Status_Message
           ("Success", "Transfer succeeded"));

      return Response_Object.Build;

   exception
      when Invalid_ID =>
         Response_Object.HTTP_Status_Code (HTTP.Bad_Request);
         Response_Object.Content
           (Status_Message
              ("Bad request", "Invalid or no call ID supplied"));
         return Response_Object.Build;

      when PBX.Call.Not_Found =>
         Response_Object.HTTP_Status_Code (HTTP.Not_Found);
         Response_Object.Content
           (Status_Message
              ("Not found", "No call found with ID " &
                 Parameters (Request).Get ("source")));
         return Response_Object.Build;

      when E : others =>
         System_Message.Critical.Response_Exception
           (Event           => E,
            Message         => "Transfer request failed",
            Response_Object => Response_Object);
         return Response_Object.Build;
   end Transfer;

end Handlers.Call;
