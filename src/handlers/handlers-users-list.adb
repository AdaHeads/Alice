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

with GNATCOLL.JSON;

with Alice_Configuration,
     Common,
     Model.User,
     Model.Users,
     Response.Error_Messages,
     Response.Not_Cached,
     View.Users;

package body Handlers.Users.List is

   function Public_User_Identification return Boolean
     renames Alice_Configuration.Public_User_Identification;

   ----------------------------------------------------------------------------

   procedure Generate_Document (Instance : in out Response.Object);
   --  Add a generated JSON_String to Response_Object.

   function JSON_Response is
      new Response.Not_Cached.Generate_Response
            (Public            => Public_User_Identification,
             Allowed           => (Model.User.Receptionist  => False,
                                   Model.User.Service_Agent => False,
                                   Model.User.Administrator => True),
             Generate_Document => Generate_Document);
   --  Generate the AWS.Response.Data that ultimately is delivered to the user.

   ----------------------------------------------------------------------------

   function Callback return AWS.Response.Callback is
   begin
      return JSON_Response'Access;
   end Callback;

   procedure Generate_Document
     (Instance : in out Response.Object)
   is
      use GNATCOLL.JSON;
      use Common;

      Data : JSON_Value;
   begin
      Data := Create_Object;

      if Public_User_Identification then
         if Instance.Parameter_Count = 0 then
            Data.Set_Field (Field_Name => View.Status,
                            Field      => "okay");
            Data.Set_Field (Field_Name => View.Users_S,
                            Field      => View.Users.To_JSON
                                            (Model.Users.List));

            Instance.Content (To_JSON_String (Data));
         else
            Response.Error_Messages.Too_Many_Parameters (Instance);
         end if;
      else
         Response.Error_Messages.Not_Authorized (Instance);
      end if;
   end Generate_Document;

end Handlers.Users.List;
