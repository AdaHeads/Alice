-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                                  Peers                                    --
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

with System_Messages;

package body Peers is
   use System_Messages;
   ----------------------------------------------------------------------------
   --  TODO Navngivning, Der er brug for nogle bedre navne her.
   protected Peers_List is
      function Get_Peers_List return Peer_List_Type.Map;
      function Get_Peer_By_ID (Agent_ID : in Unbounded_String)
                               return Peer_Type;
      function Get_Peer_By_PhoneName (PhoneName : in Unbounded_String)
                                      return Peer_Type;
      procedure Replace_Peer (Item : in Peer_Type);
      procedure Insert (New_Item : in Peer_Type);
      function List_As_String return String;
   private
      List : Peer_List_Type.Map;
   end Peers_List;

   protected body Peers_List is
      function Get_Peer_By_ID (Agent_ID : in Unbounded_String)
                               return Peer_Type is
      begin
         for item in List.Iterate loop
            System_Messages.Notify (Debug, "Peers.Get_Peer. [" & To_String (
                        Peer_List_Type.Element (item).Agent_ID) &
                        "] = ["
                       & To_String (Agent_ID) & "]");
            if Peer_List_Type.Element (item).Agent_ID = Agent_ID then
               return Peer_List_Type.Element (item);
            end if;
         end loop;
         return Null_Peer;
      end Get_Peer_By_ID;

      function Get_Peer_By_PhoneName (PhoneName : in Unbounded_String)
                                      return Peer_Type is
         use Peer_List_Type;
         Peer_Cursor : constant Peer_List_Type.Cursor := List.Find (PhoneName);
      begin
         if Peer_Cursor = Peer_List_Type.No_Element then
            return Null_Peer;
         else
            --  ???? Hvorfor kan jeg ikke få lov (continued)
            --       til at bruge den cursor jeg har - Peer_Cursor
            return List.Element (PhoneName);
         end if;
      end Get_Peer_By_PhoneName;

      function Get_Peers_List return Peer_List_Type.Map is
      begin
         return List;
      end Get_Peers_List;

      procedure Insert (New_Item : in Peer_Type) is
      begin
         System_Messages.Notify (Debug, "Inserted a new peer: " &
                           To_String (New_Item.Peer));
         Peer_List_Type.Insert (Container => List,
                                Key       => New_Item.Peer,
                                New_Item  => New_Item);
      end Insert;

      function List_As_String return String is
         Result : Unbounded_String;
         CRLF : constant String := (ASCII.CR, ASCII.LF);
      begin
         for Item of List loop
            Append (Result, Item.Peer & CRLF);
         end loop;
         return To_String (Result);
      end List_As_String;

      procedure Replace_Peer (Item : in Peer_Type) is
         use Peer_List_Type;
         Peer_Cursor : constant Peer_List_Type.Cursor :=
           Peer_List_Type.Find (List, Item.Peer);
      begin
         if Peer_Cursor /= Peer_List_Type.No_Element then
            Peer_List_Type.Replace_Element (Container => List,
                                            Position  => Peer_Cursor,
                                            New_Item  => Item);
         end if;
      end Replace_Peer;
   end Peers_List;

   --  TODO change it to use a database.
   function Get_Exten (Peer : in Unbounded_String) return Unbounded_String is
      Exten : Unbounded_String;
      Peer_String : constant String := To_String (Peer);
   begin
      if Peer_String = "softphone1" then
         Exten := To_Unbounded_String ("100");
      elsif Peer_String = "softphone2" then
         Exten := To_Unbounded_String ("101");
      elsif Peer_String = "DesireZ" then
         Exten := To_Unbounded_String ("102");
      elsif Peer_String = "TP-Softphone" then
         Exten := To_Unbounded_String ("103");
      elsif Peer_String = "JSA-N900" then
         Exten := To_Unbounded_String ("104");
      else
         System_Messages.Notify (Debug,
                         "Could not find an Extension for: " & Peer_String);
         Exten := Null_Unbounded_String;
      end if;
      return Exten;
   end Get_Exten;

   function Get_Peer_By_ID (Agent_ID : in Unbounded_String) return Peer_Type is
   begin
      return Peers_List.Get_Peer_By_ID (Agent_ID);
   end Get_Peer_By_ID;

   function Get_Peer_By_PhoneName (PhoneName : in Unbounded_String)
                                      return Peer_Type is
   begin
      return Peers_List.Get_Peer_By_PhoneName (PhoneName);
   end Get_Peer_By_PhoneName;

   function Get_Peers_List return Peer_List_Type.Map is
   begin
      return Peers_List.Get_Peers_List;
   end Get_Peers_List;

   function Hash (Peer_Address : in Unbounded_String) return Hash_Type is
   begin
      return Ada.Strings.Hash (To_String (Peer_Address));
   end Hash;

   procedure Insert_Peer (New_Item : in Peer_Type) is
   begin
      Peers_List.Insert (New_Item);
   end Insert_Peer;

--     procedure Print_Peer (Peer : in Peer_Type) is
--        use Ada.Text_IO;
--     begin
--        Put ("Peer => "   & To_String (Peer.Peer) & ", ");
--        case Peer.Status is
--        when Unregistered =>
--           Put ("Status => Unregistered, ");
--        when Registered =>
--           Put ("Status => Registered, ");
--           --  when others =>
--           --     raise PROGRAM_ERROR;
--        end case;
--
--        Put ("Address => " & To_String (Peer.Address) & ", ");
--        Put ("Channel_Type => " & To_String (Peer.ChannelType) & ", ");
--        Put ("Port => " & To_String (Peer.Port) & ", ");
--        Put ("Exten => " & To_String (Peer.Exten) & ", ");
--        Put ("Last_Seen =>
--     " & Ada.Calendar.Formatting.Image (Peer.Last_Seen));
--        New_Line;
--
--     end Print_Peer;
   function List_As_String return String is
   begin
      return Peers_List.List_As_String;
   end List_As_String;

   procedure Replace_Peer (Item : in Peer_Type) is
   begin
      Peers_List.Replace_Peer (Item);
   end Replace_Peer;
end Peers;
