if ( !fileio ) then	require("fileio")		if ( fileio ) then		LShop.core.Message( Color( 0, 255, 0 ), "FileIO Module load. - Module by 'Alex Grist'" )	else		LShop.core.Message( Color( 255, 0, 0 ), "FileIO Module load failed. - Please reinstall FileIO Module ;o" )	endendLShop.SU = LShop.SU or {}LShop.SU.PercentGage = LShop.SU.PercentGage or 0util.AddNetworkString( "LShop_SU_CheckNewUpdate" )util.AddNetworkString( "LShop_SU_CheckNewUpdate_SendCL" )util.AddNetworkString( "LShop_SU_SoftwareUpdate" )util.AddNetworkString( "LShop_SU_SoftwareUpdate_ProgressMessage" )util.AddNetworkString( "LShop_SU_SoftwareUpdate_STOP" )util.AddNetworkString( "LShop_SU_SoftwareUpdate_Ready" )util.AddNetworkString( "LShop_SU_SoftwareUpdate_PercentCL" )net.Receive( "LShop_SU_CheckNewUpdate", function( len, cl )	LShop.SU.CheckNewUpdate( cl )end)net.Receive( "LShop_SU_SoftwareUpdate", function( len, cl )	LShop.SU.ProgressMessage( cl, "Initializing ..." )	timer.Simple( 1, function()		LShop.SU.SoftwareUpdate_1( cl )	end)end)function LShop.system.FileWrite( path, data )	return fileio.Write( path, data )endfunction LShop.system.FileDelete( path )	return fileio.Delete( path )endfunction LShop.system.DirCreate( path )	return fileio.MakeDirectory( path )endfunction LShop.SU.ProgressMessage( caller, msg )	net.Start("LShop_SU_SoftwareUpdate_ProgressMessage")	net.WriteString( msg )	net.Send( caller )endfunction LShop.SU.Ready( caller )	net.Start("LShop_SU_SoftwareUpdate_Ready")	net.Send( caller )endfunction LShop.SU.Percent( caller, percent )	LShop.SU.PercentGage = percent	net.Start("LShop_SU_SoftwareUpdate_PercentCL")	net.WriteString( LShop.SU.PercentGage )	net.Send( caller )endfunction LShop.SU.Stop( caller )	net.Start("LShop_SU_SoftwareUpdate_STOP")	net.Send( caller )	LShop.SU.ProgressMessage( caller, "* SU ERROR : Forced stop ..." )	timer.Simple( 5, function()		RunConsoleCommand( "changelevel", game.GetMap() )	end)	local cachefileFind = file.Find( "LShop/cache/*", "DATA" )	for kg, vg in pairs( cachefileFind ) do		if ( string.match( vg, ".cache" ) ) then			table.remove( cachefileFind, kg )		end	end	for k, v in pairs( cachefileFind ) do		timer.Destroy( "LShop_su_func4_1_" .. k )	end	timer.Destroy("LShop_su_func4_compcheck")endfunction LShop.SU.SoftwareUpdate_1( caller )	LShop.core.Message( Color( 0, 255, 255 ), "[Progress] Software version check ..." )	LShop.SU.ProgressMessage( caller, "[Progress] Software update check ..." )		http.Fetch( "http://textuploader.com/tdny/raw",		function( body, len, headers, code )			if ( LShop.Config.Version == body ) then				LShop.core.Message( Color( 0, 255, 0 ), "[Progress] Version is latest !" )				LShop.SU.ProgressMessage( caller, "[Progress] ERROR : Version is latest !" )			else				LShop.SU.ProgressMessage( caller, "[Progress] You need software update !" )				LShop.SU.SoftwareUpdate_2( caller )			end		end,		function( err )			LShop.core.Message( Color( 255, 0, 0 ), "[SU]" .. err )			LShop.SU.ProgressMessage( caller, "* SU ERROR : " .. err )			LShop.SU.Stop( caller )		end	)endfunction LShop.SU.SoftwareUpdate_2( caller )	for _, pl in pairs( player.GetAll() ) do		if ( pl != caller ) then			pl:Kick( "[SU]Software update." )		end	end		RunConsoleCommand( "sv_password", math.random( 1, 99999999 ) .. "_" .. math.random( 1, 100000 ) )		LShop.SU.Percent( caller, 1 )		LShop.SU.Ready( caller )	LShop.SU.ProgressMessage( caller, "Downloading, file list ..." )		LShop.SU.Percent( caller, 2 )		local updatedfileList = {}		http.Fetch( "http://textuploader.com/tdni/raw",		function( body, len, headers, code )			updatedfileList = string.Explode( "\n", body )			for k, v in pairs( updatedfileList ) do				if ( k != #updatedfileList ) then					updatedfileList[k] = string.sub( v, 0, string.len( v ) - 1 )				else					LShop.SU.ProgressMessage( caller, "File list download finished !" )					LShop.system.SoftwareUpdate_3( caller, updatedfileList )					LShop.SU.Percent( caller, 5 )				end			end		end,		function( err )			LShop.core.Message( Color( 255, 0, 0 ), "[SU]" .. err )			LShop.SU.ProgressMessage( caller, "* SU ERROR : " .. err )		end	)endfunction LShop.system.SoftwareUpdate_3( caller, lists )	LShop.SU.ProgressMessage( caller, "Cache download initializing ..." )			LShop.SU.Percent( caller, 7 )		local Finished = {}		for k, v in pairs( lists ) do		Finished[ k ] = false	end	LShop.system.DirCreate( "data/LShop" )	LShop.system.DirCreate( "data/LShop/cache/" )		local deletepreCache = file.Find( "LShop/cache/*", "DATA" ) or nil	if ( #deletepreCache != 0 ) then		LShop.SU.ProgressMessage( caller, "Pre cache file found, : " .. #deletepreCache )			for k1, v1 in pairs( deletepreCache ) do			LShop.system.FileDelete( "data/LShop/cache/" .. v1 )			LShop.SU.ProgressMessage( caller, "Pre cache file delete, : " .. v1 )		end	end		for k2, v2 in pairs( lists ) do		timer.Create( "LShop_su_func3_1_" .. k2, 3 + k2, 1, function()			if ( string.match( v2, ";" ) ) then				v2 = string.gsub( v2, ";", "" )				LShop.system.FileWrite( "data/LShop/cache/" .. k2 .. ".data", "D;" )				LShop.system.FileWrite( "data/LShop/cache/" .. k2 .. ".cache", tostring( v2 ) )					LShop.SU.ProgressMessage( caller, "Cache file create ... : " .. k2 .. ".data" )				Finished[ k2 ] = true				timer.Destroy( "LShop_su_func3_1_" .. k2 )				if ( LShop.SU.PercentGage <= 50 ) then					LShop.SU.Percent( caller, LShop.SU.PercentGage + math.random( 1, 3 ) )				end				return			end			http.Fetch( "https://raw.githubusercontent.com/SolarTeam/LShop/master/" .. v2,				function( body, len, headers, code )					if ( string.match( body, "Not Found" ) && len == 9 ) then						Finished[ k2 ] = nil						LShop.SU.ProgressMessage( caller, "* SU ERROR : Cache file create failed! : " .. v2 )						Finished[ k2 ] = 0						table.remove( lists, k2 )						for m, _ in pairs( lists )do							timer.Destroy( "LShop_su_func3_1_" .. m )								end						return					end					LShop.system.FileWrite( "data/LShop/cache/" .. k2 .. ".data", tostring( body ) )					LShop.system.FileWrite( "data/LShop/cache/" .. k2 .. ".cache", tostring( v2 ) )					LShop.SU.ProgressMessage( caller, "Cache file create ... : " .. k2 .. ".data" )					timer.Destroy( "LShop_su_func3_1_" .. k2 )					Finished[ k2 ] = true					if ( LShop.SU.PercentGage <= 50 ) then						LShop.SU.Percent( caller, LShop.SU.PercentGage + math.random( 1, 3 ) )					end				end,				function( err )					LShop.core.Message( Color( 255, 0, 0 ), "[SU]" .. err )					LShop.SU.ProgressMessage( caller, "* SU ERROR : Cache file create error, : " .. err )					Finished[ k2 ] = 0				end			)						end)	end	-- LShop.SU.Stop( caller )	timer.Create( "LShop_su_func3_compcheck", 3, 0, function()		for k3, v3 in pairs( Finished ) do			if ( v3 != 0 ) then				if ( v3 ) then					if ( k3 == #Finished ) then						LShop.SU.ProgressMessage( caller, "Cache file create finished !" )						LShop.SU.Percent( caller, 52 )						timer.Destroy("LShop_su_func3_compcheck")						LShop.system.SoftwareUpdate_4( caller, lists )					end							end			else				LShop.SU.Stop( caller )			end		end	end)endfunction LShop.system.SoftwareUpdate_4( caller, lists )	LShop.SU.ProgressMessage( caller, "Software update initializing ..." )	timer.Simple( 5, function()		local Finished = {}		for i = 1, #lists do			Finished[ i ] = false		end		LShop.SU.Percent( caller, 55 )				local files, dirs = file.Find( "addons/*", "GAME" )		if ( dirs ) then			for k, v in pairs( dirs ) do				local findText = string.lower( v )				local addonDIR = ""				if ( string.match( findText, "lshop" ) ) then					addonDIR = v					local cachefileFind = file.Find( "LShop/cache/*", "DATA" )					for kg, vg in pairs( cachefileFind ) do						if ( string.match( vg, ".cache" ) ) then							table.remove( cachefileFind, kg )						end					end					for k2, v2 in pairs( cachefileFind ) do						timer.Create( "LShop_su_func4_1_" .. k2, 2 + k2, 0, function()							local exs = string.GetExtensionFromFilename( v2 )							local dirRep = string.gsub( v2, exs, "cache" )							local fileDirread = file.Read( "LShop/cache/" .. dirRep, "DATA" ) or nil							local fileDataread = file.Read( "LShop/cache/" .. v2, "DATA" ) or nil														if ( fileDirread && fileDataread ) then								if ( fileDataread != "D;" ) then									local dir = ""									local exd = string.Explode( "/", fileDirread )									for k3, v3 in pairs( exd ) do										if ( k3 != #exd ) then											dir = dir .. "/" ..  v3											LShop.system.DirCreate( dir )										else											LShop.system.FileWrite( fileDirread, fileDataread )											LShop.SU.ProgressMessage( caller, "[WRITE] Update software ... : " .. v3 .. " +" )											LShop.core.Message( Color( 0, 255, 0 ), "[SU]Update software ... : " .. v3 )											if ( LShop.SU.PercentGage <= 90 ) then												LShop.SU.Percent( caller, LShop.SU.PercentGage + math.random( 1, 5 ) )											end										end									end									timer.Destroy( "LShop_su_func4_1_" .. k2 )									Finished[ k2 ] = true								else									LShop.system.FileDelete( fileDirread )									LShop.SU.ProgressMessage( caller, "[DELETE] Update software ... : " .. fileDirread .. " +" )									if ( LShop.SU.PercentGage <= 90 ) then										LShop.SU.Percent( caller, LShop.SU.PercentGage + math.random( 1, 5 ) )									end									timer.Destroy( "LShop_su_func4_1_" .. k2 )									Finished[ k2 ] = true								end							else								LShop.core.Message( Color( 255, 0, 0 ), "[SU]Cache file read failed! : " .. v2 )								LShop.SU.ProgressMessage( caller, "* SU ERROR : Cache file read error, : " .. v2 )								LShop.SU.Stop( caller )							end						end)					end				end			end		end				timer.Create( "LShop_su_func4_compcheck", 3, 0, function()			for k3, v3 in pairs( Finished ) do				if ( v3 ) then					if ( k3 == #Finished ) then						local deletepreCache = file.Find( "LShop/cache/*", "DATA" ) or nil						if ( #deletepreCache != 0 ) then							for k1, v1 in pairs( deletepreCache ) do								LShop.system.FileDelete( "data/LShop/cache/" .. v1 )								LShop.SU.ProgressMessage( caller, "Cache file delete, : " .. v1 )								if ( LShop.SU.PercentGage <= 99 ) then									LShop.SU.Percent( caller, LShop.SU.PercentGage + math.random( 1, 8 ) )								end							end						end												timer.Simple( 3, function()							LShop.SU.ProgressMessage( caller, "Software update success ! :) +" )							LShop.SU.Percent( caller, 100 )							timer.Simple( 4, function()								LShop.SU.ProgressMessage( caller, "Reboot server ..." )								timer.Simple( 7, function()									RunConsoleCommand("changelevel", game.GetMap())								end)							end)													end)						timer.Destroy("LShop_su_func4_compcheck")					end							end			end				end)	end)endfunction LShop.SU.CheckNewUpdate( caller )	local curret_version = LShop.Config.Version or "0.1"	LShop.core.Message( Color( 0, 255, 0 ), "Check Version update ..." )	http.Fetch( "http://textuploader.com/tdny/raw",		function( body, len, headers, code )			if ( curret_version == body ) then				LShop.core.Message( Color( 0, 255, 0 ), "Version is latest!" )				net.Start("LShop_SU_CheckNewUpdate_SendCL")				net.WriteString( "0" )				net.WriteString( body )				net.WriteTable( { } )				net.Send( caller )			else				LShop.core.Message( Color( 0, 255, 255 ), "You need software update." )				http.Fetch( "http://textuploader.com/t1kj/raw",					function( body2, len, headers, code )						local changelog = string.Explode( "\n", body2 )						net.Start("LShop_SU_CheckNewUpdate_SendCL")						net.WriteString( "1" )						net.WriteString( body )						net.WriteTable( changelog )						net.Send( caller )					end,					function( err )										end				)			end		end,		function( err )			LShop.core.Message( Color( 255, 255, 0 ), "Error : " .. err )		end	)end