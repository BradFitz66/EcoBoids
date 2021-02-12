using System;
using System.Collections;
using System.Threading;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;

using Boids.lib;


/*
	Title: GameApp
	Description: Handles initialization of boids and updating of systems like the spatial hash as-well as handling the drawing
*/
namespace Boids
{
	//Global stuff
	static{
		public static GameApp app;
		public static Camera2D cam;
		public static SpatialHash<Entity> hash;

		public const int worldWidth=2500;
		public const int worldHeight=2500;
		public const int BoidsAmount=1000;
		public const int FlockAmount=10;
	}

	class GameApp 
	{

		public List<Flock> flocks ~ delete _;

		float zoomLevel=1.0f;
		float camSpeed=6;
		float defaultCamSpeed=6;

		public this(){
			app=this;
			Init();
		}

		public ~this(){
			DeleteAndNullify!(hash);

		}
		public void Init(){

			Random mRand = scope Random();
			cam=Camera2D(.(0,0),.(0,0),0,1);
			hash=new SpatialHash<Entity>(200);
			
			flocks=new List<Flock>();
			let pi = Math.PI_f;

			for(int i=0; i<FlockAmount; i++){
				float randx=mRand.Next(0,worldWidth);
				float randy=mRand.Next(0,worldHeight);
				let f = new Flock(BoidsAmount/FlockAmount,randx,randy,1000);
				flocks.Add(f);
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

			for(int i=0; i<flocks.Count; i++){
				flocks[i].Update();
			}
		}
		public void Draw()
		{
			//Draw everything
			BeginDrawing();
				ClearBackground(.(255, 255, 255, 255));
				BeginMode2D(cam);
					for(int i=0; i<flocks.Count; i++){
						flocks[i].Draw();
					}
					hash.Draw();
				EndMode2D();
			EndDrawing();
		}
	}
}