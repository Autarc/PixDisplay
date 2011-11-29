// The file which will be added/loaded to the other, and then starts the scripts

// Creating a new Display Element
var d = new Display('test');
d.grid();


// adddress the clear button clears the screen
var clear = document.querySelector('#clear');
clear.onclick = function(){
	d.clear();	
	clearInterval(intervalID);
	d.alreadyRotate = undefined;
};



// waiting for a keypress - until he does the action
window.onkeydown = function(e){

	// draws 100 random colored points
	if (e.which == 49){ // || #1

		// clears the screen if there was something before
		d.clear();

		for(var i=0;i<100;i++){
			var p = new Point(random(d.scaledWidth),random(d.scaledHeight),randomColor());
				p.draw(d);
			}		
		}	


	// draws 100 random colored lines
	if (e.which == 50){ // || #2

		d.clear();

		for (var j = 0; j < 100; j++) {		
			var p1 = new Point(random(d.scaledWidth),random(d.scaledHeight),randomColor());
			var p2 = new Point(random(d.scaledWidth),random(d.scaledHeight),randomColor());
			var l = new Line(p1,p2,randomColor());
			l.draw(d);
		}	
	} 


	// draws a rotating square rectangle
	if (e.which == 51){ // || #3

	d.clear();	

	if (!d.alreadyRotate){

		d.alreadyRotate = true;

		c  = randomColor();
		width = d.scaledWidth;
		height = d.scaledHeight;
		
		var middWidth = width/2;
		var middHeight = height/2;

		middpoint = new Point(middWidth,middHeight,randomColor());
		middpoint.draw(d);

		
		var p1 = new Point(middWidth-2,middHeight-2);
		var p2 = new Point(middWidth+2,middHeight-2);
		var p3 = new Point(middWidth+2,middHeight+2);
		var p4 = new Point(middWidth-2,middHeight+2);
									
		var l1 = new Line(p1,p2,c); // top
		var l2 = new Line(p2,p3,c); // right
		var l3 = new Line(p3,p4,c); // down
		var l4 = new Line(p4,p1,c); // left

		l1.draw(d);
		l2.draw(d);
		l3.draw(d);
		l4.draw(d);
		
		intervalID = setInterval(function(){
		
			d.clear();
			l1.rotateAroundAPoint(middpoint,1);
			l2.rotateAroundAPoint(middpoint,1);
			l3.rotateAroundAPoint(middpoint,1);
			l4.rotateAroundAPoint(middpoint,1);
			l1.draw(d);
			l2.draw(d);
			l3.draw(d);
			l4.draw(d);
							
		}, 100);

		} else {
			clearInterval(intervalID);
			d.alreadyRotate = undefined;	
		}
	
	} 

};

