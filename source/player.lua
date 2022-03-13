import "CoreLibs/object"

local gfx<const> = playdate.graphics

class('Player').extends()

function Player:init(speed)
  self.sprite = nil
  self.speed = speed or 5
  self.score = 0
end
function Player:loadSprite(path)
  local loadedImage = gfx.image.new(path)
  self.sprite = gfx.sprite.new(loadedImage)
  self.sprite:setCollideRect(0, 0, self.sprite:getSize())
end
function Player:setStartPosition(x, y)
  self.sprite:moveTo(x, y)
  self.sprite:add()
end
function Player:moveBy(x, y)
  self.sprite:moveBy(x, y)
end

class('Human').extends(Player)

function Human:init(speed, spritePath, startPosX, startPosY)
  Player.init(self, speed)
  Player.loadSprite(self, spritePath)
  Player.setStartPosition(self, startPosX, startPosY)
end

class('Computer').extends(Player)

function Computer:init(speed, spritePath, startPosX, startPosY)
  Player.init(self, speed)
  Player.loadSprite(self, spritePath)
  Player.setStartPosition(self, startPosX, startPosY)
end
