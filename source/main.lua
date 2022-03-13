import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "player"

local gfx<const> = playdate.graphics
local dsp<const> = playdate.display

local centerX<const> = dsp.getWidth() / 2
local centerY<const> = dsp.getHeight() / 2
local playerSpriteHeight<const> = 50

local fieldBoundary<const> = 30
local maxGameSpeed<const> = 6

local p1 = nil
local ai = nil

local ballSprite = nil

local vx = maxGameSpeed * (math.random(0, 1) == 0 and 1 or -1)
local vy = math.random(3, maxGameSpeed)

local function initalize()
  math.randomseed(playdate.getSecondsSinceEpoch())
  p1 = Human(2, "images/plong-player", 10, centerY)
  ai = Computer(5, "images/plong-player", 390, centerY)

  ballSprite = gfx.sprite.new(gfx.image.new("images/plong-ball"))
  ballSprite:setCollideRect(0, 0, ballSprite:getSize())
  ballSprite:add()

  playdate.display.setInverted(true)
  resetBall()
end

function resetBall()
  vx = maxGameSpeed * (math.random(0, 1) == 0 and 1 or -1)
  vy = math.random(3, maxGameSpeed) * (math.random(0, 1) == 0 and 1 or -1)
  ballSprite:moveTo(centerX, centerY)
end

initalize()

function playerOneInputHandler()
  local playerPos = p1.sprite.y;
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    if playerPos > fieldBoundary then
      p1:moveBy(0, -p1.speed)
      if p1.speed < 15 then
        p1.speed = p1.speed + 1
      end
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonDown) then
    if playerPos < (dsp.getHeight() - fieldBoundary) then
      p1:moveBy(0, p1.speed)
      if p1.speed < 15 then
        p1.speed = p1.speed + 1
      end
    end
  end
  if playdate.buttonJustReleased(playdate.kButtonUp) or
      playdate.buttonJustReleased(playdate.kButtonDown) then
    p1.speed = 2
  end

  if playdate.buttonIsPressed(playdate.kButtonB) then
    resetBall()
  end
end

function moveAi()
  if vy > 0 then
    if ai.prevDir == 1 and ai.speed < 10 then ai.speed += 1
    else ai.speed = 1 end
    ai.prevDir = 1
    if ai.sprite.y < (ballSprite.y) and ai.sprite.y <
        (dsp.getHeight() - fieldBoundary) then
      ai:moveBy(0, ai.speed)
    else ai.speed = 1
    end
  else
    if ai.prevDir == -1 and ai.speed < 10 then ai.speed += 1
    else ai.speed = 1 end
    ai.prevDir = -1
    if ai.sprite.y > (ballSprite.y) and ai.sprite.y >
        fieldBoundary then
      ai:moveBy(0, -ai.speed)
    else ai.speed = 1
    end
  end
  print('ai speed : ' .. ai.speed)
end

function moveBall()
  ballSprite:moveTo(ballSprite.x + vx, ballSprite.y + vy)
end

function checkCollisions()
  if ballSprite.y <= 2.5 or ballSprite.y >= 237.5 then
    vy = -vy
  end
  local collisions = ballSprite:overlappingSprites()
  if #collisions >= 1 then
    local collidingPlayer = collisions[1];
    local ballX = ballSprite.x
    local ballY = ballSprite.y
    local playerY = collidingPlayer.y
    local dif = playerY - ballY
    vx = -vx
    if (vx < 0 and ballX > 0 and ballX < (centerX / 2)) then return end
    if (vx > 0 and ballX < 0 and ballX > (centerX / 2)) then return end
    if dif > -4 and dif < 4 then
      if vy > 0 then vy = 1 else vy = -1 end
    elseif dif > -18 and dif < 18 then
      vy = vy - 1
    else
      if dif < 0 then vy = math.abs(vy + math.random(4, 6))
      else vy = -math.abs(vy - math.random(4, 6)) end
    end
  end
end

function checkScore()
  if ballSprite.x <= 5 then
    ai.score = ai.score + 1
    resetBall()
  end
  if ballSprite.x >= 395 then
    p1.score = p1.score + 1
    resetBall()
  end
end

function playdate.update()
  playerOneInputHandler()
  checkCollisions()
  moveAi()
  moveBall()
  checkScore()

  playdate.timer.updateTimers()
  gfx.sprite.update()

  gfx.drawText(p1.score, centerX - (centerX / 2), 5)
  gfx.drawText(ai.score, centerX + (centerX / 2), 5)
end
