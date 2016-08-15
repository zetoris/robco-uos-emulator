{                         4.0.0                         }
{ 	     RobCo Unified Operating System Emulator		}
{	       Coded by Zetoris (The MIT License)			}
{        www.zetoris.info | www.vk.com/zetoris			}
{          Version 4.0 'Goodsprings' - 2015 			}
{            Compiled in Turbo Pascal 7.1				}

{============================================= Program}
	PROGRAM TERMINAL;
	{$M $4000, 0, 0 } {doing magic with memory} 
	USES CRT, DOS;
{============================================= Vars}
	VAR out_text1, in_text1, in_text2:string;
		login, password:string[18];
		capitalization_input, text_to_slow, text_to_trim, text_to_view, menu_func_to_parse:string;
		true_login, true_password, pass_key, pass_comb, pass_temp, gen_password, fake_password, new_login, new_password:string;
		password_displayed, pass_lenght, ent_pass_lenght, true_pass_lenght, terminal_mode, log_ext:integer;
		q,w,e,r,t,y,u,i,o,p,a,s,d,valcode:integer; {int for cycles etc}
		termlink_result, rand_max, hack_attempt: integer;
		input_key:char;{for input keys in autofill section}
		pass_random_word_f1, pass_random_word_f2:String;
		pass_array_used: array [1..20] of Integer;
		pass_array_sym: array [1..20] of String[1];
		pass_array_5ch: array [1..20] of String[5];
		pass_array_6ch: array [1..20] of String[6];
		pass_array_7ch: array [1..20] of String[7];
		pass_array_8ch: array [1..20] of String[8];
		pass_array_9ch: array [1..20] of String[9];
		pass_array_10ch: array [1..20] of String[10];
		pass_array_11ch: array [1..20] of String[11];
		pass_array_12ch: array [1..20] of String[12];
		settings_file_backup: array [1..10] of String;
			
		docs_files_menu: array[1..5, 1..35] of String[42];
		docs_file_sysname: array[1..5, 1..35] of String[12];{8+.txt}
			
		docs_files_counter:integer;
		docs_pages_counter:integer;
		docs_files_counter_overall:integer;
		docs_edit_mode:string;
		editor_mode_edit:integer;
		
		docs_file_to_edit, docs_file_to_delete: string;
		docs_creating_doc_title: string[42];
		docs_creating_file_name: string[8];
		
		docs_editor_text: array[1..70, 1..68] of String[1];{array for text}
				
		kiosk_title_text, file_kiosk_title_name:string;
			
		minigame_field_1, minigame_field_2, table_numbers_f1, table_numbers_f2:String;
		file_settings, file_menu, file_block, file_kiosk_title: text;
		file_settings_name, file_menu_name, file_block_name:string;
		from_file:string;
		terminal_blocked, terminal_delay, terminal_color:integer;
		menu_1_title, menu_2_title, menu_3_title, menu_4_title: string;
		items_count, menu_submenu, dbg:integer;
		
		menu_name: array [1..4, 1..7] of String;
		menu_func: array [1..4, 1..7] of String;
		
		{----port----}
		pin_status: array [1..5] of integer;
		pin_number, pin_state: integer;
	
	LABEL logout;
{========================================================================================== Functions}

{================================================================}
{===================================== TEXT OUTPUT LETTERbyLETTER}
{================================================================}
	function slow_text_output(text_to_slow : string) : string; 
	var lngt:integer;
		begin
			lngt:=length(text_to_slow);
			for i:=1 to lngt do
				begin
					write(text_to_slow[i]);
					delay(terminal_delay);
				end;			
		end;

	function slow_text_output_docs(text_to_slow : string) : string; 
	var lngt,strng,wrd:integer;
		begin
			lngt:=length(text_to_slow);
		 	for i:=1 to lngt do
				begin
					if(strng<45)then 
						begin
							strng:=strng+1;
							write(text_to_slow[i]);
						end
					else
						begin 
							if(text_to_slow[i]=' ') then
								begin
									strng:=0;
									writeln;
								end
							else if (text_to_slow[i]=',') or (text_to_slow[i]='.') or (text_to_slow[i]='!') 
							or (text_to_slow[i]=';') or (text_to_slow[i]=':') or (text_to_slow[i]='-') or (text_to_slow[i]='"') then
								begin
									writeln(text_to_slow[i]);
									i:=i+1;
									strng:=0;
								end
							else
								begin
									strng:=strng+1;
									if(strng>51)then 
										begin
											writeln(text_to_slow[i],'-');
											strng:=0;
										end
									else
										begin
											write(text_to_slow[i]);
										end;								
								end;
						end;
					
					
					delay(terminal_delay);
				end;			
		end;

	function menu_trim_line(text_to_trim : string) : string; 
	var lngt, lngt2, tofill:integer;
		filler:string;
		begin
			lngt:=length(text_to_trim);
			filler:='                                             ';
			lngt2:=length(filler);
			tofill:=lngt2-lngt;
			for i:=1 to tofill do begin text_to_trim:=text_to_trim+' '; end;
			writeln(text_to_trim);
		end;

{========================================================================================== Procedures}
{================================================================}
{========================================= WORKING WITH LPT1 PORT}
{================================================================}
{setting different pins (from 1 to 5 pin) state on lpt     }
{more info http://zps-electronics.com/shema/lpt_programing/}
	procedure port_state_change(pin_number : integer; pin_state : integer);
	var SendToPort,GetFromPort:byte;										  
		pin_hard_number:integer;
		begin
			GetFromPort:=Port[$378];		
			{ ---- pins real adresses ---- }
			if(pin_number	 =  1) then 
				begin
					pin_hard_number:=1;
				end
			else if(pin_number=2) then 
				begin
					pin_hard_number:=2;
				end
			else if(pin_number=3) then 
				begin
					pin_hard_number:=4;
				end	
			else if(pin_number=4) then 
				begin
					pin_hard_number:=8;
				end	
			else if(pin_number=5) then 
				begin
					pin_hard_number:=16;
				end;			
			{ ---------------------------- }

			if(pin_state=1)and(pin_status[pin_number]<>1)then{turn pin on, check if it already on}
				begin
					pin_status[pin_number]:=1;{array to keep pin states}
					SendToPort:=GetFromPort+pin_hard_number;{getting pins pattern number}
					Port[$378]:=SendToPort;{sending to port}
				end
			else if (pin_state=0)and(pin_status[pin_number]<>0) then{turn pin off, check if it already off}
				begin
					pin_status[pin_number]:=0;{array to keep pin states}
					SendToPort:=GetFromPort-pin_hard_number;{getting pins pattern number}
					Port[$378]:=SendToPort;{sending to port}
				end;
		end;

{================================================================}
{=========================================== SHUTDOWN and LOGOUT }
{================================================================}	
	procedure terminal_shutdown;
		begin
			window(1,1,80,25); ClrScr;		
			window(34,9,55,12);
			writeln('-------------');writeln('SHUTTING DOWN');writeln('-------------');
			window(1,1,80,25);
			delay(terminal_delay*40);
			for i:=1 to 60 do
				begin
					writeln;
					delay(terminal_delay*10);
				end;
			ClrScr;
			port_state_change(1,0);
			repeat {exit by enter, not allowing to input characters}
				input_key:=ReadKey;		
			until input_key=#27;
			halt;
		end;

	procedure terminal_logout;
		begin
			window(1,1,80,25); ClrScr;		
			window(34,9,55,12);
			writeln('-------------');writeln(' LOGGING OUT ');writeln('-------------');
			window(1,1,80,25);
			delay(terminal_delay*40);
			for i:=1 to 35 do
				begin
					writeln;
					delay(terminal_delay*10);
				end;
			ClrScr;
			login:='null'; 
			password:='null'; 
			input_key:='0';
			pass_comb:='';
			termlink_result:=0;
			exit;
		end;

{================================================================}
{============================================= OUTPUT TEXT/DESIGN}
{================================================================}
	procedure header_termlink;
		begin
			ClrScr;
			TextColor(terminal_color);
			out_text1:='WELCOME TO ROBCO INDUSTRIES (TM) TERMLINK'+#13#10 +#13#10 +'';
			q:=1;
			w:=length(out_text1)+1;
			WHILE q<w do
			begin
			write(out_text1[q]);
			delay(terminal_delay);
			q:=q+1;
			end;
		end;

	procedure hack_version_loading;
		begin
			out_text1:=+#13#10+'RIT-V300'+#13#10;
			q:=1;
			w:=length(out_text1)+1;
			WHILE q<w do
			begin
			write(out_text1[q]);
			delay(terminal_delay);
			q:=q+1;
			end;
		end;
		
	procedure hack_bios_loading;
		begin
			out_text1:='Initializing Robco Industries(TM) MF Boot Agent v2.3.0'+'RETROS BIOS'+#13#10;
			out_text1:=out_text1+'RBIOS-4.02.08.00 52EE5.E7.E8'+#13#10+'Copyright 2201-2203 Robco Ind.'+#13#10+'Uppermem: 64 KB'+#13#10;
			out_text1:=out_text1+'Root (5A8)'+#13#10+'Maintenance Mode';
			q:=1;
			w:=length(out_text1)+1;
			WHILE q<w do
			begin
			write(out_text1[q]);
			delay(terminal_delay*2);
			q:=q+1;
			end;
		end;
		
	procedure desktop_header;
		begin
			ClrScr;
			TextColor(terminal_color);
			out_text1:='      ROBCO INDUSTRIES UNIFIED OPERATING SYSTEM'+#13#10;
			out_text1:=out_text1+'        COPYRIGHT 2075-2077 ROBCO INDUSTRIES'+#13#10;
			out_text1:=out_text1+'                     -Server 1-'+#13#10;
			q:=1;
			w:=length(out_text1)+1;
			WHILE q<w do
			begin
			write(out_text1[q]);
			delay(terminal_delay);
			q:=q+1;
			end;
		end;

	procedure desktop_welcome;
		begin
			out_text1:='Welcome, '+true_login+#13#10;
			out_text1:=out_text1+'______________________________'+#13#10;
			q:=1;
			w:=length(out_text1)+1;
			WHILE q<w do
			begin
			write(out_text1[q]);
			delay(terminal_delay);
			q:=q+1;
			end;
		end;
		
	procedure minigame_header;
		begin
			out_text1:='ROBCO INDUSTRIES (TM) TERMLINK PROTOCOL'+#13#10;
			out_text1:=out_text1+'ENTER PASSWORD NOW'+#13#10;
			q:=1;
			w:=length(out_text1)+1;
			WHILE q<w do
			begin
			write(out_text1[q]);
			delay(terminal_delay);
			q:=q+1;
			end;
		end;
		
{================================================================}
{============================================ INPUT TEXT/AUTOFILL}
{================================================================}
	procedure input_command_1;
		begin
			in_text1:='SET FILE/PROTECTION=OWNER:RWED ACCOUNTS.F';
			q:=1;
			w:=length(in_text1)+1;
			WHILE q<w do
			begin
			input_key:=ReadKey;
				if (input_key<>#27)and(input_key<>#13)and(input_key<>#10)and(input_key<>#8)and
                   (input_key<>#127)and(input_key<>#9)and(input_key<>#15)and(input_key<>#0) then
					begin
						write(in_text1[q]);
						q:=q+1;
					end;
			end;
			repeat {waiting for enter}
			input_key:=ReadKey;
			until input_key=#13;
		end;

	procedure input_command_2;
		begin
			in_text1:='SET HALT RESTART/MAINT';
			q:=1;
			w:=length(in_text1)+1;
			WHILE q<w do
			begin
			input_key:=ReadKey;
				if (input_key<>#27)and(input_key<>#13)and(input_key<>#10)and(input_key<>#8)and
                   (input_key<>#127)and(input_key<>#9)and(input_key<>#15)and(input_key<>#0) then
					begin
						write(in_text1[q]);
						q:=q+1;
					end;
			end;
			repeat {waiting for enter}
			input_key:=ReadKey;
			until input_key=#13;
		end;
		
	procedure input_command_3;
		begin
			in_text1:='RUN DEBUG/ACCOUNTS.F';
			q:=1;
			w:=length(in_text1)+1;
			WHILE q<w do
			begin
			input_key:=ReadKey;
				if (input_key<>#27)and(input_key<>#13)and(input_key<>#10)and(input_key<>#8)and
                   (input_key<>#127)and(input_key<>#9)and(input_key<>#15)and(input_key<>#0) then
					begin
						write(in_text1[q]);
						q:=q+1;
					end;
			end;
			repeat {waiting for enter}
			input_key:=ReadKey;
			until input_key=#13;
		end;
		
{================================================================}
{=============================================== INPUT CAPITALIZE}
{================================================================}
	procedure uppercase_input;
		begin
			capitalization_input:='';
			for i:=1 to 255 do
				begin
					capitalization_input:='';
				end;
			
			repeat 
			input_key:=ReadKey;
			
			if (input_key=#97)or(input_key=#98)or(input_key=#99)or(input_key=#100)or(input_key=#101)or(input_key=#102)or
			(input_key=#103)or(input_key=#104)or(input_key=#105)or(input_key=#106)or(input_key=#107)or(input_key=#108)or
			(input_key=#109)or(input_key=#110)or(input_key=#111)or(input_key=#112)or(input_key=#113)or(input_key=#114)or
			(input_key=#115)or(input_key=#116)or(input_key=#117)or(input_key=#118)or(input_key=#119)or(input_key=#120)or
			(input_key=#121)or(input_key=#122) then
					begin
						input_key:=Chr(Ord(input_key)-32);
						capitalization_input:=capitalization_input+input_key;
						write(input_key);
					end
			else if (input_key<>#27)and(input_key<>#13)and(input_key<>#10)and(input_key<>#8)and
					(input_key<>#127)and(input_key<>#9)and(input_key<>#15)and(input_key<>#0) then
					begin
						capitalization_input:=capitalization_input+input_key;
						write(input_key);
					end
			else if (input_key=#8)then
					begin
						s:=Length(capitalization_input);
						if(s>0) then
							begin
								delete(capitalization_input,s,1);
								{capitalization_input:=capitalization_input+input_key;}
								gotoXY(whereX-1,whereY);
								write(' ');
								gotoXY(whereX-1,whereY);
								{writeln(capitalization_input);debug}
							end;
					end
			else if (input_key=#27)then
					begin
						exit;
					end;
			{writeln(capitalization_input);{debug}
			
			until input_key=#13;
		end;

{================================================================}
{================================== LOGIN LOGICS (NOT A MINIGAME)}
{================================================================}
	procedure password_check;
		begin
			input_key:='0';
			pass_comb:='';
			password:='';
			writeln;
			slow_text_output(#13#10+'ENTER PASSWORD: '+#13#10+#13#10);
			write('>');
			
			repeat 
			input_key:=ReadKey;
			
			if (input_key=#97)or(input_key=#98)or(input_key=#99)or(input_key=#100)or(input_key=#101)or(input_key=#102)or
			(input_key=#103)or(input_key=#104)or(input_key=#105)or(input_key=#106)or(input_key=#107)or(input_key=#108)or
			(input_key=#109)or(input_key=#110)or(input_key=#111)or(input_key=#112)or(input_key=#113)or(input_key=#114)or
			(input_key=#115)or(input_key=#116)or(input_key=#117)or(input_key=#118)or(input_key=#119)or(input_key=#120)or
			(input_key=#121)or(input_key=#122) then
					begin
								input_key:=Chr(Ord(input_key)-32);
								pass_comb:=pass_comb+input_key;
								write('*');
					end
			else if (input_key<>#27)and(input_key<>#13)and(input_key<>#10)and(input_key<>#8)and
					(input_key<>#127)and(input_key<>#9)and(input_key<>#15)and(input_key<>#0) then
					begin
								pass_comb:=pass_comb+input_key;
								write('*');
					end
			else if (input_key=#8)then
					begin
						s:=Length(pass_comb);
						if(s>0) then
							begin
								delete(pass_comb,s,1);
								gotoXY(whereX-1,whereY);
								write(' ');
								gotoXY(whereX-1,whereY);
							end;
					end;
			{writeln(pass_comb); {debug}
			until input_key=#13;
			password:=pass_comb;	
		end;

{================================================================}
{============================================ MAIN HANDMADE INPUT}
{================================================================}
	procedure termlink_input;
		begin
            write('>');
			uppercase_input;
			in_text1:=capitalization_input;

		end;

{================================================================}
{======================================== TERMLINK MAIN PROCEDURE}
{================================================================}
	procedure termlink_main;
	LABEL TERMLINK;
		begin
			window(1,1,80,25);
			ClrScr;
			TextBackground(BLACK); TextColor(terminal_color);
			window(14,2,67,25);
			ClrScr;
			
			header_termlink;{+PROC+}
			
			TERMLINK:
			
			termlink_input;{+PROC+}

			if (in_text1='SET TERMINAL/INQUIRE') then
				begin
					writeln;
					hack_version_loading;{+PROC+}
					writeln; write('>');
					input_command_1;{+PROC+}
					writeln; write('>');
					input_command_2;{+PROC+}
					writeln; writeln;
					hack_bios_loading;{+PROC+}
					writeln; writeln; write('>');
					input_command_3;{+PROC+}
					writeln;
					termlink_result:=2;
					{GO TO MINIGAME}{EXIT POINT}
				end
			else if	(in_text1='HELP')or(in_text1='?') then
				begin
					writeln;				
					slow_text_output(' HELP:'+#13#10+'  LOGON [USERNAME]'+#13#10+'  VERSION'+#13#10+'  SET HALT'+#13#10);
					slow_text_output('  SET HALT RESTART'+#13#10+'  SET TERMINAL/INQUIRE'+#13#10+#13#10);
					goto TERMLINK;
				end
			else if	(in_text1='SET HALT')or(in_text1='EXIT')or(in_text1='Q')or(in_text1='HALT') then
				begin
					terminal_shutdown;
					Exit;
				end
			else if	(in_text1='SET HALT RESTART')or(in_text1='RESTART') then
				begin
					writeln; writeln;
					writeln('RESTARTING...');
				    delay(terminal_delay*70);
					header_termlink;
					goto TERMLINK;
				end
			else if	(in_text1='VERSION') then
				begin
					writeln;
					slow_text_output(' RobCo Unified Operating System v.85'+#13#10+' Copyright 2075-2077 RobCo Ind.'+#13#10);
					writeln;
					goto TERMLINK;
				end
			else if	(in_text1='INFO') then
				begin
					writeln;
					slow_text_output(' RobCo UOS Emulator by Zetoris (The MIT License)'+#13#10+
					' www.zetoris.info | www.vk.com/zetoris'+#13#10);
					slow_text_output(' Version 4.0 ''Goodsprings'' - 2015'+#13#10);
					slow_text_output(' Some rights may belong to Bethesda Softworks LLC'+#13#10);
					writeln;
					goto TERMLINK;
				end
			else
				begin
					in_text2:= copy(in_text1, 1, 6);
					login:=in_text1;
					delete(login, 1, 6);
					
					if (in_text2='LOGON ')or(in_text2='LOGON') then
						begin
							if login=true_login then
								begin
									password_check;{+PROC+}
									if password=true_password then
										begin
											writeln; termlink_result:=1; {GO TO DESKTOP}{EXIT POINT}
										end
									else
										begin
											writeln;									
											writeln; slow_text_output('ERROR: WRONG PASSWORD'+#13#10); writeln; goto TERMLINK;
										end;
								end
							else
								begin
									writeln;
									slow_text_output('ERROR: WRONG USERNAME'+#13#10);  writeln; goto TERMLINK;
								end;
						end
					else
						begin
						 writeln;
						 slow_text_output('ERROR: UNKNOWN COMMAND'+#13#10); 
						 writeln; goto TERMLINK;
						end;
				end;
		end;

{================================================================}{======================}{DOCUMENTS CODE BELOW}
{================================================================}
{===================================== TEXT OUTPUT FOR DOCUMENTS }
{================================================================}
	function docs_file_viewer(text_to_view : string) : string;
	var strng: integer;
		strings_on_page:integer;
		filename:string;
		fileass:text;
		Ch:char;
		last_char: array [1..2] of String[1];
		
		begin
			window(1,1,80,25);
			ClrScr;	
			window(14,2,67,25);
			TextBackground(BLACK);
			TextColor(terminal_color);
		
			
			desktop_header;{+PROC+}{!!!!!!!!!!!!!!!!!!!!!!!!!!!}
			writeln;

			if(terminal_mode = 1) then {kiosk mode on} 
				begin 
					slow_text_output(kiosk_title_text+#13#10);

					slow_text_output('______________________________'+#13#10);
					filename:='KIOSK/TEXTS/'+text_to_view;
				end
			else
				begin 
					slow_text_output('Sten-o-pool 3500 Word Processing System'+#13#10);
					slow_text_output('______________________________'+#13#10);
					filename:='DOCS/'+text_to_view;
				end;


				
			window(14,2,67,25);
			TextBackground(BLACK);
			TextColor(terminal_color);
				
			{==loading mark - on==}
				window(14,24,67,24);ClrScr;	
				write('> ');
				TextColor(terminal_color + Blink);
				write('Loading...');
				window(14,8,67,23);
				TextColor(terminal_color);
			{=====================}	


				
			{$i-}
			Assign(fileass, filename);
			Reset(fileass);
			{$i+}
					
			if IOResult <> 0 then 
				begin
					write{ln}('ERROR: FILE NOT FOUND (034)');
					repeat {waiting for enter}
						input_key:=ReadKey;
					until input_key=#13;
					exit;
				end;

			strng:=0;
			strings_on_page:=0;
			
			window(14,8,67,23);
			{----------------------------TEXT OUTPUT--------------------------------}
			while not Eof(fileass) do
			begin
				read(fileass, Ch);
				last_char[2]:=Ch;
			
				
				if(strings_on_page<=13)then
					begin			
						if(strng<53)then {54x25 is screen resolution in robco mode}
							begin
								if(Ch=#10){or(Ch=#13)}then 
									begin 
										write(Ch);
										strng:=0;
										strings_on_page:=strings_on_page+1;
									end
								else if(Ch=#13) then
									begin
										write(Ch);
										strng:=0;
									end
								else
									begin
										strng:=strng+1;
										write(Ch);
									end;										
							end
						else
							begin 
								if(Ch=' ')or(Ch=',')or(Ch='.')or(Ch='!')or(Ch=';')or(Ch=':')or(Ch='-')or(Ch='"')or(Ch='?')then 
									begin 
										write(Ch);
										strng:=0;
										strings_on_page:=strings_on_page+1;
									end
								else
									begin
										if(last_char[1]=' ')then
											begin
												write(' ');write(Ch);
												strng:=1;
												strings_on_page:=strings_on_page+1;
											end
										else
											begin
												write('-'); write(Ch);
												strng:=1;
												strings_on_page:=strings_on_page+1;
											end;
									end;	
							end;		
					end
				else
					begin
						write(Ch,'...'); {more text ahead}
						strng:=0;
						strings_on_page:=0;
					
						{loading mark - off}
						window(14,24,67,24); ClrScr;
						TextColor(terminal_color);
						write('> Next');
						{==================}	

						repeat{next page by enter, not allowing to input characters}
							input_key:=ReadKey;		
							if input_key=#27 then
								begin
									exit;
								end;
						until input_key=#13;
						

						{-----------------------------------}
						
						window(14,8,67,23);{clear screen from text}
						ClrScr;
						TextColor(terminal_color);
						
						{loading mark - on}
						window(14,24,67,24); ClrScr;	
						write('> ');
						TextColor(terminal_color + Blink);
						write('Loading...');
						window(14,8,67,23);
						TextColor(terminal_color);
						{=================}						
					
					end;
					
					last_char[1]:=last_char[2];
					delay(terminal_delay);	
			end;
			{-----------------------------------------------------------------------}	
			Close(fileass);		
			{loading mark - off}
			window(14,24,67,24); ClrScr;
			TextColor(terminal_color);
			write('> ');
			{==================}	
			
			repeat {exit by enter, not allowing to input characters}
				input_key:=ReadKey;		
			until input_key=#13;
		end;

{================================================================}
{========================================== FILE EXPLORER/PARSER }
{================================================================}
	procedure docs_file_parser;
	var DirInfo: SearchRec;
		filename_menu, file_path_local, file_path_rel: string;
		filename:string;
		fileass:text;
		txtpos, len: integer;
		begin
			docs_files_counter_overall:=0;
			docs_files_counter:=0;
			docs_pages_counter:=1;
			
			if(terminal_mode = 1) then {kiosk mode on} 
				begin 
					file_path_local:='KIOSK/TEXTS/*.TXT';
					file_path_rel:='KIOSK/TEXTS/';		
				end
			else
				begin 
					file_path_local:='DOCS/*.TXT';
					file_path_rel:='DOCS/';
				end;
						
			FindFirst(file_path_local, AnyFile, DirInfo);
			while DosError = 0 do
				begin
					docs_files_counter:=docs_files_counter+1;
					
					if(docs_files_counter>6) then {next page}
						begin 
							docs_files_menu[docs_pages_counter, docs_files_counter]:='> Next'; {add next button if mult. pages}
							docs_files_counter_overall:=docs_files_counter_overall+1;
							docs_pages_counter:=docs_pages_counter+1; 
							docs_files_counter:=1; 
						end;
					
					{filename1string:=DirInfo.Name;}
					
					{Getting first string from file and setting it as file title}				
					filename:=file_path_rel+DirInfo.Name;
					{$i-}
					Assign(fileass, filename);
					Reset(fileass);
					{$i+}
					
					if IOResult <> 0 then 
						begin
							write{ln}('ERROR: FILE NOT FOUND (ERRCRIT)');
							repeat {waiting for enter}
								input_key:=ReadKey;
							until input_key=#13;
							exit;
						end;
						
					readln(fileass, filename_menu);
					Close(fileass);
					
					{-----------------------------------------------------------}
					
				{ 	txtpos:=pos('.TXT', filenametrim);removing TXT
					if(txtpos>0) then
						begin
							delete(filenametrim, txtpos, 4);
						end;	 }		

					docs_files_menu[docs_pages_counter, docs_files_counter]:='> '+filename_menu; {DEBUG27}	
					docs_file_sysname[docs_pages_counter, docs_files_counter]:=DirInfo.Name;

					FindNext(DirInfo);				
				end;
	
			if(docs_pages_counter>1)then
				begin
							docs_files_menu[docs_pages_counter, docs_files_counter+1]:='> Back'; {add back button only if we have multiple pages}
				end;
		
		end;

{================================================================}
{============================================= TEXT EDITOR DELETE}
{================================================================}
	procedure docs_file_delete(docs_file_to_delete : string);
	var file_to_del: text;
		path_to_file: string;
		z: integer;
		begin 
						{ write(docs_file_to_delete); readln; }{debug}
						
						path_to_file:='DOCS/'+docs_file_to_delete;
						{$I-}
						Assign(file_to_del, path_to_file);
						Reset(file_to_del);
						Erase(file_to_del);
						Close(file_to_del);
						{$I+}			

						if IOresult<>0 then 
						begin { -- IF FILE DOESNT EXIST -- }
							write('ERROR: File not found (035)');
							repeat {waiting for enter}
								input_key:=ReadKey;
							until input_key=#13;
							exit;
						end;		
				
						for i:=0 to 5 do
							begin
								for z:=0 to 35 do
									begin
										docs_files_menu[i, z]:='';{erase array with menu titles}
									end;
							end;
									
						docs_file_parser;{reparse files}
			
						slow_text_output('File '+docs_file_to_delete+' deleted. Press Enter to exit.'); 
						
						repeat {exit by enter, not allowing to input characters}
						input_key:=ReadKey;		
						until input_key=#13;
						
						exit;
		end;  

{================================================================}
{============================================ EDITOR TEXT headers}
{================================================================}

	procedure docs_editor_headers;
	label redo,redo2;
		begin
		{ ---------------------header--------------------------------------------- }
		window(1,1,80,25); 
		ClrScr;
		window(14,2,67,25);
		TextBackground(BLACK); 
		TextColor(terminal_color);
		desktop_header;{+PROC+}
		writeln;
		
		slow_text_output('Sten-o-pool Text Editor - Creating new file'+#13#10);

		slow_text_output('______________________________'+#13#10);
		

		{ ------------------------------------------------------------------ }

			
			window(14,8,67,20);
			redo:
			writeln;
			slow_text_output('ENTER FILE NAME (8 LETTERS MAX):'+#13#10);
			writeln;
			write('> ');
			
			uppercase_input;
			writeln;

			if (length(capitalization_input)>1) and (length(capitalization_input)<9) then {length from 1 to 8 letters}
				begin
					docs_creating_file_name:=capitalization_input; 
				end
			else
				begin
					writeln;
					slow_text_output('ERROR! FILENAME LENGTH MUST BE FROM 1 TO 8 LETTERS!'+#13#10);
					goto redo;
				end;
			
			
			redo2:
			

			writeln;
			slow_text_output('ENTER DOCUMENT TITLE (42 LETTERS MAX):'+#13#10);
			writeln;
			write('> ');
			
			readln(docs_creating_doc_title);
			
			writeln;
			if (length(docs_creating_doc_title)>1) and (length(docs_creating_doc_title)<43) then {length from 1 to 42 letters}
				begin
					docs_creating_doc_title:=docs_creating_doc_title;
				end
			else
				begin
					writeln;
					slow_text_output('ERROR! TITLE LENGTH MUST BE FROM 1 TO 42 LETTERS!'+#13#10);
					goto redo2;
				end;
		
		end;

{================================================================}
{========================================================= EDITOR}
{================================================================}
	procedure docs_editor_engine(docs_edit_mode : string);
	var docs_editor_filename, docs_editor_filetitle, docs_editor_filecontent, path_to_file:string;
		dummy:string[1];{debug}
		created_file, docs_file_to_edit: text;
		read_from_file:char;
		editor_text_lenght, strings_counter, chars_counter: integer;
		docs_editor_stringnumber, docs_editor_stringnumber_overall: integer;
		docs_editor_charnumber, z, x, prgrs1, cc, hack: integer;
		{docs_editor_text: array[1..70, 1..68] of String[1];}{array for text !moved to global vars}
		begin 
		
		if(docs_edit_mode='new') then {if 'new' string - create new file, if string contains filename - edit file}
			begin {create new file}
				docs_editor_headers; {get name and title for new file}
				docs_editor_filename:=docs_creating_file_name; {something wrong with vars}
		
			{------------ WORK WITH FILES}
			{ -- PATH TO NEW FILE -- }
			path_to_file:='DOCS/'+docs_editor_filename+'.TXT';
	
			{ -- CHECK IF FILE EXISTS ALREADY -- }
			{$I-}
			Assign(created_file, path_to_file);
			Reset(created_file);
			{$I+}				
			if IOresult<>0 then 
				begin { -- IF FILE DOESN'T EXIST -- }				
					Rewrite(created_file); {// creating an empty file}
				end
			else 
				begin { -- IF FILE EXIST -- }
					write('Error! File exist, choose another filename.');
					Close(created_file); {// close file}
					repeat {exit by enter, not allowing to input characters}
						input_key:=ReadKey;		
					until input_key=#13;
					exit;
				end;
			
			write(created_file, docs_creating_doc_title+#13#10+' '+#13#10); { writing title as a first string }
			
			{ -----------------------------HEADER OF SCREEN------------------------------------ }
			window(1,1,80,25); ClrScr; window(14,2,67,25);
			TextBackground(BLACK); 
			TextColor(terminal_color);
			desktop_header;{+PROC+}
			writeln;
		
			slow_text_output('Sten-o-pool Text Editor (ESC to save and exit)'+#13#10);

			slow_text_output('______________________________'+#13#10);
		
			window(14,8,67,25);
			
			{-----------------------CLEANING UP-------------------------}
			docs_editor_stringnumber:=1;
			docs_editor_charnumber:=1;		
			for z:=0 to 70 do
				begin 
					for x:=0 to 68 do
						begin 
								docs_editor_text[z,x]:='';
								
						end;				
				end;	
			{-----------------------------------------------------------}
			end
		else 
			begin {edit existing file}

				{docs_file_to_edit;}
				
				path_to_file:='DOCS/'+docs_edit_mode;
			
				{$I-}
				Assign(docs_file_to_edit, path_to_file);
				Reset(docs_file_to_edit);
				{$I+}	
				
				if IOresult<>0 then 
					begin { -- IF FILE DOESN'T EXIST -- }				
						write('ERROR: File not found (033)');
						repeat {exit by enter, not allowing to input characters}
							input_key:=ReadKey;		
						until input_key=#13;
						exit;
					end;
			
				{ -----------------------------HEADER OF SCREEN------------------------------------ }
				window(1,1,80,25); ClrScr; window(14,2,67,25);
				TextBackground(BLACK); 
				TextColor(terminal_color);
				desktop_header;{+PROC+}
				writeln;
		
				slow_text_output('Sten-o-pool Text Editor (ESC to save and exit)'+#13#10);

				slow_text_output('______________________________'+#13#10);
		
				window(14,8,67,25);
			
				{-----------------------CLEANING UP-------------------------}
				docs_editor_stringnumber:=1;
				docs_editor_charnumber:=1;
				strings_counter:=1;
				chars_counter:=1;
				for z:=0 to 70 do
					begin 
						for x:=0 to 68 do
							begin 
								docs_editor_text[z,x]:='';
								
							end;				
					end;	
				{-----------------------------------------------------------}	
			
				
				while not Eof(docs_file_to_edit) do
					begin		
						delay(terminal_delay);
						while not Eoln(docs_file_to_edit) do
							begin					
								read(docs_file_to_edit, read_from_file);
								docs_editor_text[strings_counter,chars_counter]:=read_from_file;	
								write(docs_editor_text[strings_counter,chars_counter]);
								chars_counter:=chars_counter+1;
							end;
						docs_editor_text[strings_counter,chars_counter+1]:=#13; 
						docs_editor_text[strings_counter,chars_counter+2]:=#10;
						readln(docs_file_to_edit, dummy);{hack to make Eof work}
						writeln;
						strings_counter:=strings_counter+1;
						chars_counter:=1;
					end; 
		

			gotoXY(1,1);
			end;
			
			{ -----------------------------EDITOR ITSELF------------------------------- }
			repeat 
			input_key:=ReadKey;
			
			{a-z&A-Z filter, yes, I really don't know how to do it easier in pascal}
			if (input_key=#97)or(input_key=#98)or(input_key=#99)or(input_key=#100)or(input_key=#101)or(input_key=#102)or
			(input_key=#103)or(input_key=#104)or(input_key=#105)or(input_key=#106)or(input_key=#107)or(input_key=#108)or
			(input_key=#109)or(input_key=#110)or(input_key=#111)or(input_key=#112)or(input_key=#113)or(input_key=#114)or
			(input_key=#115)or(input_key=#116)or(input_key=#117)or(input_key=#118)or(input_key=#119)or(input_key=#120)or
			(input_key=#121)or(input_key=#122){capitals:}or(input_key=#65)or(input_key=#66)or(input_key=#67)or(input_key=#68)or
			(input_key=#69)or(input_key=#70)or(input_key=#71)or(input_key=#72)or(input_key=#73)or(input_key=#74)or(input_key=#75)or
			(input_key=#76)or(input_key=#77)or(input_key=#78)or(input_key=#79)or(input_key=#80)or(input_key=#81)or(input_key=#82)or
			(input_key=#83)or(input_key=#84)or(input_key=#85)or(input_key=#86)or(input_key=#87)or(input_key=#88)or(input_key=#89)or
			(input_key=#90)		
			then
					begin {a-z A-Z}
						if(docs_editor_charnumber<53)then 
							begin
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]:=input_key;  {WRITING TO ARRAY}
								write(docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]); {WRITING TO SCREEN}	
								editor_text_lenght:=editor_text_lenght+1;
								docs_editor_charnumber:=docs_editor_charnumber+1;				
							end
						else if(whereY<17)then 
							begin {move to next string}					
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber+1]:=#13; {WRITING TO ARRAY}	
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber+2]:=#10; {WRITING TO ARRAY}
								
								docs_editor_charnumber:=1;
								docs_editor_stringnumber:=docs_editor_stringnumber+1;
								docs_editor_stringnumber_overall:=docs_editor_stringnumber_overall+1;
								
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]:=input_key; {WRITING TO ARRAY}
								writeln;
								write(docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]); {WRITING TO SCREEN}	
								docs_editor_charnumber:=docs_editor_charnumber+1;
								editor_text_lenght:=editor_text_lenght+1;								
							end;					
					end		
		
			else if (input_key<>#27)and(input_key<>#13)and(input_key<>#10)and(input_key<>#8)and
					(input_key<>#127)and(input_key<>#9)and(input_key<>#15)and(input_key<>#0)
			then
					begin {probably spec symbols and other... filter dangerous stuff like del or esc}
						if(docs_editor_charnumber<53)then 
							begin
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]:=input_key;  {WRITING TO ARRAY}
								write(docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]); {WRITING TO SCREEN}	
								editor_text_lenght:=editor_text_lenght+1;
								docs_editor_charnumber:=docs_editor_charnumber+1;			
							end
						else if(whereY<17)then 
							begin
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber+1]:=#13;  {WRITING TO ARRAY}	
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber+2]:=#10; {WRITING TO ARRAY}
								
								docs_editor_charnumber:=1;
								docs_editor_stringnumber:=docs_editor_stringnumber+1;
								docs_editor_stringnumber_overall:=docs_editor_stringnumber_overall+1;
								
								docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]:=input_key; {WRITING TO ARRAY}
								writeln;
								write(docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]); {WRITING TO SCREEN}	
								docs_editor_charnumber:=docs_editor_charnumber+1;
								editor_text_lenght:=editor_text_lenght+1;									
							end;
					end
			else if (input_key=#8)then {BACKSPACE}
					begin	
						if(whereX+whereY<>2) then
							begin					
								if(docs_editor_charnumber<1)then
									begin
										gotoXY(52,whereY-1);
										write(' ');
										gotoXY(whereX-1,whereY);
												
										docs_editor_charnumber:=52;
														
										docs_editor_text[docs_editor_stringnumber-1,52]:=' ';  {WRITING TO ARRAY}	
										editor_text_lenght:=editor_text_lenght-1;	
										docs_editor_stringnumber:=docs_editor_stringnumber-1;
									end
								else
									begin
										gotoXY(whereX-1,whereY);
										write(' ');
										gotoXY(whereX-1,whereY);
						
										docs_editor_charnumber:=docs_editor_charnumber-1;
						
										docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber]:=' ';  {WRITING TO ARRAY}	
										editor_text_lenght:=editor_text_lenght-1;
									end;	
							end;							
					end
			else if (input_key=#13)and(whereY<17)then {ENTER}
					begin
						writeln;		
						
						docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber+1]:=#13;  {WRITING TO ARRAY}	
						docs_editor_text[docs_editor_stringnumber,docs_editor_charnumber+2]:=#10; {WRITING TO ARRAY}
						docs_editor_stringnumber:=docs_editor_stringnumber+1;
						docs_editor_stringnumber_overall:=docs_editor_stringnumber_overall+1;
						docs_editor_charnumber:=1;
					end
			else if (input_key=#0)then {ARROWS}
					begin
						    input_key:=ReadKey;
							if (input_key=#75)then {<}
								begin
									gotoXY(whereX-1,whereY);
									docs_editor_charnumber:=docs_editor_charnumber-1;
								end
							else if  (input_key=#72)then {/\}
								begin
									gotoXY(whereX,whereY-1);
									docs_editor_stringnumber:=docs_editor_stringnumber-1;
								end
							else if  (input_key=#77)then {>}
								begin
									if(docs_editor_charnumber<51)then 
										begin
											gotoXY(whereX+1,whereY);
											docs_editor_charnumber:=docs_editor_charnumber+1;
										end;
								end
							else if  (input_key=#80)then {\/}
								begin
									if(whereY<17)then 
										begin
											gotoXY(whereX,whereY+1);
											docs_editor_stringnumber:=docs_editor_stringnumber+1;
										end;
								end;
					end;
			until input_key=#27;{ESC}
			{ -----------------------------END OF EDITOR------------------------------------ }
			
			
			{ ------------------------------SAVE FILE------------------------------------ }	
			
			ClrScr; window(33,9,54,12); ClrScr; prgrs1:=0; {window with saving indicator}
			
			if(docs_edit_mode='new') then {if 'new' string - create new file, if string contains filename - edit file}
				begin {create new file}

					for z:=1 to 18 do
						begin 
							{----------progress indicator}
							ClrScr;
							case prgrs1 of
							0 : write('   Saving \'); 
							1 : write('   Saving |'); 
							2 : write('   Saving /'); 
							3 : write('   Saving -'); 
							end;	
							prgrs1:=prgrs1+1;
							if prgrs1>3 then prgrs1:=0;
							{----------------------------}
							for x:=1 to 60 do
								begin
									delay(terminal_delay{*2}); {delay for visual things}
									write(created_file, docs_editor_text[z,x]); {WRITING FROM ARRAY TO FILE}
								end;		
						end;
					Close(created_file); {close&save file}

				end
			else
				begin {write to existing}
					Rewrite(docs_file_to_edit);
					
					for z:=1 to 18{strings_counter} do
						begin 
							{----------progress indicator}
							ClrScr;
							case prgrs1 of
							0 : write('   Saving \'); 
							1 : write('   Saving |'); 
							2 : write('   Saving /'); 
							3 : write('   Saving -'); 
							end;	
							prgrs1:=prgrs1+1;
							if prgrs1>3 then prgrs1:=0;
							{----------------------------}
							for x:=1 to 60 do
								begin
									delay(terminal_delay{*2}); {delay for visual things}
									write(docs_file_to_edit, docs_editor_text[z,x]); {WRITING FROM ARRAY TO FILE}
								end;		
						end;
					
					Close(docs_file_to_edit); {close&save file}
				end;

		end;
		
{================================================================}
{=================================== DOCUMENTS MENU LIST BUILDER }
{================================================================}
	procedure docs_reader;
	var selected, page_to_disp, items_on_page:integer;	
	label menu_cycle;
		begin	
		docs_file_parser; {read text files from DOCS folder}
		
		selected:=0;
		page_to_disp:=1;
		
		menu_cycle:
		
		window(1,1,80,25); 
		ClrScr;
		window(14,2,67,25);
		TextBackground(BLACK); 
		TextColor(terminal_color);
		desktop_header;{+PROC+}
		writeln;
		
		if(terminal_mode = 1) then {kiosk mode on} 
				begin 
					slow_text_output(kiosk_title_text+#13#10);
				end
		else if(editor_mode_edit = 1) then {select file to edit} 
				begin 
					slow_text_output('Select file you want to edit (ESC to exit)'+#13#10);
				end
		else if(editor_mode_edit = 2) then {select file to delete} 
				begin 
					slow_text_output('Select file you want to delete (ESC to exit)'+#13#10);
				end
		else {just reading} 
				begin 
					slow_text_output('Sten-o-pool Document Viewer (ESC to exit)'+#13#10);
				end;
				
		

		slow_text_output('______________________________'+#13#10);
	
		window(14,9,67,24);
		ClrScr;
		
		for i:=1 to 7 do {writing all 7 items, empty field to rewrite previous}
			begin
				writeln(docs_files_menu[page_to_disp, i],+#13#10);
				delay(terminal_delay*10);
			end;

		window(14,24,67,24); GotoXY(1, 24); write('> ');
			
		repeat			
			input_key:=ReadKey;
							
			items_on_page:=0;
						
			for i:=1 to 7 do {counting only non-empty items}
				begin 
				if(docs_files_menu[page_to_disp, i]<>'') then 
					begin 
						items_on_page:=items_on_page+1; 
					end; 
				end;
							
			if input_key=#9 then
				begin
					window(14,9,67,24);
					ClrScr;
					selected:=selected+1;
	
					if selected>items_on_page then begin selected:=1 end;
					
					if selected=1 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{ //-------------------------------- 1 }
					menu_trim_line(docs_files_menu[page_to_disp, 1]);
					writeln;
					{//--------------------------------}
					if selected=2 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{//-------------------------------- 2}
					menu_trim_line(docs_files_menu[page_to_disp, 2]);
					writeln;
					{//--------------------------------}
					if selected=3 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{//-------------------------------- 3}
					menu_trim_line(docs_files_menu[page_to_disp, 3]);
					writeln;
					{//--------------------------------}
					if selected=4 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{//-------------------------------- 4}
					menu_trim_line(docs_files_menu[page_to_disp, 4]);
					writeln;
					{//--------------------------------}
					if selected=5 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{//-------------------------------- 5}
					menu_trim_line(docs_files_menu[page_to_disp, 5]);
					writeln;
					{//--------------------------------}
					if selected=6 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{//-------------------------------- 6}
					menu_trim_line(docs_files_menu[page_to_disp, 6]);
					writeln;
					{//--------------------------------}
					if selected=7 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
					TextColor(terminal_color); end;
					{//-------------------------------- 7}
					menu_trim_line(docs_files_menu[page_to_disp, 7]);
					writeln;
					{//--------------------------------}
					TextBackground(BLACK); TextColor(terminal_color);
						
					window(14,24,67,24); GotoXY(1, 24); write('> ');
				end
			else if input_key=#13 then
				begin
					if selected>0 then 
						begin
							if docs_files_menu[page_to_disp, selected]='> Back' then 
								begin 
									page_to_disp:=1;
									selected:=0;
									goto menu_cycle;							
								end;
								
							if(selected = 1)or(selected = 2)or(selected = 3)or(selected = 4)or(selected = 5)or(selected = 6) then 
								begin 		
									{============}
									if(editor_mode_edit = 1) then {//if we use this menu in edit mode we need to edit file by enter, not just open}
										begin 
											editor_mode_edit:=0;
											docs_editor_engine(docs_file_sysname[page_to_disp, selected]);
											{docs_text_editor(docs_file_sysname[page_to_disp, selected]);}
											exit;
											{docs_file_sysname because we need a filename not a title}
										end
									else if(editor_mode_edit = 2) then {//selected delete mode}
										begin 
											editor_mode_edit:=0;
											docs_file_delete(docs_file_sysname[page_to_disp, selected]);
											exit;
											{docs_file_sysname because we need a filename not a title}
										end
									else
										begin 
											docs_file_viewer(docs_file_sysname[page_to_disp, selected]);
											{docs_file_sysname because we need a filename not a title}
										end;
									{============}
									
									goto menu_cycle;
								end								
							else if selected=7 then 
								begin
									if(page_to_disp<docs_pages_counter) then
										begin
											page_to_disp:=page_to_disp+1; 
											goto menu_cycle; 
										end
									else
										begin
											page_to_disp:=1;
										end;
								end;

							window(14,24,67,24);
							{write('> DEBUG: ',selected);}		
						end;
				end;
		until input_key=#27;	{EXIT BY ESC (causes shutdown in kiosk mode)}
		editor_mode_edit:=0;
		window(1,1,80,25);
		ClrScr;	
		end;
		
{================================================================}
{=============================================== TEXT EDITOR MAIN}
{================================================================}
	procedure docs_editor_main;
	var selected:integer;
	label redo;
		begin	
			redo:
			window(1,1,80,25); 
			ClrScr;
			window(14,2,67,25);
			TextBackground(BLACK); 
			TextColor(terminal_color);
			desktop_header;{+PROC+}
			writeln;
			
			slow_text_output('Sten-o-pool 3500 Word Processing System'+#13#10);
			slow_text_output('______________________________'+#13#10);
			
			window(14,9,67,24);
			ClrScr;

			writeln('> Create new document',+#13#10); delay(terminal_delay*10);
			writeln('> Edit document',+#13#10); delay(terminal_delay*10);
			writeln('> Delete document',+#13#10);	
			writeln('> Back',+#13#10);
		
			window(14,24,67,24); GotoXY(1, 24); write('> ');
			
			repeat			
				input_key:=ReadKey;
				
				if input_key=#9 then
					begin
						window(14,9,67,24);
						ClrScr;
						selected:=selected+1;

						if selected>4 then begin selected:=1 end;
					
						if selected=1 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{ //-------------------------------- 1 }
						menu_trim_line('> Create new document');
						writeln;
						{//--------------------------------}
						if selected=2 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 2}
						menu_trim_line('> Edit document');
						writeln;
						{//--------------------------------}
						if selected=3 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 3}
						menu_trim_line('> Delete document');
						writeln;
						{//--------------------------------}
						if selected=4 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 4}
						menu_trim_line('> Back');
						writeln;
						{//--------------------------------}
						TextBackground(BLACK); TextColor(terminal_color);
						
						window(14,24,67,24); GotoXY(1, 24); write('> ');
					end
				else if input_key=#13 then
					begin
						if selected>0 then 
							begin	
								if(selected = 1) then 
									begin 									
										docs_editor_engine('new'); {create new}
										selected:=0;
										goto redo;
									end
								else if selected=2 then 
									begin
										editor_mode_edit:= 1; {edit mode}
										docs_reader;
										selected:=0;
										goto redo;
									end
								else if selected=3 then 
									begin
										editor_mode_edit:= 2; {delete mode}
										docs_reader;
										selected:=0;
										goto redo;
									end
								else if selected=4 then 
									begin
										exit;
									end;

								window(14,24,67,24);
								{write('> DEBUG: ',selected);}							
							end;
					end;
			until input_key=#999;{it will never happen}
		end;
	
{================================================================}
{=============================================== FILE MAIN SCREEN}
{================================================================}
	procedure docs_main_menu;
	var selected:integer;
	label redo;
		begin	
			redo:
			window(1,1,80,25); 
			ClrScr;
			window(14,2,67,25);
			TextBackground(BLACK); 
			TextColor(terminal_color);
			desktop_header;{+PROC+}
			writeln;
			
			slow_text_output('Sten-o-pool 3500 Word Processing System'+#13#10);
			slow_text_output('______________________________'+#13#10);
			
			window(14,9,67,24);
			ClrScr;

			writeln('> Read documents',+#13#10); delay(terminal_delay*10);
			writeln('> Edit documents',+#13#10); delay(terminal_delay*10);
			writeln('> Exit',+#13#10);	
		
			window(14,24,67,24); GotoXY(1, 24); write('> ');
			
			repeat			
				input_key:=ReadKey;
				
				if input_key=#9 then
					begin
						window(14,9,67,24);
						ClrScr;
						selected:=selected+1;

						if selected>3 then begin selected:=1 end;
					
						if selected=1 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{ //-------------------------------- 1 }
						menu_trim_line('> Read documents');
						writeln;
						{//--------------------------------}
						if selected=2 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 2}
						menu_trim_line('> Edit documents');
						writeln;
						{//--------------------------------}
						if selected=3 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 3}
						menu_trim_line('> Exit');
						writeln;
						{//--------------------------------}
						TextBackground(BLACK); TextColor(terminal_color);
						
						window(14,24,67,24); GotoXY(1, 24); write('> ');
					end
				else if input_key=#13 then
					begin
						if selected>0 then 
							begin	
								if(selected = 1) then 
									begin 									
										docs_reader;
										selected:=0;
										goto redo;
									end
								else if selected=2 then 
									begin
										docs_editor_main;
										selected:=0;
										goto redo;
									end
								else if selected=3 then 
									begin
										exit;
									end;

								window(14,24,67,24);
								{write('> DEBUG: ',selected);}						
							end;
					end;
			until input_key=#999;{it will never happen}
		end;
		
{================================================================}{======================}{KIOSK MODE}	
{================================================================}
{===================================================== KIOSK MAIN}
{================================================================}
	procedure kiosk_main;
	begin
		docs_reader;
		terminal_shutdown;
	end;
			
{================================================================}{======================}{DESKTOP LOGIC BELOW}
{================================================================}
{================================================ CHANGE USERNAME}
{================================================================}
	procedure func_change_username;
	label redo;
		begin
			window(1,1,80,25);
			ClrScr;
			window(14,2,67,25);
			desktop_header;
			writeln;
			slow_text_output('ACCOUNT SETTINGS: CHANGE USERNAME'+#13#10);
			slow_text_output('______________________________'+#13#10+#13#10);
			window(14,8,67,20);
			redo:
			writeln;
			slow_text_output('ENTER NEW USERNAME NOW (5 TO 12 LETTERS)'+#13#10);
			writeln;
			write('> ');
		
			uppercase_input;
			writeln;
			
			if (length(capitalization_input)>4) and (length(capitalization_input)<13) then {length from 5 to 12 letters}
				begin
					new_login:=capitalization_input;
				end
			else
				begin
					writeln;
					slow_text_output('ERROR! USERNAME LENGTH MUST BE FROM 5 TO 12 LETTERS!'+#13#10);
					goto redo;
				end;
		
			Reset(file_settings);
			
			for i:=1 to 10 do
				begin
					readln(file_settings, from_file);
					settings_file_backup[i]:= from_file;			
				end;
				
			Close(file_settings);
			
			rewrite(file_settings);
			
			settings_file_backup[6]:=new_login;
			{settings_file_backup[8]:='IT WORKS!';}
			
			for i:=1 to 10 do
				begin
					write(file_settings, settings_file_backup[i],#13#10);
				end;

			Close(file_settings);
		
			writeln;
			slow_text_output('SUCCESS! NEW USERNAME IS '+new_login+#13#10);
			window(14,24,67,24);
			write('> PRESS ENTER');
			repeat {waiting for enter}
				input_key:=ReadKey;
			until input_key=#13;
			window(14,2,67,25);
		end;
		
{================================================================}
{================================================ CHANGE PASSWORD}
{================================================================}
	procedure func_change_password;
	label redo, redo2;
		begin
			window(1,1,80,25);
			ClrScr;
			window(14,2,67,25);
			desktop_header;
			writeln;
			slow_text_output('ACCOUNT SETTINGS: CHANGE PASSWORD'+#13#10);
			slow_text_output('______________________________'+#13#10+#13#10);
			window(14,8,67,20);
			redo:
			writeln;
			slow_text_output('ENTER CURRENT PASSWORD NOW'+#13#10);
			writeln;
			write('> ');
			
			uppercase_input;
			writeln;
			
			if (capitalization_input <> true_password) then
				begin
					writeln;
					slow_text_output('WRONG PASSWORD!'+#13#10);
					goto redo;
				end;
			
			redo2:
			

			writeln;
			slow_text_output('ENTER NEW PASSWORD NOW (5 TO 12 LETTERS)'+#13#10);
			writeln;
			write('> ');
		
			uppercase_input;
			writeln;
			if (length(capitalization_input)>4) and (length(capitalization_input)<13) then {length from 5 to 12 letters}
				begin
					new_password:=capitalization_input;
				end
			else
				begin
					writeln;
					slow_text_output('ERROR! PASSWORD LENGTH MUST BE FROM 5 TO 12 LETTERS!'+#13#10);
					goto redo2;
				end;
		
			Reset(file_settings);
			
			for i:=1 to 10 do
				begin
					readln(file_settings, from_file);
					settings_file_backup[i]:= from_file;			
				end;
				
			Close(file_settings);
			
			rewrite(file_settings);
			
			settings_file_backup[8]:=new_password;
			
			for i:=1 to 10 do
				begin
					write(file_settings, settings_file_backup[i],#13#10);
				end;

			Close(file_settings);
		
			writeln;
			slow_text_output('SUCCESS! PASSWORD UPDATED'+#13#10);
			window(14,24,67,24);
			write('> PRESS ENTER');
			repeat {waiting for enter}
				input_key:=ReadKey;
			until input_key=#13;
			window(14,2,67,25);
		end;

{================================================================}
{====================================================== MENU MAIN}
{================================================================}
	procedure menu_main;
	var cmd_respond_text:string[40];
		begin
			window(14,9,67,22);
				
		
		
			writeln(menu_name[menu_submenu,1]+#13#10); delay(terminal_delay*10);
 			writeln(menu_name[menu_submenu,2]+#13#10); delay(terminal_delay*10);
			writeln(menu_name[menu_submenu,3]+#13#10); delay(terminal_delay*10);
			writeln(menu_name[menu_submenu,4]+#13#10); delay(terminal_delay*10);
			writeln(menu_name[menu_submenu,5]+#13#10); delay(terminal_delay*10);
			writeln(menu_name[menu_submenu,6]+#13#10); delay(terminal_delay*10);
			writeln(menu_name[menu_submenu,7]);
			
			r:=0;
			items_count:=1;

			for i:=1 to 7 do 
				begin 
					if menu_name[menu_submenu,i]<>'' then items_count:=items_count+1;
				end;
					
			window(14,24,67,24); GotoXY(1, 24); write('> ');
		
			repeat			
				input_key:=ReadKey;
				

				if input_key=#9 then
					begin
						window(14,9,67,24);
						ClrScr;
						r:=r+1;
						
						if r>=items_count then begin r:=1 end;
					
						if r=1 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{ //-------------------------------- 1 }
						menu_trim_line(menu_name[menu_submenu,1]);
						writeln;
						{//--------------------------------}
						if r=2 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 2}
						menu_trim_line(menu_name[menu_submenu,2]);
						writeln;
						{//--------------------------------}
						if r=3 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 3}
						menu_trim_line(menu_name[menu_submenu,3]);
						writeln;
						{//--------------------------------}
						if r=4 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 4}
						menu_trim_line(menu_name[menu_submenu,4]);
						writeln;
						{//--------------------------------}
						if r=5 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 5}
						menu_trim_line(menu_name[menu_submenu,5]);
						writeln;
						{//--------------------------------}
						if r=6 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 6}
						menu_trim_line(menu_name[menu_submenu,6]);
						writeln;
						{//--------------------------------}
						if r=7 then begin TextBackground(terminal_color); TextColor(BLACK); end else begin TextBackground(BLACK); 
						TextColor(terminal_color); end;
						{//-------------------------------- 7}
						menu_trim_line(menu_name[menu_submenu,7]);
						writeln;
						{//--------------------------------}
						TextBackground(BLACK); TextColor(terminal_color);
						
						window(14,24,67,24); GotoXY(1, 24); write('> ');
					end
				else if input_key=#13 then
					begin
						if r>0 then 
							begin
								menu_func_to_parse:=menu_func[menu_submenu,r];
								if menu_func_to_parse	  ='menu_mainmenu' then begin menu_submenu:=1;  exit; end
								else if menu_func_to_parse='menu_submenu1' then begin menu_submenu:=2;  exit; end
								else if menu_func_to_parse='menu_submenu2' then begin menu_submenu:=3;  exit; end
								else if menu_func_to_parse='menu_submenu3' then begin menu_submenu:=4;  exit; end
								else if menu_func_to_parse='shutdown_function' then begin terminal_shutdown; exit; end	
								else if menu_func_to_parse='logout_function' then begin terminal_logout; log_ext:=1; exit; end						
								else if menu_func_to_parse='documents_function' then begin docs_main_menu; exit; end
								else if menu_func_to_parse='changeusername_function' then begin func_change_username; exit; end
								else if menu_func_to_parse='changepassword_function' then begin func_change_password; exit; end
								else if menu_func_to_parse='get_port_state' then begin Str(Port[$378],cmd_respond_text); end
								
								{------------------port}
							 {1}else if menu_func_to_parse='port_pin1_change_state' then begin cmd_respond_text:=('PIN SWITCHED');
							 {1}if(pin_status[1]=1) then begin port_state_change(1,0); end 
							 {1}else if(pin_status[1]=0) then begin port_state_change(1,1); end end				 
							 {2}else if menu_func_to_parse='port_pin2_change_state' then begin cmd_respond_text:=('PIN SWITCHED');
							 {2}if(pin_status[2]=1) then begin port_state_change(2,0); end 
							 {2}else if(pin_status[2]=0) then begin port_state_change(2,1); end end					 
							 {3}else if menu_func_to_parse='port_pin3_change_state' then begin cmd_respond_text:=('PIN SWITCHED');
							 {3}if(pin_status[3]=1) then begin port_state_change(3,0); end 
							 {3}else if(pin_status[3]=0) then begin port_state_change(3,1); end end				 
							 {4}else if menu_func_to_parse='port_pin4_change_state' then begin cmd_respond_text:=('PIN SWITCHED');
							 {4}if(pin_status[4]=1) then begin port_state_change(4,0); end 
							 {4}else if(pin_status[4]=0) then begin port_state_change(4,1); end end						 
							 {5}else if menu_func_to_parse='port_pin5_change_state' then begin cmd_respond_text:=('PIN SWITCHED');
							 {5}if(pin_status[5]=1) then begin port_state_change(5,0); end 
							 {5}else if(pin_status[5]=0) then begin port_state_change(5,1); end end;					
								{------------------/port}
			
								window(14,24,67,24);
								write('> ',cmd_respond_text);
								cmd_respond_text:='null';
								{write('> DEBUG: ',r);}								
							end;
					end;
			until (input_key=#999)or(log_ext=1);{it will never happen}
		end;
			
{================================================================}
{========================================= DESKTOP MAIN PROCEDURE}
{================================================================}
	procedure desktop_main;
		begin
			repeat

			window(1,1,80,25); ClrScr;
			{window(17,2,62,21); 45-mode} window(14,2,67,25); {54-mode} ClrScr; TextBackground(BLACK); TextColor(terminal_color);
			desktop_header;{+PROC+}
			writeln;
			
			
			if(menu_submenu=1) then
				begin
					if(menu_1_title='%welcome_message%') then
						begin
							desktop_welcome;{+PROC+}
						end
					else
						begin
							slow_text_output(menu_1_title+#13#10);
							slow_text_output('______________________________'+#13#10);
						end;
				end;
			if(menu_submenu=2) then
				begin
					slow_text_output(menu_2_title+#13#10);
					slow_text_output('______________________________'+#13#10);
				end;
			if(menu_submenu=3) then
				begin
					slow_text_output(menu_3_title+#13#10);
					slow_text_output('______________________________'+#13#10);
				end;
			if(menu_submenu=4) then
				begin
					slow_text_output(menu_4_title+#13#10);
					slow_text_output('______________________________'+#13#10);
				end;
			
			writeln;
			menu_main;{+PROC+}
			until (input_key=#999)or(log_ext=1);

		end;
	
{================================================================}{======================}{MINIGAME LOGIC BELOW}
{================================================================}
{================================================ MINIGAME ARRAYS}
{================================================================}	
	procedure minigame_arrays;
		begin
			pass_array_sym[1]:='!'; pass_array_sym[2]:='@'; pass_array_sym[3]:='#'; pass_array_sym[4]:='$';
			pass_array_sym[5]:='%'; pass_array_sym[6]:='^'; pass_array_sym[7]:='&'; pass_array_sym[8]:='*';
			pass_array_sym[9]:='('; pass_array_sym[10]:=')'; pass_array_sym[11]:='_'; pass_array_sym[12]:='+';
			pass_array_sym[13]:='/'; pass_array_sym[14]:='['; pass_array_sym[15]:=']'; pass_array_sym[16]:='<';
			pass_array_sym[17]:='>'; pass_array_sym[18]:='?'; pass_array_sym[19]:='~'; pass_array_sym[20]:='`';

			pass_array_5ch[1]:='HAVOC';
			pass_array_5ch[2]:='VIRAL';
			pass_array_5ch[3]:='DARED';
			pass_array_5ch[4]:='WIRES';
			pass_array_5ch[5]:='LIVES';
			pass_array_5ch[6]:='LIVES';
			pass_array_5ch[7]:='SORTS';
			pass_array_5ch[8]:='AGREE';
			pass_array_5ch[9]:='MINES';
			pass_array_5ch[10]:='LIKES';
			pass_array_5ch[11]:='NEVER';
			pass_array_5ch[12]:='PARTS';
			pass_array_5ch[13]:='HAREM';
			pass_array_5ch[14]:='WARNS';
			pass_array_5ch[15]:='THREW';
			pass_array_5ch[16]:='FARMS';
			pass_array_5ch[17]:='SIDES';
			pass_array_5ch[18]:='TIRES';
			pass_array_5ch[19]:='SWARD';
			pass_array_5ch[20]:='HARPY';
			
			pass_array_6ch[1]:='SCREEN';
			pass_array_6ch[2]:='POCKET';
			pass_array_6ch[3]:='OPTION';
			pass_array_6ch[4]:='BUFFER';
			pass_array_6ch[5]:='OUTPUT';
			pass_array_6ch[6]:='SAMPLE';
			pass_array_6ch[7]:='CANNON';
			pass_array_6ch[8]:='TRIODE';
			pass_array_6ch[9]:='TOGGLE';
			pass_array_6ch[10]:='CYCLES';
			pass_array_6ch[11]:='STRICT';
			pass_array_6ch[12]:='PINOUT';
			pass_array_6ch[13]:='BRIDGE';
			pass_array_6ch[14]:='QUICKS';
			pass_array_6ch[15]:='JINXES';
			pass_array_6ch[16]:='JABBED';
			pass_array_6ch[17]:='JUMPER';
			pass_array_6ch[18]:='ZAPPED';
			pass_array_6ch[19]:='COMMIX';
			pass_array_6ch[20]:='ZIPPED';
			
			pass_array_7ch[1]:='MEETING';
			pass_array_7ch[2]:='SENDING';
			pass_array_7ch[3]:='SETTING';
			pass_array_7ch[4]:='WARRIOR';
			pass_array_7ch[5]:='OFFLINE';
			pass_array_7ch[6]:='WRITING';
			pass_array_7ch[7]:='WARNING';
			pass_array_7ch[8]:='AFFRONT';
			pass_array_7ch[9]:='WISHING';
			pass_array_7ch[10]:='STERILE';
			pass_array_7ch[11]:='MELTING';
			pass_array_7ch[12]:='DANCING';
			pass_array_7ch[13]:='LETTING';
			pass_array_7ch[14]:='TESTING';
			pass_array_7ch[15]:='ACQUIRE';
			pass_array_7ch[16]:='HEADING';
			pass_array_7ch[17]:='CALLING';
			pass_array_7ch[18]:='SELLING';
			pass_array_7ch[19]:='WINDING';
			pass_array_7ch[20]:='WELCOME';
			
			pass_array_8ch[1]:='FRIZZLER';
			pass_array_8ch[2]:='HIGHJACK';
			pass_array_8ch[3]:='SCUZZIER';
			pass_array_8ch[4]:='FUZZIEST';
			pass_array_8ch[5]:='BEJEEZUS';
			pass_array_8ch[6]:='FRIZZLES';
			pass_array_8ch[7]:='QUADPLEX';
			pass_array_8ch[8]:='SIZZLING';
			pass_array_8ch[9]:='BEZIQUES';
			pass_array_8ch[10]:='JAPANIZE';
			pass_array_8ch[11]:='GRIZZLED';
			pass_array_8ch[12]:='POZZOLAN';
			pass_array_8ch[13]:='WHIZZERS';
			pass_array_8ch[14]:='QUINCUNX';
			pass_array_8ch[15]:='PIZZELLE';
			pass_array_8ch[16]:='BUZZARDS';
			pass_array_8ch[17]:='FUZZTONE';
			pass_array_8ch[18]:='PUZZLERS';
			pass_array_8ch[19]:='FRIZZLED';
			pass_array_8ch[20]:='BLIZZARD';
			
			pass_array_9ch[1]:='EXOENZYME';
			pass_array_9ch[2]:='JUMPINGLY';
			pass_array_9ch[3]:='JACKSCREW';
			pass_array_9ch[4]:='SKYJACKER';
			pass_array_9ch[5]:='MAXIMIZER';
			pass_array_9ch[6]:='JACQUERIE';
			pass_array_9ch[7]:='HIGHJACKS';
			pass_array_9ch[8]:='COXCOMBIC';
			pass_array_9ch[9]:='EXCHEQUER';
			pass_array_9ch[10]:='SCUZZIEST';
			pass_array_9ch[11]:='OZONIZING';
			pass_array_9ch[12]:='ZWIEBACKS';
			pass_array_9ch[13]:='QUILLBACK';
			pass_array_9ch[14]:='FRIZZLERS';
			pass_array_9ch[15]:='SQUEEZING';
			pass_array_9ch[16]:='KICKBOXED';
			pass_array_9ch[17]:='BACKCHECK';
			pass_array_9ch[18]:='BACKCHECK';
			pass_array_9ch[19]:='FRIZZLIER';
			pass_array_9ch[20]:='OXAZEPAMS';
			
			pass_array_10ch[1]:='JARGONIZED';
			pass_array_10ch[2]:='AMBERJACKS';
			pass_array_10ch[3]:='COMPLEXIFY';
			pass_array_10ch[4]:='QUILLBACKS';
			pass_array_10ch[5]:='JACQUERIES';
			pass_array_10ch[6]:='QUADPLEXES';
			pass_array_10ch[7]:='LIQUIDIZED';
			pass_array_10ch[8]:='FRIZZLIEST';
			pass_array_10ch[9]:='MAXIMIZERS';
			pass_array_10ch[10]:='FRIZZINESS';
			pass_array_10ch[11]:='OXYGENIZED';
			pass_array_10ch[12]:='QUARTZITIC';
			pass_array_10ch[13]:='JOYPOPPING';
			pass_array_10ch[14]:='MEZZANINES';
			pass_array_10ch[15]:='EQUALIZING';
			pass_array_10ch[16]:='ZYGOMORPHY';
			pass_array_10ch[17]:='QUINCUNXES';
			pass_array_10ch[18]:='SCHIZZIEST';
			pass_array_10ch[19]:='SCHIZZIEST';
			pass_array_10ch[20]:='KOLKHOZNIK';
			
			pass_array_11ch[1]:='LEXICALIZED';
			pass_array_11ch[2]:='MYTHICIZING';
			pass_array_11ch[3]:='HYPOPHARYNX';
			pass_array_11ch[4]:='JACKLIGHTED';
			pass_array_11ch[5]:='JOURNALIZED';
			pass_array_11ch[6]:='JOHNNYCAKES';
			pass_array_11ch[7]:='EXPERTIZING';
			pass_array_11ch[8]:='BAMBOOZLING';
			pass_array_11ch[9]:='CONJUNCTIVA';
			pass_array_11ch[10]:='CHIFFCHAFFS';
			pass_array_11ch[11]:='CONJUNCTIVE';
			pass_array_11ch[12]:='CYCLAZOCINE';
			pass_array_11ch[13]:='ENZYMICALLY';
			pass_array_11ch[14]:='EMBLEMIZING';
			pass_array_11ch[15]:='QUICKSILVER';
			pass_array_11ch[16]:='QUACKSALVER';
			pass_array_11ch[17]:='CARJACKINGS';
			pass_array_11ch[18]:='QUIZMASTERS';
			pass_array_11ch[19]:='SUBJUNCTIVE';
			pass_array_11ch[20]:='OBJECTIVISM';
			
			pass_array_12ch[1]:='REPRIHANDING';
			pass_array_12ch[2]:='PURIFICATION';
			pass_array_12ch[3]:='AUTHENTICITY';
			pass_array_12ch[4]:='APPRICIATING';
			pass_array_12ch[5]:='TECHNOLOGIES';
			pass_array_12ch[6]:='APPREHENSIVE';
			pass_array_12ch[7]:='ORGANIZATION';
			pass_array_12ch[8]:='ANTICIPATION';
			pass_array_12ch[9]:='TRANSCRIBING';
			pass_array_12ch[10]:='BRAINWASHING';
			pass_array_12ch[11]:='OVERWHELMING';
			pass_array_12ch[12]:='RESURRECTION';
			pass_array_12ch[13]:='CONVERSATION';
			pass_array_12ch[14]:='BLACKJACKING';
			pass_array_12ch[15]:='SUBJECTIVIZE';
			pass_array_12ch[16]:='QUINQUENNIUM';
			pass_array_12ch[17]:='PUZZLEHEADED';
			pass_array_12ch[18]:='BEDAZZLEMENT';
			pass_array_12ch[19]:='CRACKERJACKS';
			pass_array_12ch[20]:='SUBJECTIVISM';
		end;	

{================================================================}
{======================================= MINIGAME FIELD GENERATOR}
{================================================================}
	procedure minigame_generator;
	label pass_escape, re_rand, re_rand2, debug;
		begin{a}
		debug:
					

					password_displayed:=0;
			
					minigame_field_1:='';
			
					minigame_field_2:='';
					
					o:=random(100); {50/50 define where password will be shown, in left or right table}
					
					y:=random(149)+1{150 is max};
					{y:=150;}
					
					rand_max:=19;{19+1 in random}
					
					pass_lenght:=length(true_password);
					
					{writeln('y=');writeln(y);}
					
					for i:=1 to 20 do
						begin
							pass_array_used[i]:=0;
						end;
					
					t:=1;
					w:=1;
					e:=0;														
			
					while t<=204 do
						begin{whl}
							w:=w+1;
							t:=t+1;
					
							minigame_field_1:=minigame_field_1+pass_array_sym[random(20)+1];{ADD RANDOM SYMBOL TO F1}
							minigame_field_2:=minigame_field_2+pass_array_sym[random(20)+1];{ADD RANDOM SYMBOL TO F2}
								
							{random number from 15 to 20}
							re_rand:
							u:=random(rand_max)+1;
							if u<15 then goto re_rand;
							{u:=20;}
							{---------------------------}
							
							if (w>u) then
								begin{q}
									if (Length(minigame_field_1)<192) then
										begin{w}
											if (Length(minigame_field_1)>y) then
												begin{e}
													if (password_displayed=0) then
														begin{t}
															password_displayed:=1;
														
															if (pass_lenght=5) then
																begin{z}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_5ch[random(19)+1];
																			
																			t:=t+5;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_5ch[random(19)+1];
																			t:=t+5;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;
																end{z}				
															else if (pass_lenght=6) then
																begin{x}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_6ch[random(19)+1];
																			t:=t+6;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_6ch[random(19)+1];
																			t:=t+6;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;		
																end{x}
															else if (pass_lenght=7) then
																begin{c}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_7ch[random(19)+1];
																			t:=t+7;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_7ch[random(19)+1];
																			t:=t+7;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;
																end{c}
															else if (pass_lenght=8) then
																begin{v}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_8ch[random(19)+1];
																			t:=t+8;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_8ch[random(19)+1];
																			t:=t+8;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;		
																end{v}
															else if (pass_lenght=9) then
																begin{b}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_9ch[random(19)+1];
																			t:=t+9;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_9ch[random(19)+1];
																			t:=t+9;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;
																end{b}
															else if (pass_lenght=10) then
																begin{n}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_10ch[random(19)+1];
																			t:=t+10;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_10ch[random(19)+1];
																			t:=t+10;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;
																end{n}
															else if (pass_lenght=11) then
																begin{m}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_11ch[random(19)+1];
																			t:=t+11;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_11ch[random(19)+1];
																			t:=t+11;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;
																end{m}
															else if (pass_lenght=12) then
																begin{,}
																	if o>50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_12ch[random(19)+1];
																			t:=t+12;
																			w:=1;
																			minigame_field_1:=minigame_field_1+gen_password;
																			minigame_field_2:=minigame_field_2+fake_password;
																			goto pass_escape;
																		end
																	else if o<=50 then 
																		begin
																			gen_password:='PSWRD';{DEBUG}
																			gen_password:=true_password;
																			fake_password:=pass_array_12ch[random(19)+1];
																			t:=t+12;
																			w:=1;
																			minigame_field_2:=minigame_field_2+gen_password;
																			minigame_field_1:=minigame_field_1+fake_password;
																			goto pass_escape;
																		end;
																end;{,}
														end;{t}
												end;{e}
											
											
											{---unique random number----}
											re_rand2:
											q:=random(9)+1;
											for i:=1 to 10 do
												begin
													{write('*');}
													if q=pass_array_used[i] then begin goto re_rand2 end;
												end;
											{---------------------------}

											e:=e+1;
											pass_array_used[e]:=q;
								
								
											if (pass_lenght=5) then
												begin{z}
													pass_random_word_f1:=pass_array_5ch[q];
													pass_random_word_f2:=pass_array_5ch[q+10];
													w:=1;
													t:=t+5;
												end{z}				
											else if (pass_lenght=6) then
												begin{x}
													pass_random_word_f1:=pass_array_6ch[q];
													pass_random_word_f2:=pass_array_6ch[q+10];	
													w:=1;
													t:=t+6;													
												end{x}
											else if (pass_lenght=7) then
												begin{c}
													pass_random_word_f1:=pass_array_7ch[q];
													pass_random_word_f2:=pass_array_7ch[q+10];
													w:=1;
													t:=t+7;
												end{c}
											else if (pass_lenght=8) then
												begin{v}
													pass_random_word_f1:=pass_array_8ch[q];
													pass_random_word_f2:=pass_array_8ch[q+10];
													w:=1;
													t:=t+8;
												end{v}
											else if (pass_lenght=9) then
												begin{b}
													pass_random_word_f1:=pass_array_9ch[q];
													pass_random_word_f2:=pass_array_9ch[q+10];
													w:=1;
													t:=t+9;
												end{b}
											else if (pass_lenght=10) then
												begin{n}
													pass_random_word_f1:=pass_array_10ch[q];
													pass_random_word_f2:=pass_array_10ch[q+10];
													w:=1;
													t:=t+10;
												end{n}
											else if (pass_lenght=11) then
												begin{m}
													pass_random_word_f1:=pass_array_11ch[q];
													pass_random_word_f2:=pass_array_11ch[q+10];
													w:=1;
													t:=t+11;
												end{m}
											else if (pass_lenght=12) then
												begin{,}
													pass_random_word_f1:=pass_array_12ch[q];
													pass_random_word_f2:=pass_array_12ch[q+10];
													w:=1;
													t:=t+12;
												end;{,}
								
											minigame_field_1:=minigame_field_1+pass_random_word_f1;{ADD RANDOM WORD}
											minigame_field_2:=minigame_field_2+pass_random_word_f2;{ADD RANDOM WORD}
		
											pass_escape:

										end;{w}
								end;{q}

						end;{whl}

	end;{a}
	
{================================================================}								
{=================================================== MINIGAME BAN}
{================================================================}
	procedure minigame_ban;
		begin
			window(1,1,80,25);
			for i:=1 to 60 do
				begin
					writeln;
					delay(terminal_delay*5);
				end;
			ClrScr;
			TextBackground(BLACK); TextColor(terminal_color);
			window(14,13,67,25);
			writeln('                  TERMINAL BLOCKED');
			writeln('          Contact your system administrator');
			window(1,1,80,25);
			GotoXY(80, 25);
			Rewrite(file_block);
			write(file_block,'DELETE THIS FILE TO UNBLOCK TERMINAL');
			Close(file_block);
			repeat {exit by ESC, not allowing to input characters}
				input_key:=ReadKey;		
			until input_key=#27;
			halt;
		end;	
		
{================================================================}								
{================================================= MINIGAME LOGIN}
{================================================================}
	procedure minigame_login;
	label relogin;
		begin
			relogin:
			
			window(1,1,80,25);
			ClrScr;
			window(14,2,67,25);
			header_termlink;
			
			login:='';
			for i:=1 to 255 do
				begin
					login[i]:=' ';
				end;
			
			write('> LOGON ');
			
			uppercase_input;
			
			login:=capitalization_input;
			
							if (login=true_login)or(login='ADMIN') then
								begin
									password_check;{+PROC+}
									if password=true_password then
										begin
											if(terminal_mode = 1) then {kiosk mode on} 
												begin 
													kiosk_main;
												end
											else
												begin
													desktop_main; {goto DESKTOP;}{ТОЧКА ВЫХОДА}
												end;
										end
									else
										begin
											writeln;
											writeln; writeln('ERROR: WRONG PASSWORD! PRESS ENTER TO TRY AGAIN'); 
											repeat {waiting for enter}
												input_key:=ReadKey;
											until input_key=#13;
											goto relogin;
										end;
								end
							else
								begin
									writeln;
									writeln('ERROR: WRONG USERNAME! PRESS ENTER TO TRY AGAIN'); 
									repeat {waiting for enter}
										input_key:=ReadKey;
									until input_key=#13;
									goto relogin;
								end;
						
		end;	

{================================================================}								
{====================================== MINIGAME ATTEMPTS COUNTER}
{================================================================}
	procedure minigame_attempts;
		begin
			window(14,5,50,6);
			ClrScr;
			if(hack_attempt=1) then
				begin
					d:=5-hack_attempt;
					writeln(d,' ATTEMPT(S) LEFT: '+#254+' '+#254+' '+#254+' '+#254);
				end
			else if(hack_attempt=2) then
				begin
					d:=5-hack_attempt;
					writeln(d,' ATTEMPT(S) LEFT: '+#254+' '+#254+' '+#254);
				end
			else if(hack_attempt=3) then
				begin
					d:=5-hack_attempt;
					writeln(d,' ATTEMPT(S) LEFT: '+#254+' '+#254);
				end
			else if(hack_attempt=4) then
				begin
					TextColor(terminal_color + Blink);
					write('!!! WARNING: LOCKOUT IMMINENT !!!');
					TextColor(terminal_color);
				end
			else if(hack_attempt=5) then
				begin
					minigame_ban;{BAN}
				end;
			window(54,7,67,23);
			gotoXY(1, 17);
		end;

{================================================================}								
{======================================== MINIGAME HACK PROCEDURE}
{================================================================}
	procedure minigame_hack;
	label rehack;
		begin
			rehack:
			
			hack_attempt:=hack_attempt+1;
			
			minigame_attempts;{+PROC+}
			
			write('>');
			uppercase_input;
			password:=capitalization_input;
			
			gotoXY(1,WhereY{-1});
			DelLine;
			
			if(password=true_password) then 
				begin 
					{writeln;}
					write('>Exact match!'+#13#10+'>Please wait'+#13#10+'>while system'+#13#10+'>is accessed.');
					{GO TO DESKTOP}{EXIT POINT}
					delay(terminal_delay*400);
					minigame_login;
				end
			else
				begin	
					writeln('>',password);
					writeln('>Entry denied');
					true_pass_lenght:=Length(true_password);
	
	
					for i:=1 to true_pass_lenght do
						begin
							if(password[i]=true_password[i]) then begin a:=a+1; end;
						end;
						
					writeln('>',a,'/',true_pass_lenght,' correct.'{+#13#10});
					a:=0;
					
					password:='';
					for i:=1 to 12 do
						begin
							password[i]:=' ';
						end;
				
					goto rehack;
				end;
		end;

{================================================================}								
{=========================================== MINIGAME FIELD BUILD}
{================================================================}
	procedure minigame_field_build;
		begin
			window(14,2,67,25);
			minigame_header;
			writeln;
			writeln;
			writeln;
			
			table_numbers_f1:='0xF8TG0xF8480xFA500xFAGF0xFA9G0xFA050xFAE40xFAG40xFAT40xFAYG0xFARH0xFARK0xFAAC0xFAA40xFA470xFA190xFA2F';
			table_numbers_f2:='0xFA880xFABB0xFAR50xFAF70xFA8F0xFAYD0xFA6T0xFA8D0xFB0F0xFB6J0xFB3K0xFB5G0xFBG70xFB630xFBRD0xFB540xFB78';
			
			
			window(14,7,19,25);
			for i:=1 to 103 do begin write(table_numbers_f1[i]); delay(terminal_delay div 4); end;

			window(21,7,32,25);
			for i:=1 to 205 do begin write(minigame_field_1[i]); delay(terminal_delay div 4); end;

			window(34,7,39,25);
			for i:=1 to 103 do begin write(table_numbers_f2[i]); delay(terminal_delay div 4); end;

			window(41,7,52,25);
			for i:=1 to 205 do begin write(minigame_field_2[i]); delay(terminal_delay div 4); end;

			
			window(54,7,67,23);
			gotoXY(1, 17);
			minigame_hack;
		end;

{================================================================}								
{======================================== MINIGAME MAIN PROCEDURE}
{================================================================}
	procedure minigame_main;
		begin
			minigame_arrays;
			minigame_generator;
			minigame_field_build;
			
		end;

{================================================================}{======================}{WORK WITH FILES}
{================================================================}								
{=============================================== MENU FILE PARSER}
{================================================================}
	procedure menu_parser;
	var menu_caret_pos, menu_caret_leght: integer;
	menu_file_raw: array [1..40] of String;
	
		begin
				
			for i:=1 to 40 do
				begin
					readln(file_menu, from_file);
					menu_file_raw[i]:=from_file;
				end;
		
			menu_1_title:= menu_file_raw[2];
			menu_2_title:= menu_file_raw[12];
			menu_3_title:= menu_file_raw[22];
			menu_4_title:= menu_file_raw[32];
					
			{================================== MENU_1 }
			menu_caret_pos:=Pos('^',menu_file_raw[3]);
			menu_caret_leght:=Length(menu_file_raw[3]);
			menu_name[1,1]:=Copy(menu_file_raw[3], 1, menu_caret_pos-1);
			menu_func[1,1]:=Copy(menu_file_raw[3], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[4]);
			menu_caret_leght:=Length(menu_file_raw[4]);
			menu_name[1,2]:=Copy(menu_file_raw[4], 1, menu_caret_pos-1);
			menu_func[1,2]:=Copy(menu_file_raw[4], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[5]);
			menu_caret_leght:=Length(menu_file_raw[5]);
			menu_name[1,3]:=Copy(menu_file_raw[5], 1, menu_caret_pos-1);
			menu_func[1,3]:=Copy(menu_file_raw[5], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[6]);
			menu_caret_leght:=Length(menu_file_raw[6]);
			menu_name[1,4]:=Copy(menu_file_raw[6], 1, menu_caret_pos-1);
			menu_func[1,4]:=Copy(menu_file_raw[6], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[7]);
			menu_caret_leght:=Length(menu_file_raw[7]);
			menu_name[1,5]:=Copy(menu_file_raw[7], 1, menu_caret_pos-1);
			menu_func[1,5]:=Copy(menu_file_raw[7], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[8]);
			menu_caret_leght:=Length(menu_file_raw[8]);
			menu_name[1,6]:=Copy(menu_file_raw[8], 1, menu_caret_pos-1);
			menu_func[1,6]:=Copy(menu_file_raw[8], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[9]);
			menu_caret_leght:=Length(menu_file_raw[9]);
			menu_name[1,7]:=Copy(menu_file_raw[9], 1, menu_caret_pos-1);
			menu_func[1,7]:=Copy(menu_file_raw[9], menu_caret_pos+1, menu_caret_leght);
			{==================================}
			
			{================================== MENU_2 }
			menu_caret_pos:=Pos('^',menu_file_raw[3+10]);
			menu_caret_leght:=Length(menu_file_raw[3+10]);
			menu_name[2,1]:=Copy(menu_file_raw[3+10], 1, menu_caret_pos-1);
			menu_func[2,1]:=Copy(menu_file_raw[3+10], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[4+10]);
			menu_caret_leght:=Length(menu_file_raw[4+10]);
			menu_name[2,2]:=Copy(menu_file_raw[4+10], 1, menu_caret_pos-1);
			menu_func[2,2]:=Copy(menu_file_raw[4+10], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[5+10]);
			menu_caret_leght:=Length(menu_file_raw[5+10]);
			menu_name[2,3]:=Copy(menu_file_raw[5+10], 1, menu_caret_pos-1);
			menu_func[2,3]:=Copy(menu_file_raw[5+10], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[6+10]);
			menu_caret_leght:=Length(menu_file_raw[6+10]);
			menu_name[2,4]:=Copy(menu_file_raw[6+10], 1, menu_caret_pos-1);
			menu_func[2,4]:=Copy(menu_file_raw[6+10], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[7+10]);
			menu_caret_leght:=Length(menu_file_raw[7+10]);
			menu_name[2,5]:=Copy(menu_file_raw[7+10], 1, menu_caret_pos-1);
			menu_func[2,5]:=Copy(menu_file_raw[7+10], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[8+10]);
			menu_caret_leght:=Length(menu_file_raw[8+10]);
			menu_name[2,6]:=Copy(menu_file_raw[8+10], 1, menu_caret_pos-1);
			menu_func[2,6]:=Copy(menu_file_raw[8+10], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[9+10]);
			menu_caret_leght:=Length(menu_file_raw[9+10]);
			menu_name[2,7]:=Copy(menu_file_raw[9+10], 1, menu_caret_pos-1);
			menu_func[2,7]:=Copy(menu_file_raw[9+10], menu_caret_pos+1, menu_caret_leght);
			{==================================}
			
			
			{================================== MENU_3 }
			menu_caret_pos:=Pos('^',menu_file_raw[3+20]);
			menu_caret_leght:=Length(menu_file_raw[3+20]);
			menu_name[3,1]:=Copy(menu_file_raw[3+20], 1, menu_caret_pos-1);
			menu_func[3,1]:=Copy(menu_file_raw[3+20], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[4+20]);
			menu_caret_leght:=Length(menu_file_raw[4+20]);
			menu_name[3,2]:=Copy(menu_file_raw[4+20], 1, menu_caret_pos-1);
			menu_func[3,2]:=Copy(menu_file_raw[4+20], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[5+20]);
			menu_caret_leght:=Length(menu_file_raw[5+20]);
			menu_name[3,3]:=Copy(menu_file_raw[5+20], 1, menu_caret_pos-1);
			menu_func[3,3]:=Copy(menu_file_raw[5+20], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[6+20]);
			menu_caret_leght:=Length(menu_file_raw[6+20]);
			menu_name[3,4]:=Copy(menu_file_raw[6+20], 1, menu_caret_pos-1);
			menu_func[3,4]:=Copy(menu_file_raw[6+20], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[7+20]);
			menu_caret_leght:=Length(menu_file_raw[7+20]);
			menu_name[3,5]:=Copy(menu_file_raw[7+20], 1, menu_caret_pos-1);
			menu_func[3,5]:=Copy(menu_file_raw[7+20], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[8+20]);
			menu_caret_leght:=Length(menu_file_raw[8+20]);
			menu_name[3,6]:=Copy(menu_file_raw[8+20], 1, menu_caret_pos-1);
			menu_func[3,6]:=Copy(menu_file_raw[8+20], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[9+20]);
			menu_caret_leght:=Length(menu_file_raw[9+20]);
			menu_name[3,7]:=Copy(menu_file_raw[9+20], 1, menu_caret_pos-1);
			menu_func[3,7]:=Copy(menu_file_raw[9+20], menu_caret_pos+1, menu_caret_leght);
			{==================================}
			
			
			{================================== MENU_4 }
			menu_caret_pos:=Pos('^',menu_file_raw[3+30]);
			menu_caret_leght:=Length(menu_file_raw[3+30]);
			menu_name[4,1]:=Copy(menu_file_raw[3+30], 1, menu_caret_pos-1);
			menu_func[4,1]:=Copy(menu_file_raw[3+30], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[4+30]);
			menu_caret_leght:=Length(menu_file_raw[4+30]);
			menu_name[4,2]:=Copy(menu_file_raw[4+30], 1, menu_caret_pos-1);
			menu_func[4,2]:=Copy(menu_file_raw[4+30], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[5+30]);
			menu_caret_leght:=Length(menu_file_raw[5+30]);
			menu_name[4,3]:=Copy(menu_file_raw[5+30], 1, menu_caret_pos-1);
			menu_func[4,3]:=Copy(menu_file_raw[5+30], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[6+30]);
			menu_caret_leght:=Length(menu_file_raw[6+30]);
			menu_name[4,4]:=Copy(menu_file_raw[6+30], 1, menu_caret_pos-1);
			menu_func[4,4]:=Copy(menu_file_raw[6+30], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[7+30]);
			menu_caret_leght:=Length(menu_file_raw[7+30]);
			menu_name[4,5]:=Copy(menu_file_raw[7+30], 1, menu_caret_pos-1);
			menu_func[4,5]:=Copy(menu_file_raw[7+30], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[8+30]);
			menu_caret_leght:=Length(menu_file_raw[8+30]);
			menu_name[4,6]:=Copy(menu_file_raw[8+30], 1, menu_caret_pos-1);
			menu_func[4,6]:=Copy(menu_file_raw[8+30], menu_caret_pos+1, menu_caret_leght);

			menu_caret_pos:=Pos('^',menu_file_raw[9+30]);
			menu_caret_leght:=Length(menu_file_raw[9+30]);
			menu_name[4,7]:=Copy(menu_file_raw[9+30], 1, menu_caret_pos-1);
			menu_func[4,7]:=Copy(menu_file_raw[9+30], menu_caret_pos+1, menu_caret_leght);
			{==================================}
		end;
		
{================================================================}
{====================================================== FILES I/O}
{================================================================}
	procedure files_init;		
		begin
			file_settings_name:='SETTINGS.UOS';{when build remove src/}
			file_menu_name:='MENU.UOS';
			file_block_name:='BLOCKED.UOS';
			file_kiosk_title_name:='KIOSK\TITLE.TXT';

			
			Assign(file_kiosk_title, file_kiosk_title_name);
			Reset(file_kiosk_title);	 
			
		
			{==kiosk settings loading==}
		 	readln(file_kiosk_title, kiosk_title_text); 
		
			
			Assign(file_settings, file_settings_name);
			Reset(file_settings);
			
			
			{$i-}
		    Assign(file_menu, file_menu_name);
			Reset(file_menu);
			{$i+}
			if IOResult <> 0 then 
				begin
					writeln('ERROR: SYSTEM FILES NOT FOUND');
				end;

			for i:=1 to 10 do
				begin
						readln(file_settings, from_file);
						
						if(i=2) then
							begin
								Val(from_file, terminal_delay,valcode);
								{writeln('x=',terminal_delay);}
							end;
						if(i=4) then
							begin
								Val(from_file, terminal_color,valcode);
								{writeln('x=',terminal_color);}
							end;
						if(i=6) then
							begin
								true_login:=from_file;
								{writeln('x=',true_login);}
							end;
						if(i=8) then
							begin
								true_password:=from_file;
								{writeln('x=',true_password);}
							end;	
						if(i=10) then
							begin
								Val(from_file, terminal_mode,valcode);
							end;							
				end;
				
			{===========BLOCK CHECK=============}
			{if file block.ous exists goes to ban screen}
			{$i-}
			Assign(file_block, file_block_name);
			Reset(file_block);
			{$i+}
			if IOResult = 0 then 
				begin
					minigame_ban;
				end;
			{===================================}			

			Close(file_settings);
			
			menu_parser;
			
		end;

{================================================================}{======================}{MAIN CODE BELOW}
{================================================================================================}
{====================================================================================== MAIN CODE}
{================================================================================================}
begin
	Randomize;

	menu_submenu:=1;
	items_count:=1;

	window(1,1,80,25);
	ClrScr;
	TextBackground(BLACK); TextColor(terminal_color);
	window(14,2,67,25);
	ClrScr;

	Sound(1000);
	port_state_change(1,1);{turning pin1 on, it means that terminal is working}
	delay(1000);
	NoSound;

	logout:

	files_init;
	
	{desktop_main;}{DEBUG}
	{minigame_main;}{DEBUG}
	{termlink_result:=1;} {SKIP LOGIN - for normal mode comment this line}
	
	termlink_main; {SKIP LOGIN - for normal mode uncomment this line}

	window(1,1,80,25); ClrScr;

	if(termlink_result=1)then 
		begin 	
			window(1,1,80,25); 
			if(terminal_mode = 1) then {kiosk mode on} 
				begin 
					kiosk_main;
					exit;
				end; 
			ClrScr; 
			desktop_main; 
		end
	else if(termlink_result=2) then 
		begin
				window(1,1,80,25); 
				ClrScr; 
				minigame_main; 
		end;
	
	if(log_ext=1) then 
		begin 
			log_ext:=0; {hack to make logout function work, it exits from all menu procedures if '1'}
			goto logout;
		end;

	end.