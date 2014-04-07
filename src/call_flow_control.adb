-------------------------------------------------------------------------------
--                                                                           --
--                      Copyright (C) 2012-, AdaHeads K/S                    --
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

with
  Ada.Exceptions;
with
  PBX,
  Build_Constants,
  Configuration,
  HTTP_Server,
  SIGHUP,
  SIGHUP_Handler,
  System_Messages,
  Util.Command_Line,
  Util.Process_Control;

procedure Call_FLow_Control is
   use System_Messages;
   use Util;
   use Build_Constants;
   use Command_Line;

   Context : constant String := "Call-Flow_Control";

begin
   if Util.Command_Line.Got_Argument ("--help") then
      Configuration.Show_Arguments;
      Util.Command_Line.Set_Exit_Failure;
   else
      SIGHUP.Register (Handler => SIGHUP_Handler.Caught_Signal'Access);

      Configuration.Load_Config;

      System_Messages.Open_Log_Files;

      PBX.Start;
      HTTP_Server.Listen (On_Port => Configuration.HTTP_Port);

      Util.Process_Control.Wait;
      --  Wait here until we get a SIGINT, SIGTERM or SIGPWR.

      HTTP_Server.Stop;
      PBX.Stop;
      SIGHUP.Stop;
      System_Messages.Close_Log_Files;

      System_Messages.Information
        (Message => Server_Name & " shutdown complete.",
         Context => Context);
   end if;
exception
   when Event : others =>
      System_Messages.Critical
        (Message => "Shutting down due to unhandled exception: " &
                    Ada.Exceptions.Exception_Information (Event),
         Context => Context);
      HTTP_Server.Stop;
      PBX.Stop;
end Call_FLow_Control;
