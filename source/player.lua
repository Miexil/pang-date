import "CoreLibs/object"

local gfx<const> = playdate.graphics
local dsp<const> = playdate.display

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
function Player:moveBy(x, y) self.sprite:moveBy(x, y) end

class('Human').extends(Player)

function Human:init(speed, spritePath, startPosX, startPosY)
  Human.super.init(self, speed)
  Human.loadSprite(self, spritePath)
  Human.setStartPosition(self, startPosX, startPosY)
end
function Human:handleMovement()
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    printTable(self.sprite.y)
    printTable(fieldBoundary)
    if self.sprite.y > fieldBoundary then
      self:moveBy(0, -self.speed)
      if self.speed < 15 then self.speed = self.speed + 1 end
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonDown) then
    if self.sprite.y < (dsp.getHeight() - fieldBoundary) then
      self:moveBy(0, self.speed)
      if self.speed < 15 then self.speed = self.speed + 1 end
    end
  end
  if playdate.buttonJustReleased(playdate.kButtonUp) or
      playdate.buttonJustReleased(playdate.kButtonDown) then self.speed = 2 end

  if playdate.buttonIsPressed(playdate.kButtonB) then resetBall() end
end

class('Computer').extends(Player)

function Computer:init(minSpeed, maxSpeed, spritePath, startPosX, startPosY, precision, speedVelocity)
  self.prevDir = 0
  self.maxSpeed = maxSpeed
  self.minSpeed = minSpeed
  self.precision = precision or 20
  self.speedVelocity = speedVelocity or 1
  if startPosX < dsp.getWidth() / 2 then self.placement = 'left' else self.placement = 'right' end
  Computer.super.init(self, minSpeed)
  Computer.loadSprite(self, spritePath)
  Computer.setStartPosition(self, startPosX, startPosY)
end

function Computer:setSpeed(prevDir, currentDir)
  if prevDir == currentDir then
    if self.speed < self.maxSpeed then
      self.speed = self.speed + self.speedVelocity
    end
  else
    self.speed = self.minSpeed
  end
end

function Computer:handleMovement(vx, vy, ballSprite)
  if (self.placement == 'left' and vx > 0) then self.speed = self.minSpeed return end
  if (self.placement == 'right' and vx < 0) then self.speed = self.minSpeed  return end
  if (ballSprite.y > (self.sprite.y - (self.precision + 15)) and ballSprite.y < (self.sprite.y + (self.precision + 15))) then print('do nothing') self.speed = self.minSpeed return end
  if math.random(ballSprite.y - self.precision, ballSprite.y + self.precision) > self.sprite.y + math.random(0, self.precision) and self.sprite.y < (dsp.getHeight() - fieldBoundary) then
    self:setSpeed(self.prevDir, 1)
    self:moveBy(0, self.speed)
    self.prevDir = 1
  elseif math.random(ballSprite.y - self.precision, ballSprite.y + self.precision) < self.sprite.y - math.random(0, self.precision) and self.sprite.y > fieldBoundary then
    self:setSpeed(self.prevDir, -1)
    self:moveBy(0, -self.speed)
    self.prevDir = -1
  else
    self.speed = self.minSpeed
  end
end
