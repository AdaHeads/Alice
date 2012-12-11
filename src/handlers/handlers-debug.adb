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

with Common;
with HTTP_Codes;
with Response;
with Model.Peers;
with Model.Channels;

package body Handlers.Debug is
   use Common;
   use Model;

   function Channel_List (Request : in AWS.Status.Data)
                          return AWS.Response.Data is
      use HTTP_Codes;

      Response_Object : Response.Object := Response.Factory (Request);
   begin
      Response_Object.HTTP_Status_Code (OK);
      Response_Object.Content
        (To_JSON_String (Channels.List.To_JSON.Write));

      return Response_Object.Build;
   end Channel_List;

   function Peer_List (Request : in AWS.Status.Data)
                       return AWS.Response.Data is
      use HTTP_Codes;

      Response_Object : Response.Object := Response.Factory (Request);
   begin
      Response_Object.HTTP_Status_Code (OK);
      Response_Object.Content
        (To_JSON_String (Peers.List.To_JSON.Write));

      return Response_Object.Build;
   end Peer_List;

end Handlers.Debug;
