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

with JSON;

with Common,
     Model.User.List,
     Model.Token,
     Model.Token.List,
     HTTP_Codes,
     Response,
     System_Message.Critical,
     View;

package body Handlers.Authenticated_Dispatcher is
   function Key (Method : in     AWS.Status.Request_Method;
                 URI    : in     String) return String is
      use AWS.Status;
   begin
      return Request_Method'Image (Method) & ":" & URI;
   end Key;

   function Not_Authorized (Request : in     AWS.Status.Data)
                            return AWS.Response.Data is
      Response_JSON     : constant JSON.JSON_Value := JSON.Create_Object;
      Response_Object   : Response.Object := Response.Factory (Request);
   begin
      Response_JSON.Set_Field (Field_Name => View.Status,
                               Field      => "not authorized");

      Response_Object.HTTP_Status_Code (Value => HTTP_Codes.Unauthorized);
      Response_Object.Content (Common.To_JSON_String (Response_JSON));
      return
        Response_Object.Build;
   end Not_Authorized;

   procedure Register (Method     : in     AWS.Status.Request_Method;
                       URI        : in     String;
                       Allowed    : in     Authentication;
                       Action     : in     AWS.Response.Callback) is
   begin
      Handler_List.Insert (Key      => Key (Method => Method,
                                            URI    => URI),
                           New_Item => (Public  => Allowed.Public,
                                        Allowed => Allowed,
                                        Action  => Action));
   end Register;

   function Run (Request : in     AWS.Status.Data) return AWS.Response.Data is
      use AWS.Status;
      use Model;
      use Model.User;
      use Model.User.List;

      Request_Key : constant String := Key (Method => Method (Request),
                                            URI    => URI (Request));
   begin

      if Handler_List.Contains (Request_Key) then
         declare
            Selected : constant Handler := Handler_List.Element (Request_Key);
            Allowed  : Authentication renames Selected.Allowed;
            User_Token    : Token.Instance;
            Detected_User : User.Instance := No_User;
         begin

            if Parameters (Request).Exist ("token") then
               User_Token :=
                 Token.Create (Value => Parameters (Request).Get ("token"));
               Detected_User :=
                 User.List.Get_Singleton.Get
                 (Identity => Token.List.Get_Singleton.Look_Up
                    (User_Token));
            end if;

            if Allowed.Public then
               return Selected.Action (Request);
            elsif
              (Detected_User.Permissions and Allowed.As) = No_Permissions
              or
                Detected_User = No_User
            then
               return Not_Authorized (Request);
            else
               return Selected.Action (Request);
            end if;
         end;
      else
         return Default_Action (Method (Request)) (Request);
      end if;
   exception
      when Event : others =>
         --  For now we assume that "other" exceptions caught here are bad
         --  enough to warrant a critical level log entry and response.
         declare
            Response_Object : Response.Object := Response.Factory (Request);
         begin
            System_Message.Critical.Response_Exception
              (Event           => Event,
               Message         => Response_Object.To_Debug_String,
               Response_Object => Response_Object);
            return Response_Object.Build;
         end;
   end Run;

   procedure Set_Default (Method : in     AWS.Status.Request_Method;
                          Action : in     AWS.Response.Callback) is
   begin
      Default_Action (Method) := Action;
   end Set_Default;

   procedure Set_Default (Action : in     AWS.Response.Callback) is
   begin
      Default_Action := (others => Action);
   end Set_Default;
end Handlers.Authenticated_Dispatcher;
