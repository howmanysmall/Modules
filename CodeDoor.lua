local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local lower = string.lower
local function Tween(Object, Length, Style, Direction, Properties)
	local Tween = TweenService:Create(Object, TweenInfo.new(Length, Enum.EasingStyle[Style].Value, Enum.EasingDirection[Direction].Value), Properties)
	local TweenCompleted = false
	Tween.Completed:Connect(function(PlaybackState)
		if PlaybackState == Enum.PlaybackState.Completed then
			TweenCompleted = true
		end
	end)
	Tween:Play()
	while not TweenCompleted do wait() end
end

local Door = script.Parent
local Code = lower("Door")

local function OpenDoor(Length)
	Length = Length or 0.5
	Tween(Door, Length, "Quint", "Out", { Transparency = 1 })
	Door.CanCollide = false
	wait(1)
	Door.CanCollide = true
	Tween(Door, Length, "Quint", "Out", { Transparency = 0 })
end

Players.PlayerAdded:Connect(function(Player)
	Player.Chatted:Connect(function(Message)
		if lower(Message) == Code then
			OpenDoor(1)
		end
	end)
end)
