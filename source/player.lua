import "CoreLibs/object"

local gfx<const> = playdate.graphics
local dsp<const> = playdate.display
local playerHeight<const> = 25
local twoHumanGame = false

class('Player').extends()

function Player:init(speed, minSpeed, maxSpeed)
  self.sprite = nil
  self.speed = speed or 5
  self.score = 0
  self.prevDir = 0
  self.maxSpeed = maxSpeed
  self.minSpeed = minSpeed
end
function Player:loadSprite(path)
  local loadedImage = gfx.image.new(path)
  self.sprite = gfx.sprite.new(loadedImage)
  self.sprite:setCollideRect(5, 0, 1, 50)
end
function Player:setStartPosition(x, y)
  self.sprite:moveTo(x, y)
  self.sprite:add()
end
function Player:remove()
    self.sprite:remove()
end
function Player:moveBy(x, y, dir)
  if (dir == 'up' and self.sprite.y + y > (playerHeight / 5)) or
      (dir == 'down' and self.sprite.y + y <
          (dsp.getHeight() - (playerHeight / 5))) then
    self.sprite:moveBy(x, y)
  else
    self.speed = self.minSpeed
  end
end
function Player:setSpeed(prevDir, currentDir)
  if prevDir == currentDir then
    if self.speed < self.maxSpeed then
      self.speed = self.speed + self.speedVelocity
    end
  else
    self.speed = self.minSpeed
  end
end

class('Human').extends(Player)

function Human:init(minSpeed, maxSpeed, spritePath, startPosX, startPosY, disablePad)
  self.disablePad = disablePad or false
  self.speedVelocity = 1
  Human.super.init(self, minSpeed, minSpeed, maxSpeed)
  Human.loadSprite(self, spritePath)
  Human.setStartPosition(self, startPosX, startPosY)
end
function Human:handleMovement()
  local myInputHandlers = {
    cranked = function(change, acceleratedChange)
      if (change > 0) then
        self:moveBy(0, change, 'down')
      else
        self:moveBy(0, change, 'up')
      end
    end
  }
  playdate.inputHandlers.push(myInputHandlers)
  if (self.disablePad) then return end
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    self:setSpeed(self.prevDir, -1)
    self:moveBy(0, -self.speed, 'up')
    self.prevDir = -1
  elseif playdate.buttonIsPressed(playdate.kButtonDown) then
    self:setSpeed(self.prevDir, 1)
    self:moveBy(0, self.speed, 'down')
    self.prevDir = 1
  else
    self.speed = self.minSpeed
  end
end

class('Computer').extends(Player)

function Computer:init(minSpeed, maxSpeed, spritePath, startPosX, startPosY,
                       precision, speedVelocity)
  self.precision = precision or 20
  self.speedVelocity = speedVelocity or 1
  if startPosX < dsp.getWidth() / 2 then
    self.placement = 'left'
  else
    self.placement = 'right'
  end
  Computer.super.init(self, minSpeed, minSpeed, maxSpeed)
  Computer.loadSprite(self, spritePath)
  Computer.setStartPosition(self, startPosX, startPosY)
end

function Computer:handleMovement(vx, vy, ballSprite)
  if (self.placement == 'left' and vx > 0) then
    self.speed = self.minSpeed
  elseif (self.placement == 'right' and vx < 0) then
    self.speed = self.minSpeed
  elseif ballSprite.y > (self.sprite.y + math.random(0, self.precision)) then
    self:setSpeed(self.prevDir, 1)
    self:moveBy(0, self.speed, 'down')
    self.prevDir = 1
  elseif ballSprite.y < (self.sprite.y - math.random(0, self.precision)) then
    self:setSpeed(self.prevDir, -1)
    self:moveBy(0, -self.speed, 'up')
    self.prevDir = -1
  else
    self.speed = self.minSpeed
  end
end
