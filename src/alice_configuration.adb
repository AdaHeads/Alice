-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2013-, AdaHeads K/S                     --
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

with System_Message.Critical;

package body Alice_Configuration is
   function Public_User_Identification return Boolean is
   begin
      return Config.Get (Public_User_Identification);
   exception
      when others =>
         System_Message.Critical.Configuration_Error
           (Message => "The 'Public_User_Identification' configuration " &
                       "field is a Boolean.");
         return False;
   end Public_User_Identification;
begin

   Log_Unsafe_Mode :
   begin
      if Config.Get (Unsafe_Mode) then
         System_Message.Critical.Running_In_Unsafe_Mode;
      end if;
   exception
      when others =>
         System_Message.Critical.Configuration_Error
            (Message => "The 'Unsafe_Mode' configuration field is a Boolean.");
   end Log_Unsafe_Mode;

end Alice_Configuration;
