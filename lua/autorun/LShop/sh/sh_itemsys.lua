--[[

--]]
LShop = LShop or {}
LShop.system = LShop.system or {}
LShop.ITEMs = {}

function LShop.system.ItemRegister( tab )
	if ( !LShop.ITEMs[ tab.Category ] ) then
		LShop.ITEMs[ tab.Category ] = {}
		LShop.ITEMs[ tab.Category ][ #LShop.ITEMs[ tab.Category ] + 1 ] = tab
	else
		LShop.ITEMs[ tab.Category ][ #LShop.ITEMs[ tab.Category ] + 1 ] = tab
	end
end

function LShop.system.GetItems( )
	return LShop.ITEMs
end

function LShop.system.GetItemsByCategory( category )
	for k, v in pairs( LShop.system.GetItems( ) ) do
		if ( k == category ) then
			return v
		else
			if ( k == #LShop.system.GetItems( ) ) then
				MsgC( Color( 255, 0, 0 ), "[LShop] Item find failed.\n" )
				return nil
			end
		end
	end
end


function LShop.system.ItemFindByID( id, category )
	for k, v in pairs( LShop.system.GetItems( ) ) do
		if ( k == category ) then
			for i, a in pairs( v ) do
				if ( a.ID == id ) then
					return a
				else
					if ( i == #v ) then
						MsgC( Color( 255, 0, 0 ), "[LShop] Item find failed.\n" )
						return nil
					end
				end
			end
		end
	end
end


function LShop.system.ItemFindByModel( model, category )
	for k, v in pairs( LShop.system.GetItems( ) ) do
		if ( k == category ) then
			for i, a in pairs( v ) do
				if ( a.Model ) then
					if ( a.Model == model ) then
						return a
					else
						if ( i == #v ) then
							MsgC( Color( 255, 0, 0 ), "[LShop] Item find failed.\n" )
							return nil
						end
					end
				else
					if ( i == #v ) then
						MsgC( Color( 255, 0, 0 ), "[LShop] Item find failed : Model is nil.\n" )
						return {}
					end				
				end
			end
		end
	end
end

LShop.ITEMs = {}

if ( CLIENT ) then
	function LShop.system.CSLoadItemFiles( )
		local find = file.Find("autorun/LShop/items/*.lua", "LUA") or {}

		PrintTable( find )
		if ( find ) then
			for k, v in pairs( find ) do
				include( "autorun/LShop/items/" .. v )
			end
		end
	end
	
	LShop.system.CSLoadItemFiles( )
end

--[[
LShop.system.ItemRegister( {
	ID = "sex",
	Name = "Sex on the beach",
	Category = "Sex",
	Price = 30,
	Ammo_ID = "smg1",
	Type = "ammo",
	Ammo_Count = 50,
	CanBuy = true,
	CanSell = true,
	CanEquip = false,
	OneUse = false,
	Desc = "섹스!",
	Model = "models/error.mdl",
	Buyed = function( item, ply )

	end,
	Selled = function( item, ply )

	end,
	Equipped = function( item, ply )
	
	end,
	Unequipped = function( item, ply )
		
	end
} )




for k, v in pairs( LShop.ITEMs ) do
	for i, a in pairs( v ) do
		--print( a.ID )
	end
end
--]]

if ( SERVER ) then
	util.AddNetworkString("LShop_ItemBuy")
	util.AddNetworkString("LShop_ItemSell")
	util.AddNetworkString("LShop_ItemEquip")
	util.AddNetworkString("LShop_ItemIsOwnCheck")
	util.AddNetworkString("LShop_ItemIsOwnCheck_SendCL")
	util.AddNetworkString("LShop_SendTable")
	util.AddNetworkString("LShop_SendTable_Request")
	util.AddNetworkString("LShop_SendMessage")
	util.AddNetworkString("LShop_BugNoticeSend")
	
	net.Receive("LShop_SendTable_Request", function( len, cl )
		net.Start("LShop_SendTable")
		net.WriteTable( cl.OwnItems )
		net.WriteString( cl.Money )
		net.Send( cl )
	end)
	--[[
		net.Start("LShop_SendTable")
		net.WriteTable( LShop.PlyItems )
		net.Broadcast()
	--]]
	net.Receive("LShop_ItemIsOwnCheck", function( len, cl )
		local check = self:LShop_IsOwn( net.ReadString() )
		if ( check ) then
			net.Start("LShop_ItemIsOwnCheck_SendCL")
			net.WriteString( "1" )
			net.Send( cl )
			print("1")
		else
			net.Start("LShop_ItemIsOwnCheck_SendCL")
			net.WriteString( "0" )
			net.Send( cl )		
			print("0")
		end
	end)
	
	function LShop.system.SendBugNotice( pl, title, value )
		local tab = {}
		tab.BugTitle = title
		tab.BugValue = value
		net.Start("LShop_BugNoticeSend")
		net.WriteTable( tab )
		net.Send( pl )
	end
		

	local Player = FindMetaTable('Player')
	
	function Player:LShop_ItemBuyProgress( itemID, category )
		local curretMoney = self:LShop_GetMoney( )
		local item = LShop.system.ItemFindByID( itemID, category )
		local checkOwn = self:LShop_IsOwn( itemID, category )
		if ( checkOwn ) then
			if ( item.OneUse ) then
				net.Start("LShop_SendMessage")
				net.WriteString( "You already own this item. : " .. itemID )
				net.Send( self )
				print("One use item!")
				return
			end
		end
		if ( item ) then
			if ( item.Price <= curretMoney ) then
				if ( !item.OneUse ) then
				--[[
					if ( !self.OwnItems[ self:SteamID() ] ) then
						self.OwnItems[ self:SteamID() ] = {}
						self.OwnItems[ #self.OwnItems + 1 ] = { ID = itemID, Category = category, onEquip = true }
						--self.OwnItems[ self:SteamID() ][ #self.OwnItems[ self:SteamID() ] + 1 ] = { ID = itemID, Category = category, onEquip = true }
						self:LShop_TakeMoney( item.Price )
					else
						self.OwnItems[ #self.OwnItems + 1 ] = { ID = itemID, Category = category, onEquip = true }
						--self.OwnItems[ self:SteamID() ][ #self.OwnItems[ self:SteamID() ] + 1 ] = { ID = itemID, Category = category, onEquip = true }
						self:LShop_TakeMoney( item.Price )
					end
				--]]
					if ( #self.OwnItems != 0 ) then
						for k, v in pairs( self.OwnItems ) do
							if ( v.ID != itemID ) then
								self.OwnItems[ #self.OwnItems + 1 ] = { ID = itemID, Category = category, onEquip = true }
								self:LShop_TakeMoney( item.Price )
								net.Start("LShop_SendMessage")
								net.WriteString( "You buyed this item. : " .. itemID )
								net.Send( self )
								if ( item.Buyed ) then
									item.Buyed( item, self )
								end
								PrintTable( self.OwnItems )
								return
							end
						end
					else
						self.OwnItems[ #self.OwnItems + 1 ] = { ID = itemID, Category = category, onEquip = true }
						self:LShop_TakeMoney( item.Price )
						return
					end
							
						--self.OwnItems[ self:SteamID() ][ #self.OwnItems[ self:SteamID() ] + 1 ] = { ID = itemID, Category = category, onEquip = true }
				else
					if ( #self.OwnItems != 0 ) then
						for k, v in pairs( self.OwnItems ) do
							if ( v.ID != itemID ) then
								self.OwnItems[ #self.OwnItems + 1 ] = { ID = itemID, Category = category, onEquip = true }
								self:LShop_TakeMoney( item.Price )
								net.Start("LShop_SendMessage")
								net.WriteString( "You buyed this item. : " .. itemID )
								net.Send( self )
								if ( item.Buyed ) then
									item.Buyed( item, self )
								end
								PrintTable( self.OwnItems )
								return
							end
						end
					else
						self.OwnItems[ #self.OwnItems + 1 ] = { ID = itemID, Category = category, onEquip = true }
						self:LShop_TakeMoney( item.Price )
					end
				end
				
				print("dd")
			else
				print("Not enough money!")
				net.Start("LShop_SendMessage")
				net.WriteString( "Not enough money! : LShop Alpha Ver" )
				net.Send( self )
			end
		else
			print("ERROR : Item is not exists!")
		end
	end
	

	
	function Player:LShop_ItemSellProgress( itemID, category )
		local item = LShop.system.ItemFindByID( itemID, category )
		local checkOwn = self:LShop_IsOwn( itemID, category )
		if ( checkOwn ) then
			self:LShop_ItemRemoveInventory( itemID, category )
			self:LShop_AddMoney( item.Price or 100 )
			net.Start("LShop_SendMessage")
			net.WriteString( "You selled this item. : " .. itemID .. " : " .. self:LShop_GetMoney() )
			net.Send( self )
			if ( item.Selled ) then
				item.Selled( item, self )
			end
		end
	end
	
	function Player:LShop_IsOwn( itemID, category )
		local id = LShop.system.ItemFindByID( tostring( itemID ), category )

		if ( id ) then
			for k, v in pairs( self.OwnItems ) do
				if ( v.ID == itemID ) then
					return true
				else
					if ( i == #v ) then
						LShop.system.SendBugNotice( self, "LShop_IsOwn 함수 오류!", "아이디에 맞는 아이템을 찾을 수 없었습니다. : " .. itemID )
						return nil -- 추후에 수정할것.
					end
				end
			end
		else
			LShop.system.SendBugNotice( self, "LShop_IsOwn 함수 오류!", "아이템을 찾을 수 없었습니다. : " .. itemID )
			return nil
		end
	end

	function Player:LShop_ItemRemoveInventory( itemID, category )
		--local item = LShop.system.ItemFindByID( itemID, category )
		--if ( item ) then
			for k, v in pairs( self.OwnItems ) do
				if ( v.ID == itemID ) then
					self.OwnItems[k] = nil
					print("REM")
					return
				else
					if ( k == #self.OwnItems ) then
						print("Own not found.")
						LShop.system.SendBugNotice( self, "LShop_ItemRemoveInventory 함수 오류!", "그 아이템을 가지고 있지 않습니다. : " .. itemID )
					end
				end
			end
			
		--else
		--	print("Item not found.")
		--end
	end
	
	function Player:LShop_PlayerSpawn()
		local item = self:LShop_GetOwnedItem( )
		--PrintTable( item )
		timer.Simple(1, function()
			--PrintTable( item )
			if ( item ) then
				for k, v in pairs( item ) do
					local findItem = LShop.system.ItemFindByID( v.ID, v.Category )
					if ( findItem ) then
						if ( findItem.OneUse ) then return end
						findItem.Equipped( findItem, self )
						print("Give item! : " .. findItem.Name )
					else
						self:LShop_ItemRemoveInventory( v.ID, v.Category )
					end
				end
			end
			PrintTable( self.OwnItems )
		end)
	end
	
	function Player:LShop_PlayerDeath()
		local ownitem = self:LShop_GetOwnedItem( )
		for k, v in pairs( ownitem ) do
			local item = LShop.system.ItemFindByID( v.ID, v.Category )
			if ( item ) then
				self:LShop_ItemRemoveInventory( item.ID, item.Category )
				print("Remove item : " .. item.ID )
			else
				self:LShop_ItemRemoveInventory( v.ID, v.Category )
				print("Remove item [2] : " .. v.ID )
			end
		end
	end
	
	function Player:LShop_SaveData()
		local dirName = string.Replace( self:SteamID(), ":", "_" )
		file.CreateDir("Lshop/" .. dirName)
		file.Write("Lshop/" .. dirName .. "/Ownitems.txt", util.TableToJSON( self.OwnItems ))
		file.Write("Lshop/" .. dirName .. "/Money.txt", tostring( self.Money ))
		LShop.core.Message( Color( 0, 255, 0 ), "Player data saved. : " .. self:SteamID() )
	end
	
	function Player:LShop_LoadData()
		local dirName = string.Replace( self:SteamID(), ":", "_" )
		if ( file.Exists("Lshop/" .. dirName .. "/Ownitems.txt", "DATA") ) then
			if ( file.Exists("Lshop/" .. dirName .. "/Money.txt", "DATA") ) then
				local money = file.Read("Lshop/" .. dirName .. "/Money.txt", "DATA") or 0
				local ownitems = file.Read("Lshop/" .. dirName .. "/Ownitems.txt", "DATA") or "[]"
				self.Money = tonumber( money )
				self.OwnItems = util.JSONToTable( ownitems )
				LShop.core.Message( Color( 0, 255, 0 ), "Player data loaded. : " .. self:SteamID() )
			else
				self.Money = 0
				self.OwnItems = {}
				self:LShop_SaveData()
			end
		else
			self.Money = 0
			self.OwnItems = {}
			self:LShop_SaveData()
		end
	end

	function Player:LShop_PlayerInitialSpawn()
		self.Money = 0
		self.OwnItems = {}
		
		timer.Simple( 2, function()
			if ( IsValid( self ) ) then
				self:LShop_LoadData()
			end
		end)
		
		timer.Create("LShop_AutoMoneyGive_" .. self:SteamID(), LShop.Config.MoneyGiveTimer, 0, function() 
			if ( LShop.Config.AutoMoneyGive ) then
				self:LShop_AddMoney( LShop.Config.MoneyAmmount )
				self:SendLua("GAMEMODE:AddNotify(\"You gift from server " .. LShop.Config.MoneyAmmount .. " $.\", NOTIFY_NONE, 10)")
				-- LShop.Config.MoneyAmmount
				print("Money give!")
			end
		end)
	end

	function Player:LShop_PlayerDisconnected()
		self:LShop_SaveData()
		if ( timer.Exists( "LShop_AutoMoneyGive_" .. self:SteamID() ) ) then
			timer.Destroy( "LShop_AutoMoneyGive_" .. self:SteamID() )
		end
	end
	
	function Player:LShop_GetOwnedItem( )
		return self.OwnItems
	end
	
	--PrintTable( LShop.ITEMs )
	hook.Add('PlayerSpawn', 'LShop_PlayerSpawn', function(pl) pl:LShop_PlayerSpawn() end)
	hook.Add('PlayerDeath', 'LShop_PlayerDeath', function(pl) pl:LShop_PlayerDeath() end)
	hook.Add('PlayerInitialSpawn', 'LShop_PlayerInitialSpawn', function(pl) pl:LShop_PlayerInitialSpawn() end)
	hook.Add('PlayerDisconnected', 'LShop_PlayerDisconnected', function(pl) pl:LShop_PlayerDisconnected() end)

	concommand.Add("Lshop_resetitems", function( pl, cmd, args )
		pl:LShop_LoadData()
	end)
	
	net.Receive("LShop_ItemBuy", function( len, cl )
		local category = net.ReadString()
		local itemID = net.ReadString()
		cl:LShop_ItemBuyProgress( itemID, category )
		LShop.system.SendDBToPlayer( cl )
		cl:LShop_SaveData()
	end)
	
	net.Receive("LShop_ItemSell", function( len, cl )
		local category = net.ReadString()
		local itemID = net.ReadString()
		cl:LShop_ItemSellProgress( itemID, category )
		LShop.system.SendDBToPlayer( cl )
		cl:LShop_SaveData()
	end)
	
	net.Receive("LShop_ItemEquip", function( len, cl )
		local category = net.ReadString()
		local itemID = net.ReadString()
		local bool = net.ReadString()
		cl:onEquipProgress( itemID, bool, category )
		
		cl:LShop_SaveData()
		print("Received")
	end)
--[[
	function LShop.system.ItemSave( )
		file.CreateDir("Lshop/items")
		file.Write("Lshop/items/Items.txt", util.TableToJSON( LShop.PlyItems ))
		print("Save items")
	end
	
	function LShop.system.ItemLoad( )
		local read = file.Read("Lshop/items/Items.txt","DATA") or nil
		if ( read ) then
			LShop.PlyItems = util.JSONToTable( read )
			net.Start("LShop_SendTable")
			net.WriteTable( LShop.PlyItems )
			net.Broadcast()
		end
		print("Load items")
	end
--]]	
	hook.Add( "Initialize", "FirstLoad", function( )
	--	LShop.system.ItemLoad( )
	end)

	
	
	
	function LShop.system.SendDBToPlayer( pl )
		if ( IsValid( pl ) ) then
			net.Start("LShop_SendTable")
			net.WriteTable( pl.OwnItems )
			net.WriteString( pl.Money )
			net.Send( pl )	
		end
	end
	
	
	function Player:onEquipProgress( itemID, bool, category )
		local id = LShop.system.ItemFindByID( itemID, category )
		if ( id ) then
			for k, v in pairs( self.OwnItems ) do
				if ( v.ID == itemID ) then
					v.onEquip = tobool( bool )
					net.Start("LShop_SendMessage")
					net.WriteString( "You equipped this item. : " .. itemID .. " : " .. bool )
					net.Send( self )
					if ( v.onEquip ) then
						id.Equipped( id, self )
					else
						id.Unequipped( id, self )
					end
					LShop.system.SendDBToPlayer( self )
					return
				else				
					if ( k == #self.OwnItems ) then
						print("ERROR : Not buy. 3")
						net.Start("LShop_SendMessage")
						net.WriteString( "Not buy. : " .. itemID .. " : " .. bool )
						net.Send( self )
						return
					end
				end
			end
		end
	end
	--LShop.PlyItems = {}
	
	function LShop.system.SVLoadItemFiles( )
		local find = file.Find("autorun/LShop/items/*.lua", "LUA") or {}

		PrintTable( find )
		if ( find ) then
			for k, v in pairs( find ) do
				LShop.core.LoadFile( "autorun/LShop/items/" .. v )
				LShop.core.CSLoadFile( "autorun/LShop/items/" .. v )
			end
		end
	end
	
	LShop.system.SVLoadItemFiles( )
end