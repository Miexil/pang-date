import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- easy -> follow dir of vx,vy 
-- medium -> calculate final position but partly :D
-- hard -> calculate final position

-- Every minute ball goes faster

local gfx<const> = playdate.graphics
local dsp<const> = playdate.display

local centerX<const> = dsp.getWidth() / 2
local centerY<const> = dsp.getHeight() / 2

local playerSprite = nil
local aiSprite = nil
local playerSpeed = 5

local ballSprite = nil
local p1Score = 0
local p2Score = 0

local vx = math.random(2, 4)
local vy = math.random(2, 4)

local function initalize()
  math.randomseed(playdate.getSecondsSinceEpoch())
  local playerImage = gfx.image.new("images/plong-player")
  playerSprite = gfx.sprite.new(playerImage)
  playerSprite:moveTo(10, centerY)
  playerSprite:setCollideRect(0, 0, playerSprite:getSize())
  playerSprite:add()

  aiSprite = gfx.sprite.new(playerImage)
  aiSprite:moveTo(390, centerY)
  aiSprite:setCollideRect(0, 0, aiSprite:getSize())
  aiSprite:add()

  ballSprite = gfx.sprite.new(gfx.image.new("images/plong-ball"))
  ballSprite:setCollideRect(0, 0, ballSprite:getSize())
  ballSprite:add()

  playdate.display.setInverted(true)
end

function resetBall()
  vx = math.random(3, 4) * (math.random(0, 1) == 0 and 1 or -1)
  vy = math.random(3, 4) * (math.random(0, 1) == 0 and 1 or -1)
  ballSprite:moveTo(centerX, centerY)
end

initalize()
resetBall()

function playerOneInputHandler()
  local playerPos = playerSprite.y;
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    if playerPos > 30 then
      playerSprite:moveBy(0, -playerSpeed)
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonDown) then
    if playerPos < 210 then
      playerSprite:moveBy(0, playerSpeed)
    end
  end
  if playdate.buttonIsPressed(playdate.kButtonB) then
    resetBall()
  end
end

function moveAi()
  if vx > 0 then
    if vy > 0 then
      if aiSprite.y < ballSprite.y and aiSprite.y < 210 then
        aiSprite:moveBy(0, playerSpeed)
      end
    else
      if aiSprite.y > ballSprite.y and aiSprite.y > 30 then
        aiSprite:moveBy(0, -playerSpeed)
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
    p2Score = p2Score + 1
    resetBall()
  end
  if ballSprite.x >= 395 then
    p1Score = p1Score + 1
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

  gfx.drawText(p1Score, centerX - (centerX / 2), 5)
  gfx.drawText(p2Score, centerX + (centerX / 2), 5)
end
