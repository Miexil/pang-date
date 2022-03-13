import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "player"

local gfx<const> = playdate.graphics
local dsp<const> = playdate.display

local centerX<const> = dsp.getWidth() / 2
local centerY<const> = dsp.getHeight() / 2

local fieldBoundary<const> = 30

local p1 = nil
local ai = nil

local ballSprite = nil

local vx = math.random(2, 4)
local vy = math.random(2, 4)

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
  vx = math.random(3, 4) * (math.random(0, 1) == 0 and 1 or -1)
  vy = math.random(3, 4) * (math.random(0, 1) == 0 and 1 or -1)
  ballSprite:moveTo(centerX, centerY)
end

initalize()

function playerOneInputHandler()
  local playerPos = p1.sprite.y;
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    if playerPos > fieldBoundary then
      p1:moveBy(0, -p1.speed)
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonDown) then
    if playerPos < (dsp.getHeight() - fieldBoundary) then
      p1:moveBy(0, p1.speed)
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonB) then
    resetBall()
  end
end

function moveAi()
  if vx > 0 then
    if vy > 0 then
      if ai.sprite.y < ballSprite.y and ai.sprite.y <
          (dsp.getHeight() - fieldBoundary) then
        ai:moveBy(0, ai.speed)
      end
    else
      if ai.sprite.y > ballSprite.y and ai.sprite.y > fieldBoundary then
        ai:moveBy(0, -ai.speed)
      end
    end
  end
end

function moveBall()
  ballSprite:moveTo(ballSprite.x + vx, ballSprite.y + vy)
end

function checkCollision()
  if ballSprite.y <= 5 or ballSprite.y >= 235 then
    vy = -vy
  end
  local collisions = ballSprite:overlappingSprites()
  -- add direction detection here to prevent glitches
  if #collisions >= 1 then
    vx = -vx
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
  checkCollision()
  moveBall()
  moveAi()
  checkScore()

  playdate.timer.updateTimers()
  gfx.sprite.update()

  gfx.drawText(p1.score, centerX - (centerX / 2), 5)
  gfx.drawText(ai.score, centerX + (centerX / 2), 5)
end
