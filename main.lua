WWIDTH=640
VIEWPORT_HEIGHT=400
TILESIZE=150
HOR_MARGIN=220
VER_MARGIN=100
TILESIZE=65
MSGFONT=love.graphics.newFont("fonts/Orbitron Medium.otf",20)
GAMEOVERFONT=love.graphics.newFont("fonts/Orbitron Medium.otf",17)
TICTACFONT=love.graphics.newFont(60)
msg="Player 0's Turn:  Click on one of the grids"
tileGrid={{"","",""},{"","",""},{"","",""}}
emptySpaces={{1,1},{1,2},{1,3},{2,1},{2,2},{2,3},{3,1},{3,2},{3,3}}
--winComb will contain the indices of all the elements
winComb={}
math.randomseed(os.time())
player_in_action="0"
popup=false
colors=require('lib/colorcodes')
game_state='main_menu'
aiX=true
ai0=true
level=3
timer=0
function love.load()
    back=love.graphics.newImage("images/bck.jpg")
    text=love.graphics.newImage("images/text.png")
    BACKGROUND_MUSIC=love.audio.newSource("sounds/music.wav",'static')
    
    text2=love.graphics.newImage("images/text2.png")
    love.window.setMode(WWIDTH,VIEWPORT_HEIGHT+50)
    GAME_BACKGROUND=love.graphics.newImage("images/tabs-bg.jpg")
    love.window.setTitle("TicTacToe")
    love.graphics.setFont(TICTACFONT)
end

function love.draw()
    if game_state=='main_menu' then
        main_menu()
    elseif game_state=='select_combination' then
        select_combination()
    elseif game_state=='select_difficulty' then
        select_difficulty_level()
    else
        love.graphics.setColor(1,1,1)
        love.graphics.draw(GAME_BACKGROUND,0,0,0,0.5,1.15)
        drawGrid()
        drawHUD()
    end
end

function drawGrid()
    love.graphics.setFont(TICTACFONT)
    for y=1,3,1 do
        for x=1,3,1 do
            if y~=3 then
                love.graphics.line(HOR_MARGIN,VER_MARGIN+y*TILESIZE,WWIDTH-HOR_MARGIN-7,VER_MARGIN+y*TILESIZE)
                love.graphics.line(HOR_MARGIN+y*TILESIZE,VER_MARGIN,HOR_MARGIN+y*TILESIZE,VIEWPORT_HEIGHT-VER_MARGIN-8)
            end
            if ((checkDiagonal("0")==true or checkDiagonal("X")==true) and elementInTable(winComb,y,1)==elementInTable(winComb,x,2)) or 
                ((checkDiagonal("0")==false and checkDiagonal("X")==false) and elementInTable(winComb,y,1)>0 and elementInTable(winComb,x,2)>0)  then
                love.graphics.setColor(1,0,0)
            end
            love.graphics.printf(tileGrid[y][x],HOR_MARGIN+(x-1)*TILESIZE,VER_MARGIN+(y-1)*TILESIZE,TILESIZE,'center')
            love.graphics.setColor(1,1,1)
            
        end
        drawWinnerLine(y)
    end
   if checkWinner()==nil and user_can_play() and checkAllFull()==false then
        mouseHover() 
   else
    if popup==true then
        popupMsg()   
    end
   end
end

function drawHUD()
    love.graphics.setFont(MSGFONT)
    love.graphics.setColor(0,0,0,0.5)    
    love.graphics.rectangle('fill',0,VIEWPORT_HEIGHT,WWIDTH,50)
    love.graphics.setColor(1,1,1)
    love.graphics.line(0,VIEWPORT_HEIGHT,WWIDTH,VIEWPORT_HEIGHT)
    love.graphics.printf(msg,0,VIEWPORT_HEIGHT+15,WWIDTH,'center')
    love.graphics.line(0,VIEWPORT_HEIGHT,0,VIEWPORT_HEIGHT+50)
    love.graphics.line(WWIDTH,VIEWPORT_HEIGHT,WWIDTH,VIEWPORT_HEIGHT+50)
    love.graphics.line(0,VIEWPORT_HEIGHT+50,WWIDTH,VIEWPORT_HEIGHT+50)
    love.graphics.setColor(1,1,1)
end

function mouseHover()
    x=love.mouse.getX()
    y=love.mouse.getY()
    love.graphics.setColor(1,1,1,0.5)
    for j=1,3,1 do
        for i=1,3,1 do
            if x>=HOR_MARGIN +(j-1)*TILESIZE and x<=HOR_MARGIN+j*TILESIZE and y>=VER_MARGIN + (i-1)*TILESIZE and y<=VER_MARGIN+i*TILESIZE then
                love.graphics.rectangle('fill',HOR_MARGIN+(j-1)*TILESIZE,VER_MARGIN+(i-1)*TILESIZE,TILESIZE,TILESIZE)
            end
        end
    end
    love.graphics.setColor(1,1,1)    
end

function elementInTable(tbl,el,index)
    for i in ipairs(tbl) do
        if tbl[i][index]==el then
            return i;
        end
    end
    return 0
end

function removeElement (x,y)
    n=#emptySpaces
    for i=1,n do
        if emptySpaces[i] ~=nil then
            if emptySpaces[i][1]==x and emptySpaces[i][2]==y then
                table.remove(emptySpaces,i)
                break;
            end
        end
    end
end 

function user_can_play(ai)
    if ai then return true end
    if player_in_action=="0" and ai0==true then
        return false
    elseif player_in_action=="X" and aiX==true then
        return false
    else
        return true
    end
end

function love.mousereleased(x,y,btn,ai)
    if btn==1 then
        if game_state=='main_menu' then
            game_state='select_combination'
        elseif game_state=='select_combination' then
            if x>=80 and x<=256 and y>=190 and y<=208 then
                ai0,aiX=false,false
                game_state='play'
            elseif x>=80 and x<=285 and y>=250 and y<=268 then
                ai0,aiX=false,true
                game_state='select_difficulty'
            elseif x>=80 and x<=315 and y>=310 and y<=328 then
                ai0,aiX=true,true   
                game_state='select_difficulty'            
            elseif x>=30 and x<=225 and y>=420 and y<=448 then
                game_state='main_menu'
            end
        elseif game_state=='select_difficulty' then
            if x>=80 and x<=256 and y>=190 and y<=208 then
                game_state='play'
                level=1
            elseif x>=80 and x<=285 and y>=250 and y<=268 then
                game_state='play'
                level=2
            elseif x>=80 and x<=315 and y>=310 and y<=328 then
                game_state='play'                
                level=3
            elseif x>=30 and x<=225 and y>=420 and y<=448 then
                game_state='main_menu'
            end
        else
            if checkAllFull()==false and  popup==false and checkWinner()==nil then
                for i=1,3,1 do
                    for j=1,3,1 do
                        if x>=HOR_MARGIN +(j-1)*TILESIZE and x<=HOR_MARGIN+j*TILESIZE and
                        y>=VER_MARGIN + (i-1)*TILESIZE and y<=VER_MARGIN+i*TILESIZE and 
                        tileGrid[i][j]=="" and user_can_play(ai) then
                            tileGrid[i][j]=player_in_action
                            removeElement(i,j)
                            msg=string.format("Player %s Made a Move",getPlayer(player_in_action))
                            if player_in_action=="0" then
                                player_in_action="X"
                            else
                                player_in_action="0"
                            end
                            msg=msg..string.format(". Player %s's Turn ",getPlayer(player_in_action))
                            if checkAllFull()==true and checkWinner()==nil then
                                msg="Game Over. No one won"
                                popup=true
                            elseif checkWinner()~=nil then
                                msg=string.format("Player %s won the game!!!",getPlayer(checkWinner()))
                                popup=true
                            end
                        end
                    end
                end
                timer=0
            end
        end
    end
end

function getEmptySquares()
    local tbl={}
    for i=1,3 do
        for j=1,3 do
            if tileGrid[i][j]=="" then
                tbl[#tbl+1]={i,j}
            end
        end
    end
    return tbl
end

function checkDiagonal(player,diag)
    if tileGrid[1][1]==player and tileGrid[2][2]==player and tileGrid[3][3]==player and (diag==1 or diag==nil) then
        winComb={{1,1},{2,2},{3,3}}
        return true
    elseif tileGrid[1][3]==player and tileGrid[2][2]==player and tileGrid[3][1]==player and (diag==2 or diag==nil) then
        winComb={{1,3},{2,2},{3,1}}        
        return true
    else
        return false
    end
end

function checkRC(player,value,orientation)
    --check if a specific (row) row or column (orientation) is complete
    if value==nil then
        cond=3
        value=1
    else
        cond=value
    end
    for i=value,cond,1 do
        complete=true
        for j=1,3,1 do
            if orientation=='row' and tileGrid[i][j]~=player then
                complete=false
                --print(tileGrid[i][j])
            elseif orientation=='column' and tileGrid[j][i]~=player then
                complete=false
            end
        end
        if complete==true then
            if orientation=='row' then
                winComb={{i,1},{i,2},{i,3}}        
            else
                winComb={{1,i},{2,i},{3,i}}                        
            end
            return true
        end
    end
    --winComb={}
    return false;
end

function checkHorVer(player)
    for i=1,3,1 do
       if checkRC(player,i,'row')==true or checkRC(player,i,'column')==true then
        return true
       end
    end
    return false
end

function checkAllEmpty()
    for i=1,3,1 do
        for j=1,3,1 do
            if tileGrid[i][j]~="" then
                return false
            end
        end
    end
    return true
end

function checkAllFull()
    for i=1,3,1 do
        for j=1,3,1 do
            if tileGrid[i][j]=="" then
                return false
            end
        end
    end
    return true
end

function checkWinner()
    if checkDiagonal("0")==true or checkHorVer("0") then
        return "0"
    elseif checkDiagonal("X")==true or checkHorVer("X") then
        return "X"
    else
        return nil
    end
end

function drawWinnerLine(i)
    offset=(i-1)*TILESIZE+TILESIZE/2
    if checkRC("0",i,'row')==true or checkRC("X",i,'row')==true then
        love.graphics.line(HOR_MARGIN,VER_MARGIN+offset,WWIDTH-HOR_MARGIN-7,VER_MARGIN+offset)
    elseif checkRC("0",i,'column')==true or checkRC("X",i,'column')==true then
        love.graphics.line(HOR_MARGIN+offset,VER_MARGIN,HOR_MARGIN+offset,VIEWPORT_HEIGHT-VER_MARGIN-8)
    elseif checkDiagonal("0",1) or checkDiagonal("X",1) then
        love.graphics.line(HOR_MARGIN+10,VER_MARGIN+10,HOR_MARGIN-10+3*TILESIZE,VER_MARGIN-10+3*TILESIZE)
    elseif checkDiagonal("X",2) or checkDiagonal("0",2) then
        love.graphics.line(HOR_MARGIN-10+3*TILESIZE,VER_MARGIN+10,HOR_MARGIN+10,VER_MARGIN-10+3*TILESIZE)
    end
end


function popupMsg()
    love.graphics.setColor(colors:getColor('lightgrey',0.9))
    love.graphics.rectangle('fill',WWIDTH/2-150,VIEWPORT_HEIGHT/2-50,300,100)
    love.graphics.setFont(GAMEOVERFONT)
    
    colors:setColor('slategrey')
    love.graphics.rectangle('line',WWIDTH/2-151,VIEWPORT_HEIGHT/2-51,300,100)
    
    local circle_hover=love.mouse.getX()>=WWIDTH/2+138 and love.mouse.getX()<=WWIDTH/2+158 and love.mouse.getY()>=VIEWPORT_HEIGHT/2-58 and love.mouse.getY()<=VIEWPORT_HEIGHT/2-38
    if circle_hover==true then
        love.graphics.setColor(colors.darkslategrey)
    end
    love.graphics.circle('fill',WWIDTH/2+148,VIEWPORT_HEIGHT/2-48,10,6)
    
    checkPopupHover(WWIDTH/2-130,VIEWPORT_HEIGHT/2+13,65,30,1)
    checkPopupHover(WWIDTH/2+55,VIEWPORT_HEIGHT/2+13,65,30,2)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Do you want to play again?",WWIDTH/2-150,VIEWPORT_HEIGHT/2-35,300,'center')
    love.graphics.setFont(MSGFONT)   
    love.graphics.print("Yes",WWIDTH/2-120,VIEWPORT_HEIGHT/2+20)    
    love.graphics.print("No",WWIDTH/2+70,VIEWPORT_HEIGHT/2+20)   
    love.graphics.setColor(colors.darkslategrey)
    
    if circle_hover==true then
        love.graphics.setColor(colors.white)
        if love.mouse.isDown(1) then
            popup=false
        end
    end
    love.graphics.circle('fill',WWIDTH/2+148,VIEWPORT_HEIGHT/2-48,3,10)        
    love.graphics.setColor(1,1,1)
end

function checkPopupHover(posx,posy,width,height,opt)
    local x=love.mouse.getX()
    local y=love.mouse.getY()
    if x>=posx and x<=posx+width and y>=posy and y<=posy+height then
        love.graphics.setColor(colors.darkslategrey)
        if love.mouse.isDown(1) then
            if opt==2 then
                love.event.quit()
            else
                tileGrid={{"","",""},{"","",""},{"","",""}}
                emptySpaces={{1,1},{1,2},{1,3},{2,1},{2,2},{2,3},{3,1},{3,2},{3,3}}
                winComb={}
                msg="Player 0's Turn:  Click on one of the grids"
                popup=false
            end
        end
    else
        love.graphics.setColor(colors.slategrey);
    end
    love.graphics.rectangle("fill",posx,posy,width,height)
end

function checkBoardWin(board)
	return (
		(board[1][1]==board[1][2] and board[1][2]==board[1][3] and board[1][3]) or
		(board[2][1]==board[2][2] and board[2][2]==board[2][3] and board[2][3]) or
		(board[3][1]==board[3][2] and board[3][2]==board[3][3] and board[3][3]) or

		(board[1][1]==board[2][1] and board[2][1]==board[3][1] and board[3][1]) or
		(board[1][2]==board[2][2] and board[2][2]==board[3][2] and board[3][2]) or
		(board[1][3]==board[2][3] and board[2][3]==board[3][3] and board[3][3]) or		

		(board[1][3]==board[2][2] and board[2][2]==board[3][1] and board[3][1]) or
		(board[1][1]==board[2][2] and board[2][2]==board[3][3] and board[3][3])
	)
end


function minimax(player,depth)
	
	local emptySpaces=getEmptySpaces(tileGrid)
	
	if #emptySpaces==0 then
		-- print('empty returning')
		return {score=0}
	elseif checkWinner(tileGrid)=='0' then
		-- print('won player 1')
		return {score=-10+depth}
	elseif checkWinner(tileGrid)=='X' then
		-- print('won player 2')		
		return {score=10-depth}
	end

	local moves={}
	for i=1,#emptySpaces do
		local move={}
		move.index=tileGrid[emptySpaces[i][1]][emptySpaces[i][2]]
		tileGrid[emptySpaces[i][1]][emptySpaces[i][2]]=player

		-- if depth==0 then print('here you go',tileGrid[emptySpaces[i]],emptySpaces[i]) end
		
		move.score=(minimax(player=='0' and 'X' or '0',depth+1)).score

		tileGrid[emptySpaces[i][1]][emptySpaces[i][2]]=move.index
		move.index=emptySpaces[i]
		table.insert(moves,move)
	end
	
	local bestMove
	if player == 'X' then
		local bestScore = -10000000;
		for i=1,#moves do
			if moves[i].score > bestScore then
				bestScore = moves[i].score;
				bestMove = i;
			end
		end
	else
		local bestScore = 10000000;
		for i=1,#moves do
			if moves[i].score < bestScore then
				bestScore = moves[i].score;
				bestMove = i;
			end
		end
	end

	
	return moves[bestMove]
	
end
function getEmptySpaces()
	local tbl={}
	for i=1,3 do
		for j=1,3 do
            if tileGrid[i][j]=='' then
				tbl[#tbl+1]={i,j}
			end
		end
	end
	return tbl
end
function computerMove(level)
    local grid={};
    local gapfound=false
    if level==1 then
        grid=emptySpaces[math.random(#emptySpaces)]
    elseif level==2 then
        for i=1,3 do
            for j=1,3 do
                --[[basically we want the ai to be more defensive then to be aggressive
                    So it will first try to match its own set and then try to spoil the
                    other player's set]]
                if tileGrid[i][j]=="" then 
                    tileGrid[i][j]=player_in_action
                    if checkWinner()~=nil then
                        grid[1]=i
                        grid[2]=j   
                        gapfound=true
                    end
                    tileGrid[i][j]="";
                    if gapfound then 
                        winComb={}
                        break 
                    end
                    tileGrid[i][j]=oppChar(player_in_action)
                    if checkWinner()~=nil then
                        grid[1]=i
                        grid[2]=j   
                        gapfound=true
                    end
                    tileGrid[i][j]="";
                    if gapfound then 
                        winComb={}
                        break 
                    end
                end
            end
        end        
    else
		grid=minimax(
            player_in_action,
            0
        ).index
        -- grid[1],grid[2]=grid[2],grid[2]
		-- for i in pairs(a) do print(i,a[i]) end
    end
    if grid[1]==nil or grid[2]==nil then
        grid=emptySpaces[math.random(#emptySpaces)]        
    end
    i=grid[1]
    j=grid[2]
    --print(#emptySpaces,i,j)
    love.mousereleased(HOR_MARGIN+(j-1)*TILESIZE+10,VER_MARGIN+(i-1)*TILESIZE+10,1,true)
end

function love.keypressed(key)
    if key=='u' then
        for i=1,3 do
            str=''
            for j=1,3 do
                str=str..tileGrid[i][j]..' '
            end
            print(str)
        end
    end
end

function love.update(dt)
    if timer>1  then
        if game_state=='play' and checkWinner()==nil and checkAllFull()==false then
            if (aiX==true and player_in_action=="X") or (ai0==true and player_in_action=="0") then
                computerMove(level)
            end
        end
        timer=0
        
    end
    timer=timer+dt
    
end

function oppChar(c)
    if c=="0" then
        return "X"
    elseif c=="X" then
        return "0"
    else
        return ""
    end
end

function getPlayer(c)
    if c=="0" then
        return "1"
    elseif c=="X" then
        return "2"
    end
    return nil
end

function select_combination()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(back,0,0,0,0.35,0.35,0,0,0,0);   
    love.graphics.line(0,90,640,90)   
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",18)        
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle('fill',0,50,640,40)    
    love.graphics.rectangle('fill',20,413,210,30)    
    love.graphics.rectangle('fill',60,160,300,195)
    highlightOnHover("Human Vs Human",80,190,256)
    highlightOnHover("Human Vs Computer",80,250,285)
    highlightOnHover("Computer Vs Computer",80,310,315)
    highlightOnHover("Back to Main Menu",30,420,225)
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",24)
    love.graphics.setColor(1,1,0)
    love.graphics.print("Select the mode of gameplay:-",30,60)
end

function select_difficulty_level()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(back,0,0,0,0.35,0.35,0,0,0,0);   
    
    love.graphics.line(0,90,640,90)   
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",18)        
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle('fill',0,50,640,40)    
    love.graphics.rectangle('fill',20,413,210,30)    
    love.graphics.rectangle('fill',60,160,300,195)
    highlightOnHover("Easy : Walk in the park",80,190,295)
    highlightOnHover("Medium : For the average",80,250,320)
    highlightOnHover("Hard : Next to Impossible",80,310,315)
    highlightOnHover("Back to Main Menu",30,420,225)
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",24)        
    love.graphics.setColor(1,1,0)
    love.graphics.print("Select the difficulty level:-",30,60)    
end

function highlightOnHover(str,posx,posy,posx2)
    if checkHover(str,posx,posy,posx2)==true then
        love.graphics.setColor(1,1,0)
    else
        love.graphics.setColor(1,1,1,0.8)
    end
    love.graphics.print(str,posx,posy)
end
function checkHover(str,posx,posy,posx2)
    local x=love.mouse.getX()
    local y=love.mouse.getY()
    if x>=posx and x<=posx2 and y>=posy and y<=posy+18 then
        return true
    else
        return false
    end
end

function main_menu()
    BACKGROUND_MUSIC:play()
    BACKGROUND_MUSIC:setLooping(true)
    love.graphics.draw(back,0,0,0,0.35,0.325,0,0,0,0);   
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line",40,180,280,162)
    love.graphics.line(40, 215, 320, 215)  
    love.graphics.setColor(1,1,1,0.9)      
    love.graphics.draw(text,20,30,0,0.6,0.6) 
    love.graphics.draw(text2,38,100,0,0.6,0.6) 
    love.graphics.setColor(1,1,1)     
    love.graphics.setNewFont("fonts/Orbitron Medium.otf",14) 
    if timer>0.3 and timer<1 then   
        love.graphics.print("Click to start the game ",230,VIEWPORT_HEIGHT-10); 
    end
    love.graphics.print("Game Objectives:",42,188);
    love.graphics.setNewFont("fonts/arial.ttf",15)
    love.graphics.printf("Select any of the playable options. You can play in three different modes. Select one of them and select difficulty level (for the computer) The rules are same as you would expect in a typical tictactoe game",42,230,278,'justify')   
    love.graphics.print("For now just tap to continue",42,315)
    love.graphics.setColor(0.7,0.7,0.7)    
    love.graphics.print("(C) Copyright Okra Softmakers",12,VIEWPORT_HEIGHT+25)
end
