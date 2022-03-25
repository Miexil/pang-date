import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "player"
import "menu"

local gfx<const> = playdate.graphics
local dsp<const> = playdate.display

local centerX<const> = dsp.getWidth() / 2
local centerY<const> = dsp.getHeight() / 2
local playerSpriteHeight<const> = 50

fieldBoundary = 30
maxGameSpeed = 6

local p1 = nil
local p2 = nil

local ballSprite = nil

local vx = nil
local vy = nil

local round = 0
gameReady = false

local function init()
  math.randomseed(playdate.getSecondsSinceEpoch())
  playdate.display.setInverted(true)
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeNXOR)
end

function setupGameAndStart(p1Dif, p2Dif)
  if p1Dif == 1 then
    p1 = Human(1, 15, "images/plong-player", 10, centerY)
  elseif p1Dif == 2 then
    p1 = Computer(1, 15, "images/plong-player", 5, centerY, 25, 1) -- EASY
  elseif p1Dif == 3 then
    p1 = Computer(1, 15, "images/plong-player", 10, centerY, 1, 2) -- MEDIUM
  end
  
  if p2Dif == 1 then
    p2 = Human(1, 15, "images/plong-player",  395, centerY)
  elseif p2Dif == 2 then
    p2 = Computer(1, 15, "images/plong-player", 395, centerY, 25, 1) -- EASY
  elseif p2Dif == 3 then
    p2 = Computer(1, 20, "images/plong-player", 395, centerY, 1, 2) -- MEDIUM
  end

  gameReady = true
  ballSprite = gfx.sprite.new(gfx.image.new("images/plong-ball"))
  ballSprite:setCollideRect(0, 0, ballSprite:getSize())
  ballSprite:add()
  resetBall()
end

function resetBall()
  vx = maxGameSpeed * (math.random(0, 1) == 0 and 1 or -1)
  vy = math.random(3, maxGameSpeed) * (math.random(0, 1) == 0 and 1 or -1)
  ballSprite:moveTo(centerX, centerY)
end

function moveBall() ballSprite:moveTo(ballSprite.x + vx, ballSprite.y + vy) end

function checkCollisions()
  -- print('ball x : ' .. ballSprite.x .. ' y : ' .. ballSprite.y .. ' vx : ' .. vx .. ' vy : ' .. vy)
  if ballSprite.y <= 5 then
    vy = math.abs(vy)
  elseif ballSprite.y >= 235 then
    vy = -math.abs(vy)
  end
  local collisions = ballSprite:overlappingSprites()
  if #collisions >= 1 then
    local collidingPlayer = collisions[1];
    local dif = collidingPlayer.y - ballSprite.y
    vx = -vx
    if (vx < 0 and ballSprite.x > 0 and ballSprite.x < (centerX / 2)) then
      print('early return')
      return
    end
    if (vx > 0 and ballSprite.x < 0 and ballSprite.x > (centerX / 2)) then
      print('early return')
      return
    end
    if dif > -4 and dif < 4 then
      print('middle')
      if vy > 0 then
        vy = math.random(0, 1)
      else
        vy = -math.random(0, 1)
      end
    elseif dif > -18 and dif < 18 then
      print('middle-edge')
      if dif < 0 then
        vy = math.abs(vy + math.random(1, 3))
      else
        vy = -math.abs(vy - math.random(1, 3))
      end
    else
      print('edge')
      if dif < 0 then
        vy = math.abs(vy + math.random(4, 6))
      else
        vy = -math.abs(vy - math.random(4, 6))
      end
    end
  end
end

function resetRound()
  resetBall()
  gfx.sprite.update()
  drawScore();
  gfx.drawText('*Round ' .. round .. '*', centerX - 30, centerY + 50)
  playdate.wait(1500)
end

function checkScore()
  if ballSprite.x <= 5 then
    p2.score = p2.score + 1
    round = round + 1
    resetRound()
  end
  if ballSprite.x >= 395 then
    p1.score = p1.score + 1
    round = round + 1
    resetRound()
  end
end

function drawScore()
  gfx.drawText(p1.score, centerX - (centerX / 2), 5)
  gfx.drawText(p2.score, centerX + (centerX / 2), 5)
end

function gameLoop()
  checkCollisions()
  p1:handleMovement(vx, vy, ballSprite)
  p2:handleMovement(vx, vy, ballSprite)
  moveBall()
  checkScore()

  playdate.timer.updateTimers()
  gfx.sprite.update()
  drawScore()
  if playdate.buttonIsPressed(playdate.kButtonB) then resetBall() end
  if (round == 0) then
    round = round + 1
    gfx.drawText('*Round ' .. round .. '*', centerX - 30, centerY + 50)
    playdate.wait(1500)
  end
end

function playdate.update()
  if (gameReady) then
    gameLoop()
  else
    gameMenu()
  end
  playdate.drawFPS(0,0)
end

init()
