-------------------------------------------------------------------------------
--                                                                           --
--                                  Alice                                    --
--                                                                           --
--                            Contact_Attributes                             --
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

with Database;
with GNATCOLL.JSON;
with Yolk.Utilities;

package body Contact_Attributes is

   ----------------
   --  Callback  --
   ----------------

   function Callback
     return AWS.Dispatchers.Callback.Handler
   is
   begin
      return AWS.Dispatchers.Callback.Create (JSON_Response.Generate'Access);
   end Callback;

   -------------------
   --  Create_JSON  --
   -------------------

   procedure Create_JSON
     (C     : in out Cursor;
      Value : in out Common.JSON_String)
   is
      use Common;
      use GNATCOLL.JSON;
      use Yolk.Utilities;

      Attr_Array : JSON_Array;
      DB_Columns : JSON_Value;
      DB_JSON    : JSON_Value;
      J          : constant JSON_Value := Create_Object;
   begin
      while C.Has_Row loop
         DB_Columns := Create_Object;
         DB_JSON    := Create_Object;

         DB_JSON := GNATCOLL.JSON.Read (To_String (C.Element.JSON),
                                        "contact_attributes.json.error");

         DB_Columns.Set_Field (TS (C.Element.Ce_Id_Column_Name),
                               C.Element.Ce_Id);

         DB_Columns.Set_Field (TS (C.Element.Org_Id_Column_Name),
                               C.Element.Org_Id);

         DB_JSON.Set_Field ("db_columns", DB_Columns);

         Append (Attr_Array, DB_JSON);

         C.Next;
      end loop;

      J.Set_Field ("attributes", Attr_Array);

      Value := To_JSON_String (J.Write);
   end Create_JSON;

   ---------------
   --  Element  --
   ---------------

   function Element
     (C : in Cursor)
      return Row
   is
      use Common;
      use Yolk.Utilities;
   begin
      return Row'(JSON                 => To_JSON_String (C.Value (0)),
                  Ce_Id                => C.Integer_Value (1, Default => 0),
                  Ce_Id_Column_Name    => TUS (C.Field_Name (1)),
                  Org_Id               => C.Integer_Value (2, Default => 0),
                  Org_Id_Column_Name   => TUS (C.Value (2)));
   end Element;

   ----------------------
   --  Prepared_Query  --
   ----------------------

   function Prepared_Query
     return GNATCOLL.SQL.Exec.Prepared_Statement
   is
      package DB renames Database;

      use GNATCOLL.SQL;
      use GNATCOLL.SQL.Exec;

      Get_Contact_Attributes : constant SQL_Query
        := SQL_Select (Fields =>
                         DB.Contactentity_Attributes.Json &  --  0
                         DB.Contactentity_Attributes.Ce_Id & --  1
                         DB.Contactentity_Attributes.Org_Id, --  2
                       Where  =>
                         DB.Contactentity_Attributes.Ce_Id =
                           (Integer_Param (1)));

      Prepared_Get_Contact_Attributes : constant Prepared_Statement
        := Prepare (Query         => Get_Contact_Attributes,
                    Auto_Complete => True,
                    On_Server     => True,
                    Name          => "get_contact_attributes");
   begin
      return Prepared_Get_Contact_Attributes;
   end Prepared_Query;

   ------------------------
   --  Query_Parameters  --
   ------------------------

   function Query_Parameters
     (Request : in AWS.Status.Data)
      return GNATCOLL.SQL.Exec.SQL_Parameters
   is
      use GNATCOLL.SQL.Exec;
   begin
      return (1 => +Natural'Value (Response.Get_Ce_Id_Key (Request)));
   end Query_Parameters;

end Contact_Attributes;
