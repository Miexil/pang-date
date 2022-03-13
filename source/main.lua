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
local maxGameSpeed<const> = 7

local p1 = nil
local ai = nil

local ballSprite = nil

local vx = math.random(3, maxGameSpeed)
local vy = math.random(3, maxGameSpeed)

local function initalize()
  math.randomseed(playdate.getSecondsSinceEpoch())
  p1 = Human(5, "images/plong-player", 10, centerY)
  ai = Computer(5, "images/plong-player", 390, centerY)

  ballSprite = gfx.sprite.new(gfx.image.new("images/plong-ball"))
  ballSprite:setCollideRect(0, 0, ballSprite:getSize())
  ballSprite:add()

  playdate.display.setInverted(true)
  resetBall()
end

function resetBall()
  vx = math.random(3, maxGameSpeed) * (math.random(0, 1) == 0 and 1 or -1)
  vy = math.random(3, maxGameSpeed) * (math.random(0, 1) == 0 and 1 or -1)
  ballSprite:moveTo(centerX, centerY)
end

initalize()

function playerOneInputHandler()
  local playerPos = p1.sprite.y;
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    if playerPos > fieldBoundary then
      p1:moveBy(0, -p1.speed)
      if p1.speed < 10 then
        p1.speed = p1.speed + 1
      end
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonDown) then
    if playerPos < (dsp.getHeight() - fieldBoundary) then
      p1:moveBy(0, p1.speed)
      if p1.speed < 10 then
        p1.speed = p1.speed + 1
      end
    end
  end
  if playdate.buttonJustReleased(playdate.kButtonUp) or
      playdate.buttonJustReleased(playdate.kButtonDown) then
    p1.speed = 5
  end

  if playdate.buttonIsPressed(playdate.kButtonB) then
    resetBall()
  end
end

function moveAi()
  ai.speed = math.random(3, maxGameSpeed)
  if vy > 0 then
    if ai.sprite.y < (ballSprite.y - fieldBoundary) and ai.sprite.y <
        (dsp.getHeight() - fieldBoundary) then
      ai:moveBy(0, ai.speed)
    end
  else
    if ai.sprite.y > (ballSprite.y + fieldBoundary) and ai.sprite.y >
        fieldBoundary then
      ai:moveBy(0, -ai.speed)
    end
  end
end

function moveBall()
  ballSprite:moveTo(ballSprite.x + vx, ballSprite.y + vy)
end

function checkCollisions()
  if ballSprite.y <= 5 or ballSprite.y >= 235 then
    vy = -vy
  end
  local collisions = ballSprite:overlappingSprites()
  if #collisions >= 1 then
    local collidingPlayer = collisions[1];
    local ballY = ballSprite.y
    local playerY = collidingPlayer.y
    local dif = playerY - ballY
    vx = -vx
    if dif > -8 and dif < 8 then
    elseif dif > -18 and dif < 18 then
      if (dif > 0) then
        vy = dif / math.random(1, 3)
      else
        vy = dif / math.random(1, 3)
      end
    else
      if (dif > 0) then
        vy = -dif / math.random(4, maxGameSpeed)
      else
        vy = -dif / math.random(4, maxGameSpeed)
      end
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
