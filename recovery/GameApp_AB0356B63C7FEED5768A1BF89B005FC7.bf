using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;

using Boids.lib;


/*
	Title: GameApp
	Description: Handles initialization of boids and updating of systems like the quadtree as-well as handling the drawing
*/
namespace Boids
{
	//Global stuff
	static{
		public static GameApp app;
		public static Camera2D cam;
		public static Vector2 limitVec(this ref Vector2 vec, float maxLength) 
		{

			let lengthSquared = vec.x * vec.x + vec.y * vec.y;

			if ((lengthSquared > maxLength * maxLength) && (lengthSquared > 0))
			{
				let ratio = maxLength / Math.Sqrt(lengthSquared);
				vec.x *= ratio;
				vec.y *= ratio;
			}

			return vec;
		}
		public static SpatialHash<Entity> hash;


		//Extension methods for Raylib rectangle
		public static bool Contains(this Rectangle r, Vector2 point)
		{
			return (
				point.x >= r.x - r.width &&
				point.x < r.x + r.width &&
				point.y >= r.y - r.height &&
				point.y < r.y + r.height
			);
		}
		public const int worldWidth=10000;
		public const int worldHeight=10000;


	}

	class GameApp 
	{

		public List<Boid> boids;

		Point mousePoint;

		Vector2 camVel;
		float zoomLevel=1.0f;
		float camSpeed=6;
		float defaultCamSpeed=6;
		Random mRand = new Random() ~ delete _;
		public this(){
			app=this;
			cam=Camera2D(.(0,0),.(0,0),0,1);
			//mousePoint=new Point(Vector2.Zero);

			Init();
		}

		public ~this(){
			DeleteAndNullify!(hash);
			delete(boids);
		}
		public void Init(){
			hash=new SpatialHash<Entity>(200);
			boids=new List<Boid>();
			let pi = Math.PI_f;
			for(int i=0; i<5000; i++){
				float randx=mRand.Next(0,worldWidth);
				float randy=mRand.Next(0,worldHeight);
				let b = new Boid(randx,randy,float(mRand.Next(10,18))/10,45);
				cam.target=.(0,0);
				hash.Insert(b.position,b);
				boids.Add(b);
			}	
		}
		float angle = 0;
		

		public int32 GetScreenHeightWithZoom(){
			return int32(GetScreenHeight()*(1/Math.Abs(zoomLevel)));
		}
		public int32 GetScreenWidthWithZoom(){
			return int32(GetScreenWidth()*(1/Math.Abs(zoomLevel)));
		}
		public void Update()
		{
			
			camSpeed= IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_LEFT_SHIFT) ? defaultCamSpeed*2 : defaultCamSpeed;

			if(IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_A)){
				cam.target+= .(-1,0)*(camSpeed+(1/zoomLevel));
			}
			if(IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_D)){
				cam.target+= .(1,0)*(camSpeed+(1/zoomLevel));
			}
			if(IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_W)){
				cam.target+= .(0,-1)*(camSpeed+(1/zoomLevel));
			}
			if(IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_S)){
				cam.target+= .(0,1)*(camSpeed+(1/zoomLevel));
			}

			if(cam.target.x>(worldWidth-GetScreenWidthWithZoom()))
			{
				cam.target.x=worldWidth-GetScreenWidthWithZoom();
			}
			else if(cam.target.x<0){
				cam.target.x=0;
			}

			if(cam.target.y>worldHeight-GetScreenHeightWithZoom()){
				cam.target.y=worldHeight-GetScreenHeightWithZoom();
			}
			else if(cam.target.y <0){
				cam.target.y=0;
			}
			zoomLevel+=GetMouseWheelMove()*0.05f;
			if(zoomLevel<0.25f)
				zoomLevel=0.25f;
			else if(zoomLevel>2)
				zoomLevel=2;
			

			cam.zoom=zoomLevel;


			//Mouse interaction with boids
			if(IsMouseButtonDown(raylib_beef.Enums.MouseButton.MOUSE_LEFT_BUTTON)){
				List<Entity> b = scope List<Entity>();
				Vector2 mousePosWorld=GetScreenToWorld2D(GetMousePosition(),cam);
				
				hash.QueryPosition(mousePosWorld,ref b);

				for(int i=0;  i<b.Count; i++){
					if(Vector2Distance(mousePosWorld,b[i].position)<50){
						((Boid)b[i]).velocity+= Vector2Normalize(b[i].position-mousePosWorld);
					}
				}
			}

			if(IsMouseButtonDown(raylib_beef.Enums.MouseButton.MOUSE_RIGHT_BUTTON)){
				List<Entity> b = scope List<Entity>();
				Vector2 mousePosWorld=GetScreenToWorld2D(GetMousePosition(),cam);
				hash.QueryPosition(mousePosWorld,ref b);

				for(int i=0;  i<b.Count; i++){

					((Boid)b[i]).velocity+= -Vector2Normalize(b[i].position-mousePosWorld)*4;
					
				}
			}


			for(int i=0; i<boids.Count; i++){
				boids[i].prevPosition=.(boids[i].position.x,boids[i].position.y);
				boids[i].Update();
			}

			for(int i=0; i<boids.Count; i++){
				hash.UpdatePosition(boids[i].position,boids[i].prevPosition,boids[i]);
			}
			
			



			//Updates the tree, essentially. Clears all items and then adds them back in.
			
		}
		public void Draw()
		{
			//Draw everything
			BeginDrawing();
				ClearBackground(.(255, 255, 255, 255));
				BeginMode2D(cam);
					for(int i=0; i<boids.Count; i++){
						boids[i].Draw();
					}
					hash.Draw();
				DrawRectangleLinesEx(.(0,0,worldWidth,worldHeight),5,Color.YELLOW);
				EndMode2D();
	
			EndDrawing();
		}
	}
}