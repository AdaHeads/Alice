-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                              Model.Channels                               --
--                                                                           --
--                                  SPEC                                     --
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

with Ada.Containers.Indefinite_Ordered_Maps;

with GNATCOLL.JSON;

with Model.Channel;
with Model.Channel_ID;

package Model.Channels is
   use Model;

   CHANNEL_NOT_FOUND : exception;
   DUPLICATE_ID      : exception;

   type Channel_Process_Type is not null access
     procedure (C : in Channel.Channel_Type);

   package Channel_List_Type is new
     Ada.Containers.Indefinite_Ordered_Maps
       (Key_Type     => Channel_ID.Instance,
        Element_Type => Channel.Channel_Type,
        "<"          => Channel_ID."<",
        "="          => Channel."=");

   protected type Protected_Channel_List_Type is
      function Contains (Key : in Channel_ID.Instance) return Boolean;
      procedure Insert (Item : in Channel.Channel_Type);
      procedure Remove (Key : in Channel_ID.Instance);
      function Get (Key : in Channel_ID.Instance) return Channel.Channel_Type;
      function Length return Natural;
      function To_JSON return GNATCOLL.JSON.JSON_Value;
      function To_String return String;
      procedure Update (Item : in Channel.Channel_Type);
   private
      Protected_List : Channel_List_Type.Map;
   end Protected_Channel_List_Type;

   List : Protected_Channel_List_Type;
   --  Package-visible singleton.
end Model.Channels;
