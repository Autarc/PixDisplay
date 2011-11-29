# PIX - pix.coffee

###############################################################

# global functions

# gets the mouse position in the provided element
pos = (e) ->	
	if (e.pageX || e.pageY)
		x = e.pageX
		y = e.pageY
	else
	  	x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
	  	y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop 		

	posX = x 
	posY = y
	return ([posX,posY])


# 140byt.es (autarc) || random generator by me
`function random(a,b,c){c=a;a=!b?0:a<=b?a:b;!b?a>c?b=a:b=c:b>c?b=b:b=c;a=a^b?a:c;return a+(0|Math.random()*(b-a+1))}`


# returns a random color
randomColor = () ->
	return ('rgb('+random(255)+','+random(255)+','+random(255)+')')


# returns the color in a formated way
toRGB = (r,g,b) ->
	return ('rgb('+r+','+g+','+b+')')	


# a function to interpolate two colors
interpolate = (c1,c2) ->

	# gets the values for the RGB color
	c1 = c1.match(/\d+(\.\d+)?/g)
	c2 = c2.match(/\d+(\.\d+)?/g)
	
	r1 = c1[0]
	g1 = c1[1]
	b1 = c1[2]
	
	r2 = c2[0]
	g2 = c2[1]
	b2 = c2[2]
	
	rh = Math.max(r1,r2)
	rl = Math.min(r1,r2)

	gh = Math.max(g1,g2)
	gl = Math.min(g1,g2)

	bh = Math.max(b1,b2)
	bl = Math.min(b1,b2)
	
	rn = rh - rl
	gn = gh - gl
	bn = bh - bl

	return ([rn,gn,bn])

	
		

###############################################################
###############################################################


# Display - class which will be used for raster drawing
class Display	

	# the Display constructor allows to specify the target (@id) and the size (@width/@height)
	constructor: (@id,@fields) ->
			
		t = @											# local scope

		# checks the parameters, pseudo polymorphism
		type = typeof @id
		switch type
			when 'object' then (@id = ''+@id) 			
			when 'string' then (@id = @id) 				
			when 'number' then (@fields = @id)
			else console.log(type)			
		
		id = @id										# gloabal scope	

		# checks if a canvas exists, if not -> creae it
		if not document.getElementById (id)
			c = document.createElement('canvas')
			c.id = id			
			c.className = 'Display'
			document.body.appendChild(c)

		# pick element/canvas
		@cvs = document.getElementById(id)	
		@cvs.style.cursor = 'pointer'					# adds a pointer style to the canvas
		cvs = @cvs 										# gloabal scope
															
		@ctx = cvs.getContext('2d')		
		
		if (!@fields) then (@fields = 50) 				# default value for rows/columns
		fields = @fields 								# gloabal scope

		@cvs.width = 400				
		@cvs.height = 200

		# allows adressing the size from the display element
		@width = @cvs.width 							
		@height = @cvs.height		
		@size = (@cvs.width / fields)

		size = @size 									# gloabal scope 

		@scaledWidth = (@width / size)
		@scaledHeight = (@height / size)
			
		# draws a border around the display
		@.borders()


		# adding event listener to the canvas for drawing input,		
		# gets the coordinates of the first point as you pressed down

		# prevents chromes text selection while dragging
		document.onselectstart = () -> return false
			
		cvs.addEventListener 'mousedown', (e) ->	
			
			# gets the relative mouse position
			xc = pos(e)[0]
			yc = pos(e)[1]					
					
			xc = Math.floor(xc/size)
			yc = Math.floor(yc/size - 0.5)	
								
			@tp = new Point(xc,yc,randomColor())			
		
		# gets the coordinates of the second point as you release the button
		cvs.addEventListener 'mouseup', (e) ->	
								
			xc = pos(e)[0]
			yc = pos(e)[1]	

			xc = Math.floor(xc/size)
			yc = Math.floor(yc/size - 0.5) # 
									
			tp2 = new Point(xc,yc,randomColor())
			l = new Line(@tp,tp2)
			l.draw(t)				
		

	# sets the amount of fields  
	pixFieldset: (@fields) ->			

	# determines the size of a pix
	pixSize: (@size) ->	
		@.displaySize(@cvs.width,@cvs.height)
	
	# sets the size of the field
	displaySize: (width,height) ->
		cvs = @cvs
		cvs.width = (width * @size)
		cvs.height = (height * @size)
		(cvs.width - 1) until (cvs.width%@size==0)
		(cvs.height - 1) until (cvs.height%@size==0)
		@.borders()
				
	# draws the grid lines in the display
	grid: () ->
		ctx = @ctx	
		height = @cvs.height
		width = @cvs.width
		
		for x in [0...width] by @size
			ctx.moveTo(x,0) 								
			ctx.lineTo(x,height) 			
					
		for y in [0...height] by @size	
			ctx.moveTo(0,y) 					
			ctx.lineTo(width,y) 			
		
		# check if the grid already exists, turning it off
		if (@gstate != true)
			ctx.strokeStyle = 'rgba(100,100,100,0.5)'
			@gstate = true
		else
			ctx.strokeStyle = 'rgba(255,255,255,1.0)'
			@gstate = false
		
		ctx.lineWidth = 0.5
		ctx.stroke()	
			
	
	# draws the borders
	borders: () ->
		ctx = @ctx
		height = @cvs.height
		width = @cvs.width
		ctx.moveTo(0,0)
		ctx.lineTo(width,0)
		ctx.lineTo(width,height)
		ctx.lineTo(0,height)
		ctx.lineTo(0,0)
		ctx.stroke()	


	# draws a pix (will be called from the other classes)
	drawPix: (x,y,c) ->			
		size = @size
		color = if c then c else 'rgba(0,0,0,1.0)'
		@ctx.fillStyle = color
		@ctx.fillRect(x*size,y*size,size,size)	


	# clears the display
	clear: () ->	
		@cvs.width = @cvs.width
		@cvs.height = @cvs.height
		@.borders()
		if (@gstate == true)
			@gstate = false
			@.grid()



###############################################################

# a Point - which represent a Pixel at the Display
class Point

	# // class Point : point(x,y,color)
	constructor: (@posX,@posY,@color) ->
		(@color = 'rgba(0,0,0,1.0)') if not @color 	# the color of a point is black by default
				

	# // -> add/substract a vector  || changes the position of the point
	translate: (vector) ->				
		@posX += vector.x   
		@posY += vector.y
		

	# // -> substract points() || returns a new vector
	subtractPoint: (point) ->
		vX = @posX - @posX
		vY = @posY - @posY
		return ( new Vector(vX,vY) )


	# // -> rotate (...°) around (0,0)
	rotate: (angle) ->
		degree = (Math.PI * angle) / 180
		cos = Math.cos(degree)
		sin = Math.sin(degree)
		
		posX = @posX
		@posX = cos * (@posX) - sin * (@posY)
		@posY = sin * (posX) + cos * (@posY)


	# // -> scale ()
	scale: (factor) ->	
		@posX *= factor
		@posY *= factor
	

	# // -> draw()	
	draw: (@Display) -> 		
		# debugging notes for other devs
		if not @Display? then alert('Assigned to which Display ?') 		
		if (@posX > @Display.width) || (@posY > @Display.height) then alert ('Too high: '+ @posX + ' | ' + @posY)
		if (@posX < 0) || (@pos < 0) then alert ('Too low: '+ @posX + ' | ' + @posY)
		@Display.drawPix(@posX,@posY,@color)
		

###############################################################

# a Vector - which contains the data of a Vector (x,y)

class Vector

	# // class Vector: vector(x,y)
	constructor: (@x,@y) ->

	# // -> multiply/stretcg with scalar
	scale: (s) ->
		@x *= s
		@y *= s

	# // -> add & substract vectors
	merge: (vector) ->	
		@x += vector.x
		@y += vector.y
	
###############################################################	

# a line, which will be drawn between 2 points

class Line

	# // class line: line(p1,p2,color)
	constructor: (@p1,@p2,@color) ->


	# checks if the line has a color	
	hasColor: () ->
		return (!!@color)	
	

	# // => rotate around the top edge (0,0)
	rotate: (angle) ->
		@p1.rotate(angle)
		@p2.rotate(angle)
					

	# rotate around a given point.x,point.y // translate to 0,0 then rotate and retranslate
	rotateAroundAPoint: (p3,angle) ->

		# local definition
		p1 = @p1
		p2 = @p2

		# negative direction
		v = new Vector(-p3.posX,-p3.posY) 
		p1.translate(v)
		p2.translate(v)	

		# rotiert
		@.rotate(angle)

		# reverting through the positive direction
		v2 = new Vector(p3.posX,p3.posY)
		p1.translate(v2)
		p2.translate(v2)
		

	# // rotates around the middpoint of the line
	rotateAroundMidd: () ->	
		x = Math.round((@p2.x + @p1.x) / 2)
		y =	Math.round((@p2.y + @p1.y) / 2)
		m = new Point(x,y)
		@.rotateAroundPoint(m)
			
						
	# // => translate
	translate: (vector) ->
		@p1.translate(vector)	
		@p2.translate(vector)	


	# // =< scale 
	scale: (s) ->
		@p1.scale(s)
		@p2.scale(s)


	# // => draw, based on the middpoint algorithm	
	draw: (@Display) ->

		# locale variables
		x1 = @p1.posX
		x2 = @p2.posX
		y1 = @p1.posY
		y2 = @p2.posY
			
		# checks if the calculation are on the left or ride side of the system, overwise swapping the points vice versa
		if not (x2>=x1)
			tx = x1			
			ty = y1
			x1 = x2			
			y1 = y2
			x2 = tx
			y2 = ty	
				
		# the growth		
		dx = x2 - x1 
		dy = y2 - y1 
		
		# prefilled variables for later usage
		incrD = 0
		decrD = 0
		normalX = 0
		changeX	= 0
		normalY = 0
		changeY = 0	


		# rise to x	
		if (Math.abs(dx)>Math.abs(dy))		

			# fast/slow step		
			f1 = x1
			f2 = x2

			# progress
			normalX = 1
			changeX = 1
	
			if (y2>=y1)	 			# positive side									
				d = 2*dy-dx 		
				incrD = 2*dy 		
				decrD = 2*(dy-dx) 	
				changeY = 1	
																						
			else  					# negative side		 
				d = 2*(-dy)-dx				
				incrD = 2*(-dy)
				decrD = 2*(-dy-dx)
				changeY = -1				
									
		# rise to y											
		else

			# fast/slow step	
			f1 = y1
			f2 = y2

			# progress				
			changeX = 1

			if (y2>y1)				# positive side				
				d = 2*dx-dy
				incrD = 2*dx
				decrD = 2*(dx-dy)														
				changeY = 1			
				normalY = 1
																										
			else  					# negative side
				f1 = y2
				f2 = y1 

				d = 2*dx+dy		
				incrD = 2*dx
				decrD = 2*(dx+dy)
				normalY = -1
				changeY = -1
	

		# interpolate between the two colors
		steps = f2-f1		

		diffColor = interpolate(@p1.color,@p2.color)
		rInc = 0|(diffColor[0]/steps)
		gInc = 0|(diffColor[1]/steps)
		bInc = 0|(diffColor[2]/steps)
		
		# sets the base color
		baseC = @p1.color
		baseC = baseC.match(/\d+(\.\d+)?/g)				
		bC = toRGB(baseC[0],baseC[1],baseC[2])

		# startX & startY 
		x = x1 
		y = y1
	
		# placing the startpoint	
		p = new Point(x,y,bC)
		p.draw(@Display)	

		# iterates over the faster runner
		while (f1<=f2)

			if (d<=0)	# the point is on or above the line
				d += incrD
				x += normalX
				y += normalY
							
			else 		# the point is below the line
				d += decrD
				x += changeX
				y += changeY
			
			f1++ 		# increase/counter
			
			# sets the color into each drawn pixel
			baseC = [(+baseC[0]+rInc),(+baseC[1]+gInc),(+baseC[2]+bInc)]
			bC = toRGB(+baseC[0],+baseC[1],+baseC[2])
			
			p = new Point(x,y,bC)
			p.draw(@Display)
			

###############################################################