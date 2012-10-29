with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;

with AMI;
with AMI.Client; 
with AMI.Response; 
with AMI.Parser;
with AMI.Event;
with AMI.Callback;
  
with Connection_Management;
with Configuration;
with System_Messages; use  System_Messages;
with My_Callbacks;


procedure Asterisk_AMI_Test is
   use AMI;
   use AMI.Client;
   use AMI.Parser;
   use AMI.Event;
   use Ada.Strings.Unbounded;
   
   Client : aliased Client_Type;
   Client_Access : constant access Client_Type := Client'Access;
   
   Callbacks : AMI.Event.Event_Callback_Table := 
     (Peerstatus => My_Callbacks.Peer_Status'Access,
      Hangup     => My_Callbacks.Hangup'Access,
      Join       => My_Callbacks.Join'Access,
      Newchannel => My_Callbacks.New_Channel'Access,
      Newstate   => My_Callbacks.New_State'Access,
      Dial       => My_Callbacks.Dial'Access,
      others     => AMI.Event.Null_Callback'Access);   
    
   package My_Connection_Manager is new Connection_Management 
     (Client   => Client_Access,
      Hostname => Configuration.Hostname,
      Port     => Configuration.Port);
   
   procedure Authenticate is
   begin
      My_Connection_Manager.Wait_For_Connection;
      
      Login (Client   => Client_Access, 
	     Username => Configuration.Username, 
	     Secret   => Configuration.Secret);
   end Authenticate;
   
   --  task type Connection_Manager_Task (Server : Asterisk_Server_Access) is
   --     entry Start;
   --  end Connection_Manager_Task;
   
   
   procedure Dispatch (Client : access Client_Type;
		       Packet : in     AMI.Parser.Packet_Type) is
      use AMI.Parser;  --AMI_Key_Type
   begin
      if Packet.Header.Key = AMI.Parser.Response then
	 AMI.Response.Notify (Client => Client, 
			      Packet => Packet);
      elsif Packet.Header.Key = AMI.Parser.Event then
	 
	 AMI.Event.Dispatch (Callback_Table => Callbacks, 
			     Packet         => Packet);
      else
	 System_Messages.Notify (Error, "Main.Dispatch: Bad header " & 
				   Packet.Header.Key'Img);
      end if;
   exception
      when Error: others =>
	 System_Messages.Notify (Debug,"Main.Dispatch: Unexpected exception: ");
	 System_Messages.Notify (Debug, Ada.Exceptions.Exception_Information(Error));
	 System_Messages.Notify (Debug,"");
	 System_Messages.Notify (Debug,"------------ Packet dump start ------");
	 System_Messages.Notify (Debug, Image(Packet));
	 System_Messages.Notify (Debug,"------------ Packet dump end ------");
	 System_Messages.Notify (Debug,"");
   end Dispatch;
   
   procedure Parser_Loop is
   begin
      loop
	 Dispatch (Client_Access,Read_Packet(Client_Access));
      end loop;
   exception
      when Error: others =>
	 System_Messages.Notify (Debug,"Reader_Loop: Unexpected exception: ");
	 System_Messages.Notify (Debug, Ada.Exceptions.Exception_Information(Error));
	 System_Messages.Notify (Debug,"Reader_Loop: Signalling disconnect: ");
	 My_Connection_Manager.Signal_Disconnect;
	 Client.Connected := False;
	 Authenticate;
   end Parser_Loop;
   
   task type Reader_Task is 
      entry Start;
   end Reader_Task;
   
   task body Reader_Task is
   begin
      accept Start;
      Parser_Loop;
   exception
      when Error: others =>
	 Ada.Text_IO.Put ("Reader: Unexpected exception: ");
	 Ada.Text_IO.Put (Ada.Exceptions.Exception_Information(Error));
   end Reader_Task;
   
   Reader : Reader_Task;
   
begin
   My_Connection_Manager.Start;
   Authenticate;
   
   
   delay 1.0;
   Reader.Start;

   loop
      while not Client.Connected loop
   	 delay 0.1;
      end loop;
      Ping (Client_Access);
      delay 60.0;
      
   end loop;
   
exception
   when E : others =>
      Ada.Text_IO.Put ("Main task: Unexpected exception: ");
      Ada.Text_IO.Put (Ada.Exceptions.Exception_Information(E));
end Asterisk_AMI_Test;
